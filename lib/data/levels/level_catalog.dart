import 'dart:convert';

import 'package:flutter/services.dart';

import '../../features/puzzle/geometry/jigsaw_geometry.dart';

/// `pieceCount = 10 × ceil(level / 10)`.
int pieceCountForLevel(int level) => 10 * ((level + 9) ~/ 10);

const double kImageWidth = 1600, kImageHeight = 1200;

class PuzzleLevel {
  const PuzzleLevel({
    required this.id,
    required this.collectionId,
    required this.imageId,
    required this.title,
    required this.description,
    required this.pieceCount,
    required this.rows,
    required this.cols,
    required this.merges,
    required this.seed,
    required this.rotation,
    required this.tier,
    required this.difficulty,
    required this.rewardCoins,
    required this.image,
    required this.thumbnail,
    required this.estimatedMinutes,
  });

  final int id, pieceCount, rows, cols, seed, tier, rewardCoins, estimatedMinutes;
  final String collectionId, imageId, title, description, difficulty, image, thumbnail;
  final List<List<int>> merges;
  final bool rotation;

  factory PuzzleLevel.fromJson(Map<String, dynamic> j) => PuzzleLevel(
        id: j['levelId'] as int,
        collectionId: j['collectionId'] as String,
        imageId: j['imageId'] as String,
        title: j['title'] as String,
        description: j['description'] as String,
        pieceCount: j['pieceCount'] as int,
        rows: j['rows'] as int,
        cols: j['cols'] as int,
        merges: [for (final m in j['merges'] as List) (m as List).cast<int>()],
        seed: j['seed'] as int,
        rotation: j['rotation'] as bool,
        tier: j['tier'] as int,
        difficulty: j['difficulty'] as String,
        rewardCoins: j['rewardCoins'] as int,
        image: j['image'] as String,
        thumbnail: j['thumbnail'] as String,
        estimatedMinutes: j['estimatedMinutes'] as int,
      );

  PuzzleSpec get spec => PuzzleSpec(rows: rows, cols: cols, seed: seed, width: kImageWidth, height: kImageHeight, merges: merges);
}

class PuzzleCollection {
  const PuzzleCollection({required this.id, required this.order, required this.title, required this.description, required this.firstLevel, required this.lastLevel, required this.cover});
  final String id, title, description, cover;
  final int order, firstLevel, lastLevel;

  factory PuzzleCollection.fromJson(Map<String, dynamic> j) => PuzzleCollection(
        id: j['id'] as String,
        order: j['order'] as int,
        title: j['title'] as String,
        description: j['description'] as String,
        firstLevel: j['firstLevel'] as int,
        lastLevel: j['lastLevel'] as int,
        cover: j['cover'] as String,
      );
}

class LevelCatalog {
  LevelCatalog(this.levels, this.collections);

  final List<PuzzleLevel> levels;
  final List<PuzzleCollection> collections;

  PuzzleLevel level(int id) => levels[id - 1];
  PuzzleCollection collection(String id) => collections.firstWhere((c) => c.id == id);
  PuzzleCollection collectionOf(PuzzleLevel l) => collection(l.collectionId);
  List<PuzzleLevel> levelsOf(PuzzleCollection c) => levels.sublist(c.firstLevel - 1, c.lastLevel);

  static LevelCatalog parse(String levelsJson, String collectionsJson) => LevelCatalog(
        [for (final j in jsonDecode(levelsJson) as List) PuzzleLevel.fromJson(j as Map<String, dynamic>)],
        [for (final j in jsonDecode(collectionsJson) as List) PuzzleCollection.fromJson(j as Map<String, dynamic>)],
      );

  static Future<LevelCatalog> load() async =>
      parse(await rootBundle.loadString('assets/data/levels.json'), await rootBundle.loadString('assets/data/collections.json'));
}

enum DailyDifficulty {
  easy('Easy', 4, 6),
  medium('Medium', 6, 8),
  hard('Hard', 9, 12),
  expert('Expert', 15, 20);

  const DailyDifficulty(this.label, this.rows, this.cols);
  final String label;
  final int rows, cols;
  int get pieces => rows * cols;
}

String dateKey(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime parseDateKey(String key) {
  final p = key.split('-').map(int.parse).toList();
  return DateTime(p[0], p[1], p[2]);
}

/// The same local date always yields the same image.
int dailyLevelFor(String key, int levelCount) {
  var h = 0x811c9dc5;
  for (final unit in key.codeUnits) {
    h = ((h ^ unit) * 0x01000193) & 0xffffffff;
  }
  return (h % levelCount) + 1;
}

/// What the game screen needs, for campaign and daily puzzles alike.
class PuzzleSetup {
  const PuzzleSetup({required this.key, required this.level, required this.spec, required this.title, this.date, this.difficulty, this.rotation = false});

  final String key;
  final PuzzleLevel level;
  final PuzzleSpec spec;
  final String title;
  final String? date;
  final DailyDifficulty? difficulty;
  final bool rotation;

  bool get isDaily => date != null;

  factory PuzzleSetup.campaign(PuzzleLevel l, {bool rotation = false}) =>
      PuzzleSetup(key: 'campaign:${l.id}', level: l, spec: l.spec, title: l.title, rotation: rotation || l.rotation);

  factory PuzzleSetup.daily(PuzzleLevel l, String date, DailyDifficulty d, {bool rotation = false}) {
    return PuzzleSetup(
      key: 'daily:$date',
      level: l,
      title: 'Daily · ${l.title}',
      date: date,
      difficulty: d,
      rotation: rotation,
      spec: PuzzleSpec(rows: d.rows, cols: d.cols, seed: (date.hashCodeStable + d.index * 101) & 0x7fffffff, width: kImageWidth, height: kImageHeight),
    );
  }
}

extension on String {
  int get hashCodeStable {
    var h = 17;
    for (final u in codeUnits) {
      h = (h * 31 + u) & 0x7fffffff;
    }
    return h;
  }
}
