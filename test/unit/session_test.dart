import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:jigsaw_puzzle/features/puzzle/engine/puzzle_session.dart';
import 'package:jigsaw_puzzle/features/puzzle/geometry/jigsaw_geometry.dart';

void main() {
  final g = JigsawGeometry.generate(const PuzzleSpec(rows: 4, cols: 5, seed: 42, width: 1600, height: 1200));
  PuzzleSession fresh({bool rotation = false}) => PuzzleSession.start(g, rotationEnabled: rotation, startedAtMs: 1);
  const tol = 50.0;

  test('deals every piece once, reproducibly', () {
    final s = fresh();
    expect(s.tray.toSet().length, 20);
    expect(fresh().tray, s.tray);
  });

  test('correct drop snaps, locks, and updates tray and progress', () {
    final s = fresh();
    final p = g.pieces[7];
    expect(s.drop(7, p.centerX + 10, p.centerY - 10, tol), PlaceResult.placed);
    expect(s.placed, contains(7));
    expect(s.tray, isNot(contains(7)));
    expect(s.progress, closeTo(1 / 20, 1e-9));
    expect(s.drop(7, 0, 0, tol), PlaceResult.ignored, reason: 'placed pieces stay locked');
    expect(s.placed, contains(7));
  });

  test('wrong drop leaves the piece in the tray', () {
    final s = fresh();
    final other = g.pieces[19];
    expect(s.drop(0, other.centerX, other.centerY, tol), PlaceResult.wrongSpot);
    expect(s.tray, contains(0));
    expect(s.placed, isEmpty);
  });

  test('shuffle never disturbs placed pieces', () {
    final s = fresh();
    for (final id in [1, 2, 3]) {
      s.drop(id, g.pieces[id].centerX, g.pieces[id].centerY, tol);
    }
    final before = s.tray.toSet();
    final order = List.of(s.tray);
    s.shuffle();
    expect(s.placed, {1, 2, 3});
    expect(s.tray.toSet(), before);
    expect(s.tray, isNot(order));
  });

  test('edge filter shows only border pieces', () {
    final s = fresh();
    final visible = s.visibleTray(edgesOnly: true);
    expect(visible, isNotEmpty);
    expect(visible.every((id) => g.pieces[id].isBorder), isTrue);
    expect(visible.length, lessThan(s.tray.length));
    expect(s.visibleTray().length, 20);
  });

  test('rotation must be upright to place, then locks', () {
    final s = fresh(rotation: true);
    final id = s.tray.firstWhere((i) => s.rotationOf(i) != 0);
    final p = g.pieces[id];
    expect(s.drop(id, p.centerX, p.centerY, tol), PlaceResult.wrongRotation);
    while (s.rotationOf(id) != 0) {
      s.rotate(id);
    }
    expect(s.drop(id, p.centerX, p.centerY, tol), PlaceResult.placed);
    s.rotate(id);
    expect(s.rotationOf(id), 0);
  });

  test('completion only after every piece, and verifies', () {
    final s = fresh();
    late PlaceResult last;
    for (final p in g.pieces) {
      expect(s.verifyComplete(), isFalse);
      last = s.drop(p.id, p.centerX, p.centerY, tol);
    }
    expect(last, PlaceResult.completed);
    expect(s.verifyComplete(), isTrue);
  });

  test('save survives JSON and restores identical state', () {
    final s = fresh();
    s.drop(4, g.pieces[4].centerX, g.pieces[4].centerY, tol);
    s.elapsedSeconds = 77;
    s.useHint();
    final json = jsonDecode(jsonEncode(s.snapshot(zoom: 2.5, panX: 300, panY: 200).toJson())) as Map<String, dynamic>;
    final snap = PuzzleSnapshot.fromJson(json);
    final r = PuzzleSession.restore(g, snap)!;
    expect(r.placed, s.placed);
    expect(r.tray, s.tray);
    expect(r.elapsedSeconds, 77);
    expect(r.hintsUsed, 1);
    expect(snap.zoom, 2.5);
    expect(snap.panX, 300);
  });

  test('corrupt or mismatched saves are rejected', () {
    final s = fresh();
    final good = s.snapshot(zoom: 1, panX: 0, panY: 0);
    PuzzleSnapshot tweak({List<int>? placed, List<int>? tray, int? seed}) => PuzzleSnapshot(placed: placed ?? good.placed, tray: tray ?? good.tray, rotations: const {}, elapsedSeconds: 0, hintsUsed: 0, zoom: 1, panX: 0, panY: 0, startedAtMs: 1, seed: seed ?? good.seed, pieceCount: good.pieceCount);
    expect(PuzzleSession.restore(g, tweak(seed: 9)), isNull);
    expect(PuzzleSession.restore(g, tweak(tray: good.tray.sublist(1))), isNull, reason: 'a piece went missing');
    expect(PuzzleSession.restore(g, tweak(placed: [good.tray.first])), isNull, reason: 'piece both placed and in tray');
  });
}
