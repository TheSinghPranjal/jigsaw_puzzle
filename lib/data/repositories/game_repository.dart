import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';
import '../../features/puzzle/engine/puzzle_session.dart';
import '../levels/level_catalog.dart';

/// Tunable reward values. Timers never affect scoring.
class Scoring {
  static const levelCoins = 10, firstBonus = 10, dailyCoins = 25, streakCoins = 50, collectionCoins = 100;
  static const milestones = {50: 100, 100: 250, 250: 500};
  static const streakEvery = 7;

  /// 3 stars with no hints, 2 with up to [limitedHints], otherwise 1.
  static const limitedHints = 3;
  static int stars(int hints) => hints == 0 ? 3 : (hints <= limitedHints ? 2 : 1);
}

class AchievementDef {
  const AchievementDef(this.id, this.title, this.description, this.metric, this.target, this.reward);
  final String id, title, description, metric;
  final int target, reward;
}

const achievementDefs = [
  AchievementDef('first_puzzle', 'First Puzzle', 'Complete your first campaign level.', 'levels', 1, 10),
  AchievementDef('beginner', 'Puzzle Beginner', 'Complete 10 levels.', 'levels', 10, 25),
  AchievementDef('enthusiast', 'Puzzle Enthusiast', 'Complete 25 levels.', 'levels', 25, 50),
  AchievementDef('master', 'Puzzle Master', 'Complete 75 levels.', 'levels', 75, 75),
  AchievementDef('levels_50', '50 Levels Completed', 'Reach 50 completed levels.', 'levels', 50, 50),
  AchievementDef('levels_100', '100 Levels Completed', 'Reach 100 completed levels.', 'levels', 100, 100),
  AchievementDef('levels_250', '250 Levels Completed', 'Reach 250 completed levels.', 'levels', 250, 200),
  AchievementDef('levels_500', '500 Levels Completed', 'Complete the entire journey.', 'levels', 500, 500),
  AchievementDef('daily_champion', 'Daily Puzzle Champion', 'Complete 30 daily puzzles.', 'dailies', 30, 100),
  AchievementDef('streak_7', 'Seven-Day Streak', 'Complete dailies seven days running.', 'streak', 7, 50),
  AchievementDef('favorite_collector', 'Favorite Collector', 'Save 10 favorites.', 'favorites', 10, 25),
  AchievementDef('perfect', 'Perfect Completion', 'Finish a level with no hints.', 'perfect', 1, 25),
];

class CoinLine {
  const CoinLine(this.label, this.amount);
  final String label;
  final int amount;
}

class CompletionResult {
  CompletionResult({
    required this.setup,
    required this.seconds,
    required this.stars,
    required this.lines,
    required this.newAchievements,
    required this.alreadyRecorded,
    this.nextLevel,
    this.collectionCompleted,
  });

  final PuzzleSetup setup;
  final int seconds, stars;
  final List<CoinLine> lines;
  final List<AchievementDef> newAchievements;
  final bool alreadyRecorded;
  final int? nextLevel;
  final String? collectionCompleted;
  int get coins => lines.fold(0, (a, l) => a + l.amount);
}

class PlayerStats {
  const PlayerStats({required this.levels, required this.stars, required this.coins, required this.dailies, required this.bestStreak, required this.currentStreak, required this.favorites, required this.perfect, required this.totalSeconds});
  final int levels, stars, coins, dailies, bestStreak, currentStreak, favorites, perfect, totalSeconds;
}

