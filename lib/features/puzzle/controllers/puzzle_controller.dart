import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../engine/puzzle_session.dart';
import '../rendering/piece_atlas.dart';

/// Board camera. [scale] maps board pixels to screen pixels.
class BoardView {
  const BoardView(this.scale, this.tx, this.ty);
  final double scale, tx, ty;
  Offset toBoard(Offset local) => Offset((local.dx - tx) / scale, (local.dy - ty) / scale);
  Offset toScreen(Offset board) => Offset(board.dx * scale + tx, board.dy * scale + ty);
}

class DragVisual {
  const DragVisual(this.id, this.center, this.scale, {this.opacity = 1, this.wrong = false});
  final int id;
  final Offset center;
  final double scale, opacity;
  final bool wrong;
}

enum DropFeedback { none, placed, wrongSpot, wrongRotation, completed }

/// Connects the rules to the screen through small notifiers, so a finger move
/// repaints one piece and a pan repaints one canvas. No widget rebuilds.
class PuzzleController {
  PuzzleController(this.session, this.atlas, {required this.onSave, required this.onFeedback});

  final PuzzleSession session;
  final PieceAtlas atlas;
  final Future<void> Function(PuzzleSnapshot) onSave;
  final void Function(DropFeedback) onFeedback;

  final view = ValueNotifier(const BoardView(1, 0, 0));
  final boardVersion = ValueNotifier(0);
  final trayVersion = ValueNotifier(0);
  final selected = ValueNotifier<int?>(null);
  final hintTarget = ValueNotifier<int?>(null);
  final drag = ValueNotifier<DragVisual?>(null);
  final elapsed = ValueNotifier(0);
  final edgesOnly = ValueNotifier(false);

  Size viewport = Size.zero;
  double zoom = 1;
  double maxZoom = 6;
  double _fit = 1;
  int? lastPlaced;
  Timer? _timer;

  late Float32List placedTransforms, placedRects;

  double get boardW => session.geometry.spec.width;
  double get boardH => session.geometry.spec.height;

  void init() {
    elapsed.value = session.elapsedSeconds;
    _rebuildPlaced();
  }

  void _rebuildPlaced() {
    final (t, r) = atlas.spriteData(session.placed);
    placedTransforms = t;
    placedRects = r;
  }

  // ---- timer ----
  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      session.elapsedSeconds++;
      elapsed.value = session.elapsedSeconds;
    });
  }

  void stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  // ---- camera ----
  /// Starting zoom keeps pieces at a usable size however many there are.
  void layout(Size vp, {double? restoredZoom, Offset? restoredCenter}) {
    final first = viewport == Size.zero;
    viewport = vp;
    _fit = math.min(vp.width / boardW, vp.height / boardH) * .96;
    final g = session.geometry;
    final unit = math.min(g.cellWidth, g.cellHeight);
    maxZoom = math.max(4, 72 / (unit * _fit));
    if (first) {
      zoom = (restoredZoom ?? (40 / (unit * _fit))).clamp(1.0, maxZoom);
      final c = restoredCenter ?? Offset(boardW / 2, boardH / 2);
      _setCamera(zoom, vp.center(Offset.zero) - c * (_fit * zoom));
    } else {
      _setCamera(zoom, Offset(view.value.tx, view.value.ty));
    }
  }

  void _setCamera(double z, Offset t) {
    zoom = z.clamp(1.0, maxZoom);
    final s = _fit * zoom;
    final w = boardW * s, h = boardH * s;
    const margin = 24.0;
    double clampAxis(double v, double size, double vp) => size <= vp ? (vp - size) / 2 : v.clamp(vp - size - margin, margin);
    view.value = BoardView(s, clampAxis(t.dx, w, viewport.width), clampAxis(t.dy, h, viewport.height));
  }

  double _gestureZoom = 1;
  void scaleStart() => _gestureZoom = zoom;

  void scaleUpdate(double factor, Offset focal, Offset delta) {
    final v = view.value;
    final anchor = v.toBoard(focal);
    final z = (_gestureZoom * factor).clamp(1.0, maxZoom);
    final s = _fit * z;
    _setCamera(z, focal + delta - anchor * s);
  }

  void zoomBy(double factor, [Offset? focal]) {
    final f = focal ?? viewport.center(Offset.zero);
    final v = view.value;
    final anchor = v.toBoard(f);
    final z = (zoom * factor).clamp(1.0, maxZoom);
    _setCamera(z, f - anchor * (_fit * z));
  }

  void fit() {
    zoom = 1;
    _setCamera(1, Offset.zero);
  }

  void centerOn(Offset board) {
    final s = view.value.scale;
    _setCamera(zoom, viewport.center(Offset.zero) - board * s);
  }

  Offset get cameraCenter => view.value.toBoard(viewport.center(Offset.zero));

  // ---- pieces ----
  void select(int? id) {
    selected.value = id;
    if (hintTarget.value != id) hintTarget.value = null;
  }

  void rotateSelected() {
    final id = selected.value;
    if (id == null) return;
    session.rotate(id);
    trayVersion.value++;
    save();
  }

  /// Highlights the slot for the selected piece; never places it.
  void hint() {
    final id = selected.value ?? (session.tray.isEmpty ? null : session.visibleTray(edgesOnly: edgesOnly.value).firstOrNull);
    if (id == null) return;
    selected.value = id;
    if (hintTarget.value != id) {
      session.useHint();
      hintTarget.value = id;
      save();
    }
    final p = session.piece(id);
    centerOn(Offset(p.centerX, p.centerY));
  }

  void shuffle() {
    session.shuffle();
    trayVersion.value++;
    save();
  }

  void sort(TraySort mode) {
    session.sortTray(mode);
    trayVersion.value++;
    save();
  }

  void toggleEdges() {
    edgesOnly.value = !edgesOnly.value;
    trayVersion.value++;
  }

  double get _tolerance {
    final g = session.geometry;
    final unit = math.min(g.cellWidth, g.cellHeight);
    return math.min(math.max(unit * .55, 26 / view.value.scale), unit * 1.1);
  }

  /// [local] is the drop point in board-viewport coordinates, or null when the
  /// piece was released outside the board.
  DropFeedback drop(int id, Offset? local) {
    if (local == null) return DropFeedback.none;
    final b = view.value.toBoard(local);
    final result = session.drop(id, b.dx, b.dy, _tolerance);
    switch (result) {
      case PlaceResult.wrongSpot:
        return _report(DropFeedback.wrongSpot);
      case PlaceResult.wrongRotation:
        return _report(DropFeedback.wrongRotation);
      case PlaceResult.ignored:
        return DropFeedback.none;
      case PlaceResult.placed:
      case PlaceResult.completed:
        lastPlaced = id;
        _rebuildPlaced();
        selected.value = null;
        hintTarget.value = null;
        boardVersion.value++;
        trayVersion.value++;
        save();
        return _report(result == PlaceResult.completed ? DropFeedback.completed : DropFeedback.placed);
    }
  }

  DropFeedback _report(DropFeedback f) {
    onFeedback(f);
    return f;
  }

  PuzzleSnapshot snapshot() {
    final c = cameraCenter;
    return session.snapshot(zoom: zoom, panX: c.dx, panY: c.dy);
  }

  Future<void> save() {
    if (session.isComplete) return Future.value();
    return onSave(snapshot());
  }

  void dispose() {
    stopTimer();
    view.dispose();
    boardVersion.dispose();
    trayVersion.dispose();
    selected.dispose();
    hintTarget.dispose();
    drag.dispose();
    elapsed.dispose();
    edgesOnly.dispose();
  }
}
