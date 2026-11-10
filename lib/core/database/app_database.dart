import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

@DataClassName('PlayerProfileRow')
class PlayerProfiles extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get playerName => text().withDefault(const Constant('Puzzler'))();
  IntColumn get totalCoins => integer().withDefault(const Constant(0))();
  IntColumn get totalCompletedLevels => integer().withDefault(const Constant(0))();
  IntColumn get totalStars => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ProgressRow')
class PuzzleProgress extends Table {
  IntColumn get levelId => integer()();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  IntColumn get bestSeconds => integer().nullable()();
  IntColumn get hintsUsed => integer().withDefault(const Constant(0))();
  DateTimeColumn get completionDate => dateTime().nullable()();
  IntColumn get bestStars => integer().withDefault(const Constant(0))();
  IntColumn get playCount => integer().withDefault(const Constant(0))();
  @override
  Set<Column> get primaryKey => {levelId};
}

@DataClassName('ActivePuzzleRow')
class ActivePuzzles extends Table {
  TextColumn get puzzleKey => text()();
  IntColumn get levelId => integer()();
  TextColumn get imageId => text()();
  IntColumn get pieceCount => integer()();
  IntColumn get randomSeed => integer()();
  IntColumn get placedCount => integer().withDefault(const Constant(0))();
  TextColumn get stateJson => text()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {puzzleKey};
}

@DataClassName('FavoriteRow')
class PuzzleFavorites extends Table {
  IntColumn get levelId => integer()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  @override
  Set<Column> get primaryKey => {levelId};
}

@DataClassName('DailyRow')
class DailyPuzzles extends Table {
  TextColumn get date => text()();
  IntColumn get levelId => integer()();
  TextColumn get selectedDifficulty => text()();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  BoolColumn get rewardClaimed => boolean().withDefault(const Constant(false))();
  IntColumn get bestSeconds => integer().nullable()();
  @override
  Set<Column> get primaryKey => {date};
}

@DataClassName('AchievementRow')
class AchievementStates extends Table {
  TextColumn get achievementId => text()();
  IntColumn get progress => integer().withDefault(const Constant(0))();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  BoolColumn get claimed => boolean().withDefault(const Constant(false))();
  @override
  Set<Column> get primaryKey => {achievementId};
}

@DataClassName('RewardRow')
class RewardTransactions extends Table {
  IntColumn get transactionId => integer().autoIncrement()();
  TextColumn get eventId => text()();
  TextColumn get rewardType => text()();
  TextColumn get currency => text().withDefault(const Constant('coins'))();
  // ignore: recursive_getters
  IntColumn get amount => integer().check(amount.isBiggerThanValue(0))();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get idempotencyKey => text().unique()();
}

@DataClassName('HistoryRow')
class PlayHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get puzzleKey => text()();
  IntColumn get levelId => integer()();
  BoolColumn get isDaily => boolean().withDefault(const Constant(false))();
  IntColumn get seconds => integer()();
  IntColumn get stars => integer()();
  DateTimeColumn get at => dateTime()();
}

@DriftDatabase(tables: [PlayerProfiles, PuzzleProgress, ActivePuzzles, PuzzleFavorites, DailyPuzzles, AchievementStates, RewardTransactions, PlayHistory])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? driftDatabase(name: 'easter_jigsaw'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        // New schema versions add their steps here, keyed on `from`.
        onUpgrade: (m, from, to) async {},
        beforeOpen: (details) async {
          // The id must be explicit: an empty insert would take the next rowid and
          // add another row on every launch.
          await into(playerProfiles).insert(PlayerProfilesCompanion.insert(id: const Value(1)), mode: InsertMode.insertOrIgnore);
        },
      );
}