class GameRepository {
  GameRepository(this.db, this.catalog, {DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final AppDatabase db;
  final LevelCatalog catalog;
  final DateTime Function() _clock;

  // ---------- ledger ----------

  /// Adds coins exactly once per [key]. Returns false when already granted.
  Future<bool> grant({required String key, required String type, required String eventId, required int amount}) {
    if (amount <= 0) throw ArgumentError.value(amount, 'amount', 'must be positive');
    return db.transaction(() async {
      final existing = await (db.select(db.rewardTransactions)..where((t) => t.idempotencyKey.equals(key))).getSingleOrNull();
      if (existing != null) return false;
      await db.into(db.rewardTransactions).insert(RewardTransactionsCompanion.insert(eventId: eventId, rewardType: type, amount: amount, timestamp: _clock(), idempotencyKey: key));
      await db.customUpdate('UPDATE player_profiles SET total_coins = total_coins + ? WHERE id = 1', variables: [Variable.withInt(amount)], updates: {db.playerProfiles});
      return true;
    });
  }

  Stream<int> watchCoins() => (db.select(db.playerProfiles)..where((t) => t.id.equals(1))).watchSingle().map((p) => p.totalCoins);
  Stream<PlayerProfileRow> watchProfile() => (db.select(db.playerProfiles)..where((t) => t.id.equals(1))).watchSingle();
  Stream<List<RewardRow>> watchLedger() => (db.select(db.rewardTransactions)..orderBy([(t) => OrderingTerm.desc(t.transactionId)])..limit(100)).watch();

  Future<void> setPlayerName(String name) => (db.update(db.playerProfiles)..where((t) => t.id.equals(1))).write(PlayerProfilesCompanion(playerName: Value(name)));

  // ---------- campaign ----------

  Stream<Map<int, ProgressRow>> watchProgress() => db.select(db.puzzleProgress).watch().map((rows) => {for (final r in rows) r.levelId: r});

  /// The highest level the player may open: one past the contiguous run of
  /// completed levels, so unlocks can only ever advance one at a time.
  static int unlockedThrough(Map<int, ProgressRow> progress, int total) {
    var next = 1;
    while (next <= total && (progress[next]?.completed ?? false)) {
      next++;
    }
    return next > total ? total : next;
  }

  Future<CompletionResult> completeLevel(PuzzleSetup setup, {required int runId, required int seconds, required int hints}) {
    final l = setup.level;
    return db.transaction(() async {
      final stars = Scoring.stars(hints);
      final runKey = 'level:${l.id}:run:$runId';
      final seen = await (db.select(db.rewardTransactions)..where((t) => t.idempotencyKey.equals(runKey))).getSingleOrNull();
      final prior = await (db.select(db.puzzleProgress)..where((t) => t.levelId.equals(l.id))).getSingleOrNull();

      if (seen == null) {
        await db.into(db.puzzleProgress).insertOnConflictUpdate(PuzzleProgressCompanion.insert(
              levelId: Value(l.id),
              completed: const Value(true),
              bestSeconds: Value(prior?.bestSeconds == null || seconds < prior!.bestSeconds! ? seconds : prior.bestSeconds),
              hintsUsed: Value(hints),
              completionDate: Value(_clock()),
              bestStars: Value(stars > (prior?.bestStars ?? 0) ? stars : prior!.bestStars),
              playCount: Value((prior?.playCount ?? 0) + 1),
            ));
        await db.into(db.playHistory).insert(PlayHistoryCompanion.insert(puzzleKey: setup.key, levelId: l.id, seconds: seconds, stars: stars, at: _clock()));
      }

      final lines = <CoinLine>[];
      Future<void> add(String key, String type, String event, int amount, String label) async {
        if (await grant(key: key, type: type, eventId: event, amount: amount)) lines.add(CoinLine(label, amount));
      }

      await add(runKey, 'level', 'level:${l.id}', Scoring.levelCoins, 'Level complete');
      await add('level:${l.id}:first', 'first', 'level:${l.id}', Scoring.firstBonus, 'First completion');

      final count = await _completedCount();
      for (final m in Scoring.milestones.entries) {
        if (count >= m.key) await add('milestone:${m.key}', 'milestone', 'milestone:${m.key}', m.value, '${m.key}-level milestone');
      }

      final col = catalog.collectionOf(l);
      final done = await (db.selectOnly(db.puzzleProgress)
            ..addColumns([db.puzzleProgress.levelId.count()])
            ..where(db.puzzleProgress.completed.equals(true) & db.puzzleProgress.levelId.isBetweenValues(col.firstLevel, col.lastLevel)))
          .map((r) => r.read(db.puzzleProgress.levelId.count())!)
          .getSingle();
      String? completedCollection;
      if (done == col.lastLevel - col.firstLevel + 1) {
        final before = lines.length;
        await add('collection:${col.id}', 'collection', 'collection:${col.id}', Scoring.collectionCoins, 'Collection complete');
        if (lines.length > before) completedCollection = col.title;
      }

      await db.customUpdate(
        'UPDATE player_profiles SET total_completed_levels = ?, total_stars = (SELECT COALESCE(SUM(best_stars), 0) FROM puzzle_progress WHERE completed = 1) WHERE id = 1',
        variables: [Variable.withInt(count)],
        updates: {db.playerProfiles},
      );
      await clearActive(setup.key);
      final newly = await syncAchievements();
      return CompletionResult(
        setup: setup,
        seconds: seconds,
        stars: stars,
        lines: lines,
        newAchievements: newly,
        alreadyRecorded: seen != null,
        nextLevel: l.id < catalog.levels.length ? l.id + 1 : null,
        collectionCompleted: completedCollection,
      );
    });
  }

  Future<int> _completedCount() => (db.selectOnly(db.puzzleProgress)
        ..addColumns([db.puzzleProgress.levelId.count()])
        ..where(db.puzzleProgress.completed.equals(true)))
      .map((r) => r.read(db.puzzleProgress.levelId.count())!)
      .getSingle();

  // ---------- daily ----------

  String get todayKey => dateKey(_clock());
  PuzzleLevel dailyLevel(String date) => catalog.level(dailyLevelFor(date, catalog.levels.length));
  Stream<List<DailyRow>> watchDailies() => (db.select(db.dailyPuzzles)..orderBy([(t) => OrderingTerm.desc(t.date)])).watch();

  /// Only ever writes the daily tables and ledger; campaign unlocks are
  /// derived solely from [PuzzleProgress], so dailies can't advance them.
  /// Replaying a past date is practice and earns nothing.
  Future<CompletionResult> completeDaily(PuzzleSetup setup, {required int seconds, required int hints}) {
    final date = setup.date!;
    return db.transaction(() async {
      final lines = <CoinLine>[];
      final stars = Scoring.stars(hints);
      final isToday = date == todayKey;
      final prior = await (db.select(db.dailyPuzzles)..where((t) => t.date.equals(date))).getSingleOrNull();
      await db.into(db.playHistory).insert(PlayHistoryCompanion.insert(puzzleKey: setup.key, levelId: setup.level.id, isDaily: const Value(true), seconds: seconds, stars: stars, at: _clock()));
      if (isToday) {
        await db.into(db.dailyPuzzles).insertOnConflictUpdate(DailyPuzzlesCompanion.insert(
              date: date,
              levelId: setup.level.id,
              selectedDifficulty: setup.difficulty!.name,
              completed: const Value(true),
              rewardClaimed: const Value(true),
              bestSeconds: Value(prior?.bestSeconds == null || seconds < prior!.bestSeconds! ? seconds : prior.bestSeconds),
            ));
        if (await grant(key: 'daily:$date', type: 'daily', eventId: 'daily:$date', amount: Scoring.dailyCoins)) {
          lines.add(const CoinLine('Daily puzzle', Scoring.dailyCoins));
        }
        final streak = await currentStreak();
        if (streak > 0 && streak % Scoring.streakEvery == 0) {
          if (await grant(key: 'streak:$date', type: 'streak', eventId: 'streak:$streak', amount: Scoring.streakCoins)) {
            lines.add(CoinLine('$streak-day streak', Scoring.streakCoins));
          }
        }
      }
      await clearActive(setup.key);
      final newly = await syncAchievements();
      return CompletionResult(setup: setup, seconds: seconds, stars: stars, lines: lines, newAchievements: newly, alreadyRecorded: prior?.completed ?? false);
    });
  }

  Future<void> rememberDailyDifficulty(String date, int levelId, DailyDifficulty d) async {
    final prior = await (db.select(db.dailyPuzzles)..where((t) => t.date.equals(date))).getSingleOrNull();
    if (prior == null) {
      await db.into(db.dailyPuzzles).insert(DailyPuzzlesCompanion.insert(date: date, levelId: levelId, selectedDifficulty: d.name));
    } else if (!prior.completed) {
      await (db.update(db.dailyPuzzles)..where((t) => t.date.equals(date))).write(DailyPuzzlesCompanion(selectedDifficulty: Value(d.name)));
    }
  }

  Future<int> currentStreak() async {
    final rows = await (db.select(db.dailyPuzzles)..where((t) => t.completed.equals(true))).get();
    final dates = {for (final r in rows) r.date};
    final now = _clock();
    var cursor = DateTime(now.year, now.month, now.day);
    if (!dates.contains(dateKey(cursor))) cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
    var n = 0;
    while (dates.contains(dateKey(cursor))) {
      n++;
      cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
    }
    return n;
  }

  static int longestStreak(Iterable<String> dates) {
    final days = dates.map(parseDateKey).toList()..sort();
    var best = 0, run = 0;
    DateTime? prev;
    for (final d in days) {
      run = prev != null && DateTime(prev.year, prev.month, prev.day + 1) == d ? run + 1 : 1;
      if (run > best) best = run;
      prev = d;
    }
    return best;
  }

  // ---------- save and resume ----------

  Future<void> saveActive(PuzzleSetup setup, PuzzleSnapshot snap) => db.into(db.activePuzzles).insertOnConflictUpdate(ActivePuzzlesCompanion.insert(
        puzzleKey: setup.key,
        levelId: setup.level.id,
        imageId: setup.level.imageId,
        pieceCount: snap.pieceCount,
        randomSeed: snap.seed,
        placedCount: Value(snap.placed.length),
        stateJson: jsonEncode(snap.toJson()),
        updatedAt: _clock(),
      ));

  Future<PuzzleSnapshot?> loadActive(String key) async {
    final row = await (db.select(db.activePuzzles)..where((t) => t.puzzleKey.equals(key))).getSingleOrNull();
    if (row == null) return null;
    try {
      return PuzzleSnapshot.fromJson(jsonDecode(row.stateJson) as Map<String, dynamic>);
    } on FormatException {
      return null;
    }
  }

  Future<void> clearActive(String key) => (db.delete(db.activePuzzles)..where((t) => t.puzzleKey.equals(key))).go();
  Stream<List<ActivePuzzleRow>> watchActive() => (db.select(db.activePuzzles)..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])).watch();

