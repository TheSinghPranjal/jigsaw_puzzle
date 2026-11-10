import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jigsaw_puzzle/data/levels/level_catalog.dart';
import 'package:jigsaw_puzzle/features/puzzle/geometry/jigsaw_geometry.dart';

void main() {
  final catalog = LevelCatalog.parse(File('assets/data/levels.json').readAsStringSync(), File('assets/data/collections.json').readAsStringSync());
  final levels = catalog.levels;

  test('exactly 500 levels numbered 1 to 500', () {
    expect(levels.length, 500);
    for (var i = 0; i < 500; i++) {
      expect(levels[i].id, i + 1);
    }
  });

  test('piece formula: known values and every level', () {
    expect(pieceCountForLevel(1), 10);
    expect(pieceCountForLevel(10), 10);
    expect(pieceCountForLevel(11), 20);
    expect(pieceCountForLevel(191), 200);
    expect(pieceCountForLevel(500), 500);
    for (final l in levels) {
      expect(l.pieceCount, pieceCountForLevel(l.id));
    }
  });

  test('images, thumbnails, seeds and titles are unique', () {
    expect(levels.map((l) => l.imageId).toSet().length, 500);
    expect(levels.map((l) => l.image).toSet().length, 500);
    expect(levels.map((l) => l.thumbnail).toSet().length, 500);
    expect(levels.map((l) => l.title).toSet().length, 500);
    expect(levels.map((l) => l.seed).toSet().length, 500);
  });

  test('stored grids produce exactly the right count with sensible shapes', () {
    for (final l in levels) {
      expect(l.spec.pieceCount, l.pieceCount, reason: 'level ${l.id}');
      final shape = (4 / 3) * l.rows / l.cols;
      expect(shape, inInclusiveRange(.5, 2.0), reason: 'level ${l.id} shape $shape');
    }
  });

  test('spec examples for grids hold', () {
    expect((levels[0].rows, levels[0].cols), (2, 5));
    expect((levels[10].rows, levels[10].cols), (4, 5));
    expect((levels[20].rows, levels[20].cols), (5, 6));
    expect((levels[90].rows, levels[90].cols), (10, 10));
    expect((levels[490].rows, levels[490].cols), (20, 25));
  });

  test('every level generates geometry with the stored piece count', () {
    for (final l in levels) {
      expect(JigsawGeometry.generate(l.spec).pieces.length, l.pieceCount, reason: 'level ${l.id}');
    }
  });

  test('ten collections of 50 in level order', () {
    expect(catalog.collections.length, 10);
    for (final (i, c) in catalog.collections.indexed) {
      expect(c.firstLevel, i * 50 + 1);
      expect(c.lastLevel, (i + 1) * 50);
      for (final l in catalog.levelsOf(c)) {
        expect(l.collectionId, c.id);
      }
    }
  });

  test('every image, thumbnail and cover exists and is a real WebP', () {
    bool isWebp(String path) {
      final f = File(path);
      if (!f.existsSync() || f.lengthSync() < 1000) return false;
      final b = f.openSync()..setPositionSync(0);
      final h = b.readSync(12);
      b.closeSync();
      return String.fromCharCodes(h.sublist(0, 4)) == 'RIFF' && String.fromCharCodes(h.sublist(8, 12)) == 'WEBP';
    }

    for (final l in levels) {
      expect(isWebp(l.image), isTrue, reason: l.image);
      expect(isWebp(l.thumbnail), isTrue, reason: l.thumbnail);
    }
    for (final c in catalog.collections) {
      expect(isWebp(c.cover), isTrue, reason: c.cover);
    }
  });

  test('daily image depends only on the date and stays in range', () {
    expect(dailyLevelFor('2026-11-10', 500), dailyLevelFor('2026-11-10', 500));
    final seen = {for (var d = 1; d <= 28; d++) dailyLevelFor('2026-02-${d.toString().padLeft(2, '0')}', 500)};
    expect(seen.length, greaterThan(20));
    expect(seen.every((x) => x >= 1 && x <= 500), isTrue);
  });

  test('daily difficulty sets its own piece count', () {
    final l = levels[0];
    expect(PuzzleSetup.daily(l, '2026-11-10', DailyDifficulty.expert).spec.pieceCount, 300);
    expect(PuzzleSetup.daily(l, '2026-11-10', DailyDifficulty.easy).spec.pieceCount, 24);
  });
}
