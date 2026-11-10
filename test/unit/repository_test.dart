import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jigsaw_puzzle/core/database/app_database.dart';
import 'package:jigsaw_puzzle/data/levels/level_catalog.dart';
import 'package:jigsaw_puzzle/data/repositories/game_repository.dart';
import 'package:jigsaw_puzzle/features/puzzle/engine/puzzle_session.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  final catalog = LevelCatalog.parse(File('assets/data/levels.json').readAsStringSync(), File('assets/data/collections.json').readAsStringSync());
  late AppDatabase db;
  late GameRepository repo;
  var now = DateTime(2026, 11, 10, 9);

  setUp(() {
    now = DateTime(2026, 11, 10, 9);
    db = AppDatabase(NativeDatabase.memory());
    repo = GameRepository(db, catalog, clock: () => now);
  });
  tearDown(() => db.close());

  Future<int> coins() async => (await db.select(db.playerProfiles).getSingle()).totalCoins;
  PuzzleSetup camp(int id) => PuzzleSetup.campaign(catalog.level(id));
  Future<Map<int, ProgressRow>> progress() async => {for (final r in await db.select(db.puzzleProgress).get()) r.levelId: r};
  Future<void> finishLevels(int from, int to) async {
    for (var i = from; i <= to; i++) {
      await repo.completeLevel(camp(i), runId: i, seconds: 60, hints: 0);
    }
  }

  test('first completion pays base plus bonus; replay pays base only', () async {
    final r = await repo.completeLevel(camp(1), runId: 100, seconds: 30, hints: 0);
    expect(r.coins, 20);
    expect(await coins(), greaterThanOrEqualTo(20));
    final again = await repo.completeLevel(camp(1), runId: 200, seconds: 20, hints: 0);
    expect(again.coins, 10);
    expect(await coins(), 30);
    expect((await progress())[1]!.bestSeconds, 20);
  });

  test('the same run cannot pay twice', () async {
    await repo.completeLevel(camp(1), runId: 5, seconds: 30, hints: 0);
    final before = await coins();
    final dup = await repo.completeLevel(camp(1), runId: 5, seconds: 30, hints: 0);
    expect(dup.coins, 0);
    expect(dup.alreadyRecorded, isTrue);
    expect(await coins(), before);
    expect((await progress())[1]!.playCount, 1);
  });

  test('stars follow hint use and replay never lowers the best', () async {
    expect(Scoring.stars(0), 3);
    expect(Scoring.stars(2), 2);
    expect(Scoring.stars(9), 1);
    await repo.completeLevel(camp(1), runId: 1, seconds: 10, hints: 0);
    await repo.completeLevel(camp(1), runId: 2, seconds: 10, hints: 9);
    expect((await progress())[1]!.bestStars, 3);
  });

  test('unlocks advance one level at a time', () async {
    expect(GameRepository.unlockedThrough(await progress(), 500), 1);
    await finishLevels(1, 3);
    expect(GameRepository.unlockedThrough(await progress(), 500), 4);
  });

  test('ledger rejects duplicates and non-positive amounts', () async {
    expect(await repo.grant(key: 'x', type: 't', eventId: 'e', amount: 5), isTrue);
    expect(await repo.grant(key: 'x', type: 't', eventId: 'e', amount: 5), isFalse);
    expect(await coins(), 5);
    expect(() => repo.grant(key: 'y', type: 't', eventId: 'e', amount: 0), throwsArgumentError);
    expect(() => repo.grant(key: 'z', type: 't', eventId: 'e', amount: -3), throwsArgumentError);
  });

  test('collection and 50-level milestone pay exactly once', () async {
    await finishLevels(1, 49);
    final last = await repo.completeLevel(camp(50), runId: 50, seconds: 60, hints: 0);
    expect(last.lines.map((l) => l.label), containsAll(['Collection complete', '50-level milestone']));
    expect(last.collectionCompleted, isNotNull);
    final replay = await repo.completeLevel(camp(50), runId: 999, seconds: 60, hints: 0);
    expect(replay.lines.map((l) => l.label), ['Level complete']);
  });

  test('daily rewards once, never unlocks campaign levels', () async {
    final date = repo.todayKey;
    final setup = PuzzleSetup.daily(repo.dailyLevel(date), date, DailyDifficulty.hard);
    final a = await repo.completeDaily(setup, seconds: 100, hints: 0);
    expect(a.coins, 25);
    final b = await repo.completeDaily(setup, seconds: 90, hints: 0);
    expect(b.coins, 0);
    expect(await coins(), 25);
    expect(GameRepository.unlockedThrough(await progress(), 500), 1);
  });

  test('past dailies are practice with no reward', () async {
    final setup = PuzzleSetup.daily(repo.dailyLevel('2026-11-01'), '2026-11-01', DailyDifficulty.easy);
    expect((await repo.completeDaily(setup, seconds: 10, hints: 0)).coins, 0);
    expect(await repo.currentStreak(), 0);
  });

  test('streak counts consecutive local days and pays at seven', () async {
    CompletionResult? last;
    for (var d = 0; d < 7; d++) {
      now = DateTime(2026, 11, 10 + d, 9);
      final date = repo.todayKey;
      last = await repo.completeDaily(PuzzleSetup.daily(repo.dailyLevel(date), date, DailyDifficulty.easy), seconds: 10, hints: 0);
    }
    expect(await repo.currentStreak(), 7);
    expect(last!.lines.map((l) => l.label), contains('7-day streak'));
    now = DateTime(2026, 11, 20, 9);
    expect(await repo.currentStreak(), 0);
  });

  test('active puzzle saves, restores and clears on completion', () async {
    final setup = camp(1);
    const snap = PuzzleSnapshot(placed: [1, 2], tray: [0, 3], rotations: {}, elapsedSeconds: 33, hintsUsed: 1, zoom: 2, panX: 400, panY: 500, startedAtMs: 8, seed: 1, pieceCount: 4);
    await repo.saveActive(setup, snap);
    final loaded = (await repo.loadActive(setup.key))!;
    expect(loaded.placed, [1, 2]);
    expect(loaded.elapsedSeconds, 33);
    expect(loaded.panX, 400);
    await repo.completeLevel(setup, runId: 8, seconds: 40, hints: 1);
    expect(await repo.loadActive(setup.key), isNull);
  });

  test('state persists across a database reopen', () async {
    final dir = Directory.systemTemp.createTempSync('jigsaw');
    final file = File('${dir.path}/t.db');
    var d = AppDatabase(NativeDatabase(file));
    var r = GameRepository(d, catalog, clock: () => now);
    await r.completeLevel(camp(1), runId: 1, seconds: 10, hints: 0);
    await r.setFavorite(9, true);
    await r.saveActive(camp(2), const PuzzleSnapshot(placed: [0], tray: [1], rotations: {}, elapsedSeconds: 5, hintsUsed: 0, zoom: 1, panX: 1, panY: 1, startedAtMs: 1, seed: 1, pieceCount: 2));
    await d.close();

    d = AppDatabase(NativeDatabase(file));
    r = GameRepository(d, catalog, clock: () => now);
    expect((await (d.select(d.playerProfiles)).getSingle()).totalCoins, 20);
    expect((await r.loadActive('campaign:2'))!.placed, [0]);
    expect((await d.select(d.puzzleFavorites).get()).map((f) => f.levelId), [9]);
    await d.close();
    dir.deleteSync(recursive: true);
  });

  test('favorites do not duplicate', () async {
    await repo.setFavorite(5, true);
    await repo.setFavorite(5, true);
    expect((await db.select(db.puzzleFavorites).get()).length, 1);
    await repo.setFavorite(5, false);
    expect(await db.select(db.puzzleFavorites).get(), isEmpty);
  });

  test('achievement completes from real progress and claims once', () async {
    final r = await repo.completeLevel(camp(1), runId: 1, seconds: 10, hints: 0);
    expect(r.newAchievements.map((a) => a.id), containsAll(['first_puzzle', 'perfect']));
    final def = achievementDefs.firstWhere((a) => a.id == 'first_puzzle');
    final before = await coins();
    expect(await repo.claimAchievement(def), isTrue);
    expect(await repo.claimAchievement(def), isFalse);
    expect(await coins(), before + def.reward);
    final locked = achievementDefs.firstWhere((a) => a.id == 'levels_500');
    expect(await repo.claimAchievement(locked), isFalse);
  });
}