  // ---------- favorites and history ----------

  Stream<Set<int>> watchFavorites() => db.select(db.puzzleFavorites).watch().map((r) => {for (final f in r) f.levelId});

  Future<void> setFavorite(int levelId, bool favorite) async {
    if (favorite) {
      await db.into(db.puzzleFavorites).insert(PuzzleFavoritesCompanion.insert(levelId: Value(levelId)), mode: InsertMode.insertOrIgnore);
    } else {
      await (db.delete(db.puzzleFavorites)..where((t) => t.levelId.equals(levelId))).go();
    }
    await syncAchievements();
  }

  Stream<List<HistoryRow>> watchHistory({int limit = 200}) => (db.select(db.playHistory)..orderBy([(t) => OrderingTerm.desc(t.id)])..limit(limit)).watch();

  // ---------- achievements ----------

  Stream<Map<String, AchievementRow>> watchAchievements() => db.select(db.achievementStates).watch().map((r) => {for (final a in r) a.achievementId: a});

  Future<PlayerStats> stats() async {
    final profile = await (db.select(db.playerProfiles)..where((t) => t.id.equals(1))).getSingle();
    final progress = await (db.select(db.puzzleProgress)..where((t) => t.completed.equals(true))).get();
    final dailies = await (db.select(db.dailyPuzzles)..where((t) => t.completed.equals(true))).get();
    final favs = await db.select(db.puzzleFavorites).get();
    final hist = await db.select(db.playHistory).get();
    return PlayerStats(
      levels: progress.length,
      stars: progress.fold(0, (a, p) => a + p.bestStars),
      coins: profile.totalCoins,
      dailies: dailies.length,
      bestStreak: longestStreak(dailies.map((d) => d.date)),
      currentStreak: await currentStreak(),
      favorites: favs.length,
      perfect: progress.where((p) => p.bestStars == 3).length,
      totalSeconds: hist.fold(0, (a, h) => a + h.seconds),
    );
  }

