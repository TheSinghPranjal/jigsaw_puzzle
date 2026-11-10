import '../geometry/jigsaw_geometry.dart';

enum PlaceResult { placed, completed, wrongSpot, wrongRotation, ignored }

enum TraySort { shuffled, edgesFirst, byPosition }

/// Serializable snapshot of a puzzle in progress.
class PuzzleSnapshot {
  const PuzzleSnapshot({
    required this.placed,
    required this.tray,
    required this.rotations,
    required this.elapsedSeconds,
    required this.hintsUsed,
    required this.zoom,
    required this.panX,
    required this.panY,
    required this.startedAtMs,
    required this.seed,
    required this.pieceCount,
  });

  final List<int> placed, tray;
  final Map<int, int> rotations;
  final int elapsedSeconds, hintsUsed, startedAtMs, seed, pieceCount;
  final double zoom, panX, panY;

  Map<String, dynamic> toJson() => {
        'placed': placed,
        'tray': tray,
        'rotations': {for (final e in rotations.entries) '${e.key}': e.value},
        'elapsed': elapsedSeconds,
        'hints': hintsUsed,
        'zoom': zoom,
        'panX': panX,
        'panY': panY,
        'startedAt': startedAtMs,
        'seed': seed,
        'pieceCount': pieceCount,
      };

  factory PuzzleSnapshot.fromJson(Map<String, dynamic> j) => PuzzleSnapshot(
        placed: (j['placed'] as List).cast<int>(),
        tray: (j['tray'] as List).cast<int>(),
        rotations: {for (final e in (j['rotations'] as Map).entries) int.parse(e.key as String): e.value as int},
        elapsedSeconds: j['elapsed'] as int,
        hintsUsed: j['hints'] as int,
        zoom: (j['zoom'] as num).toDouble(),
        panX: (j['panX'] as num).toDouble(),
        panY: (j['panY'] as num).toDouble(),
        startedAtMs: j['startedAt'] as int,
        seed: j['seed'] as int,
        pieceCount: j['pieceCount'] as int,
      );
}

/// All game rules, independent of Flutter widgets.
class PuzzleSession {
  PuzzleSession._(this.geometry, this.rotationEnabled, this.tray, this.placed, this.rotations, this.startedAtMs, this.hintsUsed, this.elapsedSeconds);

  /// A new game: pieces are dealt in an order derived from the level seed.
  factory PuzzleSession.start(JigsawGeometry g, {bool rotationEnabled = false, int? startedAtMs}) {
    final rnd = SeededRandom(g.spec.seed ^ 0x5bd1e995);
    final tray = [for (final p in g.pieces) p.id];
    _shuffle(tray, rnd);
    final rotations = <int, int>{};
    if (rotationEnabled) {
      for (final p in g.pieces) {
        rotations[p.id] = rnd.nextInt(4);
      }
    }
    return PuzzleSession._(g, rotationEnabled, tray, <int>{}, rotations, startedAtMs ?? DateTime.now().millisecondsSinceEpoch, 0, 0);
  }

  /// Restores a save. A save that doesn't match this puzzle returns null
  /// rather than producing a corrupt board.
  static PuzzleSession? restore(JigsawGeometry g, PuzzleSnapshot s, {bool rotationEnabled = false}) {
    final all = {for (final p in g.pieces) p.id};
    final placed = s.placed.toSet();
    final tray = s.tray.toList();
    if (s.seed != g.spec.seed || s.pieceCount != g.pieces.length) return null;
    if (placed.length != s.placed.length || tray.toSet().length != tray.length) return null;
    if (placed.intersection(tray.toSet()).isNotEmpty) return null;
    if (placed.union(tray.toSet()).length != all.length || !all.containsAll(placed) || !all.containsAll(tray)) return null;
    return PuzzleSession._(g, rotationEnabled, tray, placed, Map.of(s.rotations), s.startedAtMs, s.hintsUsed, s.elapsedSeconds);
  }

  final JigsawGeometry geometry;
  final bool rotationEnabled;
  final List<int> tray;
  final Set<int> placed;
  final Map<int, int> rotations;
  final int startedAtMs;
  int hintsUsed;
  int elapsedSeconds;
  int _shuffleCount = 0;

  int get total => geometry.pieces.length;
  double get progress => placed.length / total;
  bool get isComplete => placed.length == total;
  int rotationOf(int id) => rotations[id] ?? 0;
  PieceShape piece(int id) => geometry.pieces[id];

  /// Pieces shown in the tray, optionally only border pieces.
  List<int> visibleTray({bool edgesOnly = false}) => edgesOnly ? [for (final id in tray) if (piece(id).isBorder) id] : tray;

  void rotate(int id) {
    if (!rotationEnabled || placed.contains(id)) return;
    rotations[id] = (rotationOf(id) + 1) % 4;
  }

  /// Whether a drop centred at board position (x, y) lands on the slot.
  bool isNearSlot(int id, double x, double y, double tolerance) {
    final p = piece(id);
    final dx = x - p.centerX, dy = y - p.centerY;
    return dx * dx + dy * dy <= tolerance * tolerance;
  }

  /// Try to drop a piece. A placed piece is locked for the rest of the game.
  PlaceResult drop(int id, double x, double y, double tolerance) {
    if (placed.contains(id) || !tray.contains(id)) return PlaceResult.ignored;
    if (!isNearSlot(id, x, y, tolerance)) return PlaceResult.wrongSpot;
    if (rotationOf(id) != 0) return PlaceResult.wrongRotation;
    tray.remove(id);
    placed.add(id);
    return isComplete ? PlaceResult.completed : PlaceResult.placed;
  }

  /// Reorders unplaced pieces only. Placed pieces cannot be affected.
  void shuffle() {
    _shuffleCount++;
    _shuffle(tray, SeededRandom(geometry.spec.seed ^ (_shuffleCount * 0x9E3779B1) ^ placed.length));
  }

  void sortTray(TraySort mode) {
    switch (mode) {
      case TraySort.shuffled:
        shuffle();
      case TraySort.edgesFirst:
        tray.sort((a, b) {
          final ea = piece(a).isBorder ? 0 : 1, eb = piece(b).isBorder ? 0 : 1;
          return ea != eb ? ea - eb : a - b;
        });
      case TraySort.byPosition:
        tray.sort();
    }
  }

  void useHint() => hintsUsed++;

  /// Independent re-check of the final board before granting anything.
  bool verifyComplete() {
    if (!isComplete || tray.isNotEmpty) return false;
    final ids = {for (final p in geometry.pieces) p.id};
    return ids.length == total && placed.containsAll(ids) && placed.every((id) => rotationOf(id) == 0);
  }

  PuzzleSnapshot snapshot({required double zoom, required double panX, required double panY}) => PuzzleSnapshot(
        placed: placed.toList()..sort(),
        tray: List.of(tray),
        rotations: Map.of(rotations),
        elapsedSeconds: elapsedSeconds,
        hintsUsed: hintsUsed,
        zoom: zoom,
        panX: panX,
        panY: panY,
        startedAtMs: startedAtMs,
        seed: geometry.spec.seed,
        pieceCount: total,
      );

  static void _shuffle(List<int> list, SeededRandom rnd) {
    for (var i = list.length - 1; i > 0; i--) {
      final j = rnd.nextInt(i + 1);
      final t = list[i];
      list[i] = list[j];
      list[j] = t;
    }
  }
}