  /// Recalculates progress from real records; returns those newly completed.
  Future<List<AchievementDef>> syncAchievements() async {
    final s = await stats();
    int metric(String m) => switch (m) { 'levels' => s.levels, 'dailies' => s.dailies, 'streak' => s.bestStreak, 'favorites' => s.favorites, 'perfect' => s.perfect, _ => 0 };
    final existing = {for (final a in await db.select(db.achievementStates).get()) a.achievementId: a};
    final newly = <AchievementDef>[];
    for (final def in achievementDefs) {
      final prev = existing[def.id];
      final value = metric(def.metric).clamp(0, def.target);
      final progress = value > (prev?.progress ?? 0) ? value : (prev?.progress ?? 0);
      final done = progress >= def.target;
      if (done && !(prev?.completed ?? false)) newly.add(def);
      await db.into(db.achievementStates).insertOnConflictUpdate(AchievementStatesCompanion.insert(
            achievementId: def.id,
            progress: Value(progress),
            completed: Value(done),
            claimed: Value(prev?.claimed ?? false),
          ));
    }
    return newly;
  }

  Future<bool> claimAchievement(AchievementDef def) => db.transaction(() async {
        final row = await (db.select(db.achievementStates)..where((t) => t.achievementId.equals(def.id))).getSingleOrNull();
        if (row == null || !row.completed) return false;
        final ok = await grant(key: 'achievement:${def.id}', type: 'achievement', eventId: def.id, amount: def.reward);
        await (db.update(db.achievementStates)..where((t) => t.achievementId.equals(def.id))).write(const AchievementStatesCompanion(claimed: Value(true)));
        return ok;
      });
}
