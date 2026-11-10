// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PlayerProfilesTable extends PlayerProfiles
    with TableInfo<$PlayerProfilesTable, PlayerProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlayerProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _playerNameMeta = const VerificationMeta(
    'playerName',
  );
  @override
  late final GeneratedColumn<String> playerName = GeneratedColumn<String>(
    'player_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Puzzler'),
  );
  static const VerificationMeta _totalCoinsMeta = const VerificationMeta(
    'totalCoins',
  );
  @override
  late final GeneratedColumn<int> totalCoins = GeneratedColumn<int>(
    'total_coins',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalCompletedLevelsMeta =
      const VerificationMeta('totalCompletedLevels');
  @override
  late final GeneratedColumn<int> totalCompletedLevels = GeneratedColumn<int>(
    'total_completed_levels',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalStarsMeta = const VerificationMeta(
    'totalStars',
  );
  @override
  late final GeneratedColumn<int> totalStars = GeneratedColumn<int>(
    'total_stars',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    playerName,
    totalCoins,
    totalCompletedLevels,
    totalStars,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'player_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlayerProfileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('player_name')) {
      context.handle(
        _playerNameMeta,
        playerName.isAcceptableOrUnknown(data['player_name']!, _playerNameMeta),
      );
    }
    if (data.containsKey('total_coins')) {
      context.handle(
        _totalCoinsMeta,
        totalCoins.isAcceptableOrUnknown(data['total_coins']!, _totalCoinsMeta),
      );
    }
    if (data.containsKey('total_completed_levels')) {
      context.handle(
        _totalCompletedLevelsMeta,
        totalCompletedLevels.isAcceptableOrUnknown(
          data['total_completed_levels']!,
          _totalCompletedLevelsMeta,
        ),
      );
    }
    if (data.containsKey('total_stars')) {
      context.handle(
        _totalStarsMeta,
        totalStars.isAcceptableOrUnknown(data['total_stars']!, _totalStarsMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlayerProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlayerProfileRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      playerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}player_name'],
      )!,
      totalCoins: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_coins'],
      )!,
      totalCompletedLevels: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_completed_levels'],
      )!,
      totalStars: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_stars'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PlayerProfilesTable createAlias(String alias) {
    return $PlayerProfilesTable(attachedDatabase, alias);
  }
}

class PlayerProfileRow extends DataClass
    implements Insertable<PlayerProfileRow> {
  final int id;
  final String playerName;
  final int totalCoins;
  final int totalCompletedLevels;
  final int totalStars;
  final DateTime createdAt;
  const PlayerProfileRow({
    required this.id,
    required this.playerName,
    required this.totalCoins,
    required this.totalCompletedLevels,
    required this.totalStars,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['player_name'] = Variable<String>(playerName);
    map['total_coins'] = Variable<int>(totalCoins);
    map['total_completed_levels'] = Variable<int>(totalCompletedLevels);
    map['total_stars'] = Variable<int>(totalStars);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PlayerProfilesCompanion toCompanion(bool nullToAbsent) {
    return PlayerProfilesCompanion(
      id: Value(id),
      playerName: Value(playerName),
      totalCoins: Value(totalCoins),
      totalCompletedLevels: Value(totalCompletedLevels),
      totalStars: Value(totalStars),
      createdAt: Value(createdAt),
    );
  }

  factory PlayerProfileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlayerProfileRow(
      id: serializer.fromJson<int>(json['id']),
      playerName: serializer.fromJson<String>(json['playerName']),
      totalCoins: serializer.fromJson<int>(json['totalCoins']),
      totalCompletedLevels: serializer.fromJson<int>(
        json['totalCompletedLevels'],
      ),
      totalStars: serializer.fromJson<int>(json['totalStars']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'playerName': serializer.toJson<String>(playerName),
      'totalCoins': serializer.toJson<int>(totalCoins),
      'totalCompletedLevels': serializer.toJson<int>(totalCompletedLevels),
      'totalStars': serializer.toJson<int>(totalStars),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PlayerProfileRow copyWith({
    int? id,
    String? playerName,
    int? totalCoins,
    int? totalCompletedLevels,
    int? totalStars,
    DateTime? createdAt,
  }) => PlayerProfileRow(
    id: id ?? this.id,
    playerName: playerName ?? this.playerName,
    totalCoins: totalCoins ?? this.totalCoins,
    totalCompletedLevels: totalCompletedLevels ?? this.totalCompletedLevels,
    totalStars: totalStars ?? this.totalStars,
    createdAt: createdAt ?? this.createdAt,
  );
  PlayerProfileRow copyWithCompanion(PlayerProfilesCompanion data) {
    return PlayerProfileRow(
      id: data.id.present ? data.id.value : this.id,
      playerName: data.playerName.present
          ? data.playerName.value
          : this.playerName,
      totalCoins: data.totalCoins.present
          ? data.totalCoins.value
          : this.totalCoins,
      totalCompletedLevels: data.totalCompletedLevels.present
          ? data.totalCompletedLevels.value
          : this.totalCompletedLevels,
      totalStars: data.totalStars.present
          ? data.totalStars.value
          : this.totalStars,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlayerProfileRow(')
          ..write('id: $id, ')
          ..write('playerName: $playerName, ')
          ..write('totalCoins: $totalCoins, ')
          ..write('totalCompletedLevels: $totalCompletedLevels, ')
          ..write('totalStars: $totalStars, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    playerName,
    totalCoins,
    totalCompletedLevels,
    totalStars,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlayerProfileRow &&
          other.id == this.id &&
          other.playerName == this.playerName &&
          other.totalCoins == this.totalCoins &&
          other.totalCompletedLevels == this.totalCompletedLevels &&
          other.totalStars == this.totalStars &&
          other.createdAt == this.createdAt);
}

class PlayerProfilesCompanion extends UpdateCompanion<PlayerProfileRow> {
  final Value<int> id;
  final Value<String> playerName;
  final Value<int> totalCoins;
  final Value<int> totalCompletedLevels;
  final Value<int> totalStars;
  final Value<DateTime> createdAt;
  const PlayerProfilesCompanion({
    this.id = const Value.absent(),
    this.playerName = const Value.absent(),
    this.totalCoins = const Value.absent(),
    this.totalCompletedLevels = const Value.absent(),
    this.totalStars = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PlayerProfilesCompanion.insert({
    this.id = const Value.absent(),
    this.playerName = const Value.absent(),
    this.totalCoins = const Value.absent(),
    this.totalCompletedLevels = const Value.absent(),
    this.totalStars = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  static Insertable<PlayerProfileRow> custom({
    Expression<int>? id,
    Expression<String>? playerName,
    Expression<int>? totalCoins,
    Expression<int>? totalCompletedLevels,
    Expression<int>? totalStars,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (playerName != null) 'player_name': playerName,
      if (totalCoins != null) 'total_coins': totalCoins,
      if (totalCompletedLevels != null)
        'total_completed_levels': totalCompletedLevels,
      if (totalStars != null) 'total_stars': totalStars,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PlayerProfilesCompanion copyWith({
    Value<int>? id,
    Value<String>? playerName,
    Value<int>? totalCoins,
    Value<int>? totalCompletedLevels,
    Value<int>? totalStars,
    Value<DateTime>? createdAt,
  }) {
    return PlayerProfilesCompanion(
      id: id ?? this.id,
      playerName: playerName ?? this.playerName,
      totalCoins: totalCoins ?? this.totalCoins,
      totalCompletedLevels: totalCompletedLevels ?? this.totalCompletedLevels,
      totalStars: totalStars ?? this.totalStars,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (playerName.present) {
      map['player_name'] = Variable<String>(playerName.value);
    }
    if (totalCoins.present) {
      map['total_coins'] = Variable<int>(totalCoins.value);
    }
    if (totalCompletedLevels.present) {
      map['total_completed_levels'] = Variable<int>(totalCompletedLevels.value);
    }
    if (totalStars.present) {
      map['total_stars'] = Variable<int>(totalStars.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlayerProfilesCompanion(')
          ..write('id: $id, ')
          ..write('playerName: $playerName, ')
          ..write('totalCoins: $totalCoins, ')
          ..write('totalCompletedLevels: $totalCompletedLevels, ')
          ..write('totalStars: $totalStars, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $PuzzleProgressTable extends PuzzleProgress
    with TableInfo<$PuzzleProgressTable, ProgressRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PuzzleProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _levelIdMeta = const VerificationMeta(
    'levelId',
  );
  @override
  late final GeneratedColumn<int> levelId = GeneratedColumn<int>(
    'level_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedMeta = const VerificationMeta(
    'completed',
  );
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
    'completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _bestSecondsMeta = const VerificationMeta(
    'bestSeconds',
  );
  @override
  late final GeneratedColumn<int> bestSeconds = GeneratedColumn<int>(
    'best_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hintsUsedMeta = const VerificationMeta(
    'hintsUsed',
  );
  @override
  late final GeneratedColumn<int> hintsUsed = GeneratedColumn<int>(
    'hints_used',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _completionDateMeta = const VerificationMeta(
    'completionDate',
  );
  @override
  late final GeneratedColumn<DateTime> completionDate =
      GeneratedColumn<DateTime>(
        'completion_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _bestStarsMeta = const VerificationMeta(
    'bestStars',
  );
  @override
  late final GeneratedColumn<int> bestStars = GeneratedColumn<int>(
    'best_stars',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _playCountMeta = const VerificationMeta(
    'playCount',
  );
  @override
  late final GeneratedColumn<int> playCount = GeneratedColumn<int>(
    'play_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    levelId,
    completed,
    bestSeconds,
    hintsUsed,
    completionDate,
    bestStars,
    playCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'puzzle_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProgressRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('level_id')) {
      context.handle(
        _levelIdMeta,
        levelId.isAcceptableOrUnknown(data['level_id']!, _levelIdMeta),
      );
    }
    if (data.containsKey('completed')) {
      context.handle(
        _completedMeta,
        completed.isAcceptableOrUnknown(data['completed']!, _completedMeta),
      );
    }
    if (data.containsKey('best_seconds')) {
      context.handle(
        _bestSecondsMeta,
        bestSeconds.isAcceptableOrUnknown(
          data['best_seconds']!,
          _bestSecondsMeta,
        ),
      );
    }
    if (data.containsKey('hints_used')) {
      context.handle(
        _hintsUsedMeta,
        hintsUsed.isAcceptableOrUnknown(data['hints_used']!, _hintsUsedMeta),
      );
    }
    if (data.containsKey('completion_date')) {
      context.handle(
        _completionDateMeta,
        completionDate.isAcceptableOrUnknown(
          data['completion_date']!,
          _completionDateMeta,
        ),
      );
    }
    if (data.containsKey('best_stars')) {
      context.handle(
        _bestStarsMeta,
        bestStars.isAcceptableOrUnknown(data['best_stars']!, _bestStarsMeta),
      );
    }
    if (data.containsKey('play_count')) {
      context.handle(
        _playCountMeta,
        playCount.isAcceptableOrUnknown(data['play_count']!, _playCountMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {levelId};
  @override
  ProgressRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProgressRow(
      levelId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level_id'],
      )!,
      completed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completed'],
      )!,
      bestSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}best_seconds'],
      ),
      hintsUsed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hints_used'],
      )!,
      completionDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completion_date'],
      ),
      bestStars: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}best_stars'],
      )!,
      playCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}play_count'],
      )!,
    );
  }

  @override
  $PuzzleProgressTable createAlias(String alias) {
    return $PuzzleProgressTable(attachedDatabase, alias);
  }
}

class ProgressRow extends DataClass implements Insertable<ProgressRow> {
  final int levelId;
  final bool completed;
  final int? bestSeconds;
  final int hintsUsed;
  final DateTime? completionDate;
  final int bestStars;
  final int playCount;
  const ProgressRow({
    required this.levelId,
    required this.completed,
    this.bestSeconds,
    required this.hintsUsed,
    this.completionDate,
    required this.bestStars,
    required this.playCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['level_id'] = Variable<int>(levelId);
    map['completed'] = Variable<bool>(completed);
    if (!nullToAbsent || bestSeconds != null) {
      map['best_seconds'] = Variable<int>(bestSeconds);
    }
    map['hints_used'] = Variable<int>(hintsUsed);
    if (!nullToAbsent || completionDate != null) {
      map['completion_date'] = Variable<DateTime>(completionDate);
    }
    map['best_stars'] = Variable<int>(bestStars);
    map['play_count'] = Variable<int>(playCount);
    return map;
  }

  PuzzleProgressCompanion toCompanion(bool nullToAbsent) {
    return PuzzleProgressCompanion(
      levelId: Value(levelId),
      completed: Value(completed),
      bestSeconds: bestSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(bestSeconds),
      hintsUsed: Value(hintsUsed),
      completionDate: completionDate == null && nullToAbsent
          ? const Value.absent()
          : Value(completionDate),
      bestStars: Value(bestStars),
      playCount: Value(playCount),
    );
  }

  factory ProgressRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProgressRow(
      levelId: serializer.fromJson<int>(json['levelId']),
      completed: serializer.fromJson<bool>(json['completed']),
      bestSeconds: serializer.fromJson<int?>(json['bestSeconds']),
      hintsUsed: serializer.fromJson<int>(json['hintsUsed']),
      completionDate: serializer.fromJson<DateTime?>(json['completionDate']),
      bestStars: serializer.fromJson<int>(json['bestStars']),
      playCount: serializer.fromJson<int>(json['playCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'levelId': serializer.toJson<int>(levelId),
      'completed': serializer.toJson<bool>(completed),
      'bestSeconds': serializer.toJson<int?>(bestSeconds),
      'hintsUsed': serializer.toJson<int>(hintsUsed),
      'completionDate': serializer.toJson<DateTime?>(completionDate),
      'bestStars': serializer.toJson<int>(bestStars),
      'playCount': serializer.toJson<int>(playCount),
    };
  }

  ProgressRow copyWith({
    int? levelId,
    bool? completed,
    Value<int?> bestSeconds = const Value.absent(),
    int? hintsUsed,
    Value<DateTime?> completionDate = const Value.absent(),
    int? bestStars,
    int? playCount,
  }) => ProgressRow(
    levelId: levelId ?? this.levelId,
    completed: completed ?? this.completed,
    bestSeconds: bestSeconds.present ? bestSeconds.value : this.bestSeconds,
    hintsUsed: hintsUsed ?? this.hintsUsed,
    completionDate: completionDate.present
        ? completionDate.value
        : this.completionDate,
    bestStars: bestStars ?? this.bestStars,
    playCount: playCount ?? this.playCount,
  );
  ProgressRow copyWithCompanion(PuzzleProgressCompanion data) {
    return ProgressRow(
      levelId: data.levelId.present ? data.levelId.value : this.levelId,
      completed: data.completed.present ? data.completed.value : this.completed,
      bestSeconds: data.bestSeconds.present
          ? data.bestSeconds.value
          : this.bestSeconds,
      hintsUsed: data.hintsUsed.present ? data.hintsUsed.value : this.hintsUsed,
      completionDate: data.completionDate.present
          ? data.completionDate.value
          : this.completionDate,
      bestStars: data.bestStars.present ? data.bestStars.value : this.bestStars,
      playCount: data.playCount.present ? data.playCount.value : this.playCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProgressRow(')
          ..write('levelId: $levelId, ')
          ..write('completed: $completed, ')
          ..write('bestSeconds: $bestSeconds, ')
          ..write('hintsUsed: $hintsUsed, ')
          ..write('completionDate: $completionDate, ')
          ..write('bestStars: $bestStars, ')
          ..write('playCount: $playCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    levelId,
    completed,
    bestSeconds,
    hintsUsed,
    completionDate,
    bestStars,
    playCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProgressRow &&
          other.levelId == this.levelId &&
          other.completed == this.completed &&
          other.bestSeconds == this.bestSeconds &&
          other.hintsUsed == this.hintsUsed &&
          other.completionDate == this.completionDate &&
          other.bestStars == this.bestStars &&
          other.playCount == this.playCount);
}

class PuzzleProgressCompanion extends UpdateCompanion<ProgressRow> {
  final Value<int> levelId;
  final Value<bool> completed;
  final Value<int?> bestSeconds;
  final Value<int> hintsUsed;
  final Value<DateTime?> completionDate;
  final Value<int> bestStars;
  final Value<int> playCount;
  const PuzzleProgressCompanion({
    this.levelId = const Value.absent(),
    this.completed = const Value.absent(),
    this.bestSeconds = const Value.absent(),
    this.hintsUsed = const Value.absent(),
    this.completionDate = const Value.absent(),
    this.bestStars = const Value.absent(),
    this.playCount = const Value.absent(),
  });
  PuzzleProgressCompanion.insert({
    this.levelId = const Value.absent(),
    this.completed = const Value.absent(),
    this.bestSeconds = const Value.absent(),
    this.hintsUsed = const Value.absent(),
    this.completionDate = const Value.absent(),
    this.bestStars = const Value.absent(),
    this.playCount = const Value.absent(),
  });
  static Insertable<ProgressRow> custom({
    Expression<int>? levelId,
    Expression<bool>? completed,
    Expression<int>? bestSeconds,
    Expression<int>? hintsUsed,
    Expression<DateTime>? completionDate,
    Expression<int>? bestStars,
    Expression<int>? playCount,
  }) {
    return RawValuesInsertable({
      if (levelId != null) 'level_id': levelId,
      if (completed != null) 'completed': completed,
      if (bestSeconds != null) 'best_seconds': bestSeconds,
      if (hintsUsed != null) 'hints_used': hintsUsed,
      if (completionDate != null) 'completion_date': completionDate,
      if (bestStars != null) 'best_stars': bestStars,
      if (playCount != null) 'play_count': playCount,
    });
  }

  PuzzleProgressCompanion copyWith({
    Value<int>? levelId,
    Value<bool>? completed,
    Value<int?>? bestSeconds,
    Value<int>? hintsUsed,
    Value<DateTime?>? completionDate,
    Value<int>? bestStars,
    Value<int>? playCount,
  }) {
    return PuzzleProgressCompanion(
      levelId: levelId ?? this.levelId,
      completed: completed ?? this.completed,
      bestSeconds: bestSeconds ?? this.bestSeconds,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      completionDate: completionDate ?? this.completionDate,
      bestStars: bestStars ?? this.bestStars,
      playCount: playCount ?? this.playCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (levelId.present) {
      map['level_id'] = Variable<int>(levelId.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (bestSeconds.present) {
      map['best_seconds'] = Variable<int>(bestSeconds.value);
    }
    if (hintsUsed.present) {
      map['hints_used'] = Variable<int>(hintsUsed.value);
    }
    if (completionDate.present) {
      map['completion_date'] = Variable<DateTime>(completionDate.value);
    }
    if (bestStars.present) {
      map['best_stars'] = Variable<int>(bestStars.value);
    }
    if (playCount.present) {
      map['play_count'] = Variable<int>(playCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PuzzleProgressCompanion(')
          ..write('levelId: $levelId, ')
          ..write('completed: $completed, ')
          ..write('bestSeconds: $bestSeconds, ')
          ..write('hintsUsed: $hintsUsed, ')
          ..write('completionDate: $completionDate, ')
          ..write('bestStars: $bestStars, ')
          ..write('playCount: $playCount')
          ..write(')'))
        .toString();
  }
}

class $ActivePuzzlesTable extends ActivePuzzles
    with TableInfo<$ActivePuzzlesTable, ActivePuzzleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivePuzzlesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _puzzleKeyMeta = const VerificationMeta(
    'puzzleKey',
  );
  @override
  late final GeneratedColumn<String> puzzleKey = GeneratedColumn<String>(
    'puzzle_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _levelIdMeta = const VerificationMeta(
    'levelId',
  );
  @override
  late final GeneratedColumn<int> levelId = GeneratedColumn<int>(
    'level_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imageIdMeta = const VerificationMeta(
    'imageId',
  );
  @override
  late final GeneratedColumn<String> imageId = GeneratedColumn<String>(
    'image_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pieceCountMeta = const VerificationMeta(
    'pieceCount',
  );
  @override
  late final GeneratedColumn<int> pieceCount = GeneratedColumn<int>(
    'piece_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _randomSeedMeta = const VerificationMeta(
    'randomSeed',
  );
  @override
  late final GeneratedColumn<int> randomSeed = GeneratedColumn<int>(
    'random_seed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _placedCountMeta = const VerificationMeta(
    'placedCount',
  );
  @override
  late final GeneratedColumn<int> placedCount = GeneratedColumn<int>(
    'placed_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _stateJsonMeta = const VerificationMeta(
    'stateJson',
  );
  @override
  late final GeneratedColumn<String> stateJson = GeneratedColumn<String>(
    'state_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    puzzleKey,
    levelId,
    imageId,
    pieceCount,
    randomSeed,
    placedCount,
    stateJson,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'active_puzzles';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActivePuzzleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('puzzle_key')) {
      context.handle(
        _puzzleKeyMeta,
        puzzleKey.isAcceptableOrUnknown(data['puzzle_key']!, _puzzleKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_puzzleKeyMeta);
    }
    if (data.containsKey('level_id')) {
      context.handle(
        _levelIdMeta,
        levelId.isAcceptableOrUnknown(data['level_id']!, _levelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_levelIdMeta);
    }
    if (data.containsKey('image_id')) {
      context.handle(
        _imageIdMeta,
        imageId.isAcceptableOrUnknown(data['image_id']!, _imageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_imageIdMeta);
    }
    if (data.containsKey('piece_count')) {
      context.handle(
        _pieceCountMeta,
        pieceCount.isAcceptableOrUnknown(data['piece_count']!, _pieceCountMeta),
      );
    } else if (isInserting) {
      context.missing(_pieceCountMeta);
    }
    if (data.containsKey('random_seed')) {
      context.handle(
        _randomSeedMeta,
        randomSeed.isAcceptableOrUnknown(data['random_seed']!, _randomSeedMeta),
      );
    } else if (isInserting) {
      context.missing(_randomSeedMeta);
    }
    if (data.containsKey('placed_count')) {
      context.handle(
        _placedCountMeta,
        placedCount.isAcceptableOrUnknown(
          data['placed_count']!,
          _placedCountMeta,
        ),
      );
    }
    if (data.containsKey('state_json')) {
      context.handle(
        _stateJsonMeta,
        stateJson.isAcceptableOrUnknown(data['state_json']!, _stateJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_stateJsonMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {puzzleKey};
  @override
  ActivePuzzleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActivePuzzleRow(
      puzzleKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}puzzle_key'],
      )!,
      levelId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level_id'],
      )!,
      imageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_id'],
      )!,
      pieceCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}piece_count'],
      )!,
      randomSeed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}random_seed'],
      )!,
      placedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}placed_count'],
      )!,
      stateJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state_json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ActivePuzzlesTable createAlias(String alias) {
    return $ActivePuzzlesTable(attachedDatabase, alias);
  }
}

class ActivePuzzleRow extends DataClass implements Insertable<ActivePuzzleRow> {
  final String puzzleKey;
  final int levelId;
  final String imageId;
  final int pieceCount;
  final int randomSeed;
  final int placedCount;
  final String stateJson;
  final DateTime updatedAt;
  const ActivePuzzleRow({
    required this.puzzleKey,
    required this.levelId,
    required this.imageId,
    required this.pieceCount,
    required this.randomSeed,
    required this.placedCount,
    required this.stateJson,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['puzzle_key'] = Variable<String>(puzzleKey);
    map['level_id'] = Variable<int>(levelId);
    map['image_id'] = Variable<String>(imageId);
    map['piece_count'] = Variable<int>(pieceCount);
    map['random_seed'] = Variable<int>(randomSeed);
    map['placed_count'] = Variable<int>(placedCount);
    map['state_json'] = Variable<String>(stateJson);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ActivePuzzlesCompanion toCompanion(bool nullToAbsent) {
    return ActivePuzzlesCompanion(
      puzzleKey: Value(puzzleKey),
      levelId: Value(levelId),
      imageId: Value(imageId),
      pieceCount: Value(pieceCount),
      randomSeed: Value(randomSeed),
      placedCount: Value(placedCount),
      stateJson: Value(stateJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory ActivePuzzleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActivePuzzleRow(
      puzzleKey: serializer.fromJson<String>(json['puzzleKey']),
      levelId: serializer.fromJson<int>(json['levelId']),
      imageId: serializer.fromJson<String>(json['imageId']),
      pieceCount: serializer.fromJson<int>(json['pieceCount']),
      randomSeed: serializer.fromJson<int>(json['randomSeed']),
      placedCount: serializer.fromJson<int>(json['placedCount']),
      stateJson: serializer.fromJson<String>(json['stateJson']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'puzzleKey': serializer.toJson<String>(puzzleKey),
      'levelId': serializer.toJson<int>(levelId),
      'imageId': serializer.toJson<String>(imageId),
      'pieceCount': serializer.toJson<int>(pieceCount),
      'randomSeed': serializer.toJson<int>(randomSeed),
      'placedCount': serializer.toJson<int>(placedCount),
      'stateJson': serializer.toJson<String>(stateJson),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ActivePuzzleRow copyWith({
    String? puzzleKey,
    int? levelId,
    String? imageId,
    int? pieceCount,
    int? randomSeed,
    int? placedCount,
    String? stateJson,
    DateTime? updatedAt,
  }) => ActivePuzzleRow(
    puzzleKey: puzzleKey ?? this.puzzleKey,
    levelId: levelId ?? this.levelId,
    imageId: imageId ?? this.imageId,
    pieceCount: pieceCount ?? this.pieceCount,
    randomSeed: randomSeed ?? this.randomSeed,
    placedCount: placedCount ?? this.placedCount,
    stateJson: stateJson ?? this.stateJson,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ActivePuzzleRow copyWithCompanion(ActivePuzzlesCompanion data) {
    return ActivePuzzleRow(
      puzzleKey: data.puzzleKey.present ? data.puzzleKey.value : this.puzzleKey,
      levelId: data.levelId.present ? data.levelId.value : this.levelId,
      imageId: data.imageId.present ? data.imageId.value : this.imageId,
      pieceCount: data.pieceCount.present
          ? data.pieceCount.value
          : this.pieceCount,
      randomSeed: data.randomSeed.present
          ? data.randomSeed.value
          : this.randomSeed,
      placedCount: data.placedCount.present
          ? data.placedCount.value
          : this.placedCount,
      stateJson: data.stateJson.present ? data.stateJson.value : this.stateJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActivePuzzleRow(')
          ..write('puzzleKey: $puzzleKey, ')
          ..write('levelId: $levelId, ')
          ..write('imageId: $imageId, ')
          ..write('pieceCount: $pieceCount, ')
          ..write('randomSeed: $randomSeed, ')
          ..write('placedCount: $placedCount, ')
          ..write('stateJson: $stateJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    puzzleKey,
    levelId,
    imageId,
    pieceCount,
    randomSeed,
    placedCount,
    stateJson,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivePuzzleRow &&
          other.puzzleKey == this.puzzleKey &&
          other.levelId == this.levelId &&
          other.imageId == this.imageId &&
          other.pieceCount == this.pieceCount &&
          other.randomSeed == this.randomSeed &&
          other.placedCount == this.placedCount &&
          other.stateJson == this.stateJson &&
          other.updatedAt == this.updatedAt);
}

class ActivePuzzlesCompanion extends UpdateCompanion<ActivePuzzleRow> {
  final Value<String> puzzleKey;
  final Value<int> levelId;
  final Value<String> imageId;
  final Value<int> pieceCount;
  final Value<int> randomSeed;
  final Value<int> placedCount;
  final Value<String> stateJson;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ActivePuzzlesCompanion({
    this.puzzleKey = const Value.absent(),
    this.levelId = const Value.absent(),
    this.imageId = const Value.absent(),
    this.pieceCount = const Value.absent(),
    this.randomSeed = const Value.absent(),
    this.placedCount = const Value.absent(),
    this.stateJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActivePuzzlesCompanion.insert({
    required String puzzleKey,
    required int levelId,
    required String imageId,
    required int pieceCount,
    required int randomSeed,
    this.placedCount = const Value.absent(),
    required String stateJson,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : puzzleKey = Value(puzzleKey),
       levelId = Value(levelId),
       imageId = Value(imageId),
       pieceCount = Value(pieceCount),
       randomSeed = Value(randomSeed),
       stateJson = Value(stateJson),
       updatedAt = Value(updatedAt);
  static Insertable<ActivePuzzleRow> custom({
    Expression<String>? puzzleKey,
    Expression<int>? levelId,
    Expression<String>? imageId,
    Expression<int>? pieceCount,
    Expression<int>? randomSeed,
    Expression<int>? placedCount,
    Expression<String>? stateJson,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (puzzleKey != null) 'puzzle_key': puzzleKey,
      if (levelId != null) 'level_id': levelId,
      if (imageId != null) 'image_id': imageId,
      if (pieceCount != null) 'piece_count': pieceCount,
      if (randomSeed != null) 'random_seed': randomSeed,
      if (placedCount != null) 'placed_count': placedCount,
      if (stateJson != null) 'state_json': stateJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActivePuzzlesCompanion copyWith({
    Value<String>? puzzleKey,
    Value<int>? levelId,
    Value<String>? imageId,
    Value<int>? pieceCount,
    Value<int>? randomSeed,
    Value<int>? placedCount,
    Value<String>? stateJson,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ActivePuzzlesCompanion(
      puzzleKey: puzzleKey ?? this.puzzleKey,
      levelId: levelId ?? this.levelId,
      imageId: imageId ?? this.imageId,
      pieceCount: pieceCount ?? this.pieceCount,
      randomSeed: randomSeed ?? this.randomSeed,
      placedCount: placedCount ?? this.placedCount,
      stateJson: stateJson ?? this.stateJson,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (puzzleKey.present) {
      map['puzzle_key'] = Variable<String>(puzzleKey.value);
    }
    if (levelId.present) {
      map['level_id'] = Variable<int>(levelId.value);
    }
    if (imageId.present) {
      map['image_id'] = Variable<String>(imageId.value);
    }
    if (pieceCount.present) {
      map['piece_count'] = Variable<int>(pieceCount.value);
    }
    if (randomSeed.present) {
      map['random_seed'] = Variable<int>(randomSeed.value);
    }
    if (placedCount.present) {
      map['placed_count'] = Variable<int>(placedCount.value);
    }
    if (stateJson.present) {
      map['state_json'] = Variable<String>(stateJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivePuzzlesCompanion(')
          ..write('puzzleKey: $puzzleKey, ')
          ..write('levelId: $levelId, ')
          ..write('imageId: $imageId, ')
          ..write('pieceCount: $pieceCount, ')
          ..write('randomSeed: $randomSeed, ')
          ..write('placedCount: $placedCount, ')
          ..write('stateJson: $stateJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PuzzleFavoritesTable extends PuzzleFavorites
    with TableInfo<$PuzzleFavoritesTable, FavoriteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PuzzleFavoritesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _levelIdMeta = const VerificationMeta(
    'levelId',
  );
  @override
  late final GeneratedColumn<int> levelId = GeneratedColumn<int>(
    'level_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [levelId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'puzzle_favorites';
  @override
  VerificationContext validateIntegrity(
    Insertable<FavoriteRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('level_id')) {
      context.handle(
        _levelIdMeta,
        levelId.isAcceptableOrUnknown(data['level_id']!, _levelIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {levelId};
  @override
  FavoriteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FavoriteRow(
      levelId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PuzzleFavoritesTable createAlias(String alias) {
    return $PuzzleFavoritesTable(attachedDatabase, alias);
  }
}

class FavoriteRow extends DataClass implements Insertable<FavoriteRow> {
  final int levelId;
  final DateTime createdAt;
  const FavoriteRow({required this.levelId, required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['level_id'] = Variable<int>(levelId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PuzzleFavoritesCompanion toCompanion(bool nullToAbsent) {
    return PuzzleFavoritesCompanion(
      levelId: Value(levelId),
      createdAt: Value(createdAt),
    );
  }

  factory FavoriteRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FavoriteRow(
      levelId: serializer.fromJson<int>(json['levelId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'levelId': serializer.toJson<int>(levelId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  FavoriteRow copyWith({int? levelId, DateTime? createdAt}) => FavoriteRow(
    levelId: levelId ?? this.levelId,
    createdAt: createdAt ?? this.createdAt,
  );
  FavoriteRow copyWithCompanion(PuzzleFavoritesCompanion data) {
    return FavoriteRow(
      levelId: data.levelId.present ? data.levelId.value : this.levelId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteRow(')
          ..write('levelId: $levelId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(levelId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FavoriteRow &&
          other.levelId == this.levelId &&
          other.createdAt == this.createdAt);
}

class PuzzleFavoritesCompanion extends UpdateCompanion<FavoriteRow> {
  final Value<int> levelId;
  final Value<DateTime> createdAt;
  const PuzzleFavoritesCompanion({
    this.levelId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PuzzleFavoritesCompanion.insert({
    this.levelId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  static Insertable<FavoriteRow> custom({
    Expression<int>? levelId,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (levelId != null) 'level_id': levelId,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PuzzleFavoritesCompanion copyWith({
    Value<int>? levelId,
    Value<DateTime>? createdAt,
  }) {
    return PuzzleFavoritesCompanion(
      levelId: levelId ?? this.levelId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (levelId.present) {
      map['level_id'] = Variable<int>(levelId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PuzzleFavoritesCompanion(')
          ..write('levelId: $levelId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $DailyPuzzlesTable extends DailyPuzzles
    with TableInfo<$DailyPuzzlesTable, DailyRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyPuzzlesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _levelIdMeta = const VerificationMeta(
    'levelId',
  );
  @override
  late final GeneratedColumn<int> levelId = GeneratedColumn<int>(
    'level_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _selectedDifficultyMeta =
      const VerificationMeta('selectedDifficulty');
  @override
  late final GeneratedColumn<String> selectedDifficulty =
      GeneratedColumn<String>(
        'selected_difficulty',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _completedMeta = const VerificationMeta(
    'completed',
  );
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
    'completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _rewardClaimedMeta = const VerificationMeta(
    'rewardClaimed',
  );
  @override
  late final GeneratedColumn<bool> rewardClaimed = GeneratedColumn<bool>(
    'reward_claimed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("reward_claimed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _bestSecondsMeta = const VerificationMeta(
    'bestSeconds',
  );
  @override
  late final GeneratedColumn<int> bestSeconds = GeneratedColumn<int>(
    'best_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    date,
    levelId,
    selectedDifficulty,
    completed,
    rewardClaimed,
    bestSeconds,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_puzzles';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('level_id')) {
      context.handle(
        _levelIdMeta,
        levelId.isAcceptableOrUnknown(data['level_id']!, _levelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_levelIdMeta);
    }
    if (data.containsKey('selected_difficulty')) {
      context.handle(
        _selectedDifficultyMeta,
        selectedDifficulty.isAcceptableOrUnknown(
          data['selected_difficulty']!,
          _selectedDifficultyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_selectedDifficultyMeta);
    }
    if (data.containsKey('completed')) {
      context.handle(
        _completedMeta,
        completed.isAcceptableOrUnknown(data['completed']!, _completedMeta),
      );
    }
    if (data.containsKey('reward_claimed')) {
      context.handle(
        _rewardClaimedMeta,
        rewardClaimed.isAcceptableOrUnknown(
          data['reward_claimed']!,
          _rewardClaimedMeta,
        ),
      );
    }
    if (data.containsKey('best_seconds')) {
      context.handle(
        _bestSecondsMeta,
        bestSeconds.isAcceptableOrUnknown(
          data['best_seconds']!,
          _bestSecondsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {date};
  @override
  DailyRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyRow(
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      levelId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level_id'],
      )!,
      selectedDifficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}selected_difficulty'],
      )!,
      completed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completed'],
      )!,
      rewardClaimed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}reward_claimed'],
      )!,
      bestSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}best_seconds'],
      ),
    );
  }

  @override
  $DailyPuzzlesTable createAlias(String alias) {
    return $DailyPuzzlesTable(attachedDatabase, alias);
  }
}

class DailyRow extends DataClass implements Insertable<DailyRow> {
  final String date;
  final int levelId;
  final String selectedDifficulty;
  final bool completed;
  final bool rewardClaimed;
  final int? bestSeconds;
  const DailyRow({
    required this.date,
    required this.levelId,
    required this.selectedDifficulty,
    required this.completed,
    required this.rewardClaimed,
    this.bestSeconds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date'] = Variable<String>(date);
    map['level_id'] = Variable<int>(levelId);
    map['selected_difficulty'] = Variable<String>(selectedDifficulty);
    map['completed'] = Variable<bool>(completed);
    map['reward_claimed'] = Variable<bool>(rewardClaimed);
    if (!nullToAbsent || bestSeconds != null) {
      map['best_seconds'] = Variable<int>(bestSeconds);
    }
    return map;
  }

  DailyPuzzlesCompanion toCompanion(bool nullToAbsent) {
    return DailyPuzzlesCompanion(
      date: Value(date),
      levelId: Value(levelId),
      selectedDifficulty: Value(selectedDifficulty),
      completed: Value(completed),
      rewardClaimed: Value(rewardClaimed),
      bestSeconds: bestSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(bestSeconds),
    );
  }

  factory DailyRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyRow(
      date: serializer.fromJson<String>(json['date']),
      levelId: serializer.fromJson<int>(json['levelId']),
      selectedDifficulty: serializer.fromJson<String>(
        json['selectedDifficulty'],
      ),
      completed: serializer.fromJson<bool>(json['completed']),
      rewardClaimed: serializer.fromJson<bool>(json['rewardClaimed']),
      bestSeconds: serializer.fromJson<int?>(json['bestSeconds']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'date': serializer.toJson<String>(date),
      'levelId': serializer.toJson<int>(levelId),
      'selectedDifficulty': serializer.toJson<String>(selectedDifficulty),
      'completed': serializer.toJson<bool>(completed),
      'rewardClaimed': serializer.toJson<bool>(rewardClaimed),
      'bestSeconds': serializer.toJson<int?>(bestSeconds),
    };
  }

  DailyRow copyWith({
    String? date,
    int? levelId,
    String? selectedDifficulty,
    bool? completed,
    bool? rewardClaimed,
    Value<int?> bestSeconds = const Value.absent(),
  }) => DailyRow(
    date: date ?? this.date,
    levelId: levelId ?? this.levelId,
    selectedDifficulty: selectedDifficulty ?? this.selectedDifficulty,
    completed: completed ?? this.completed,
    rewardClaimed: rewardClaimed ?? this.rewardClaimed,
    bestSeconds: bestSeconds.present ? bestSeconds.value : this.bestSeconds,
  );
  DailyRow copyWithCompanion(DailyPuzzlesCompanion data) {
    return DailyRow(
      date: data.date.present ? data.date.value : this.date,
      levelId: data.levelId.present ? data.levelId.value : this.levelId,
      selectedDifficulty: data.selectedDifficulty.present
          ? data.selectedDifficulty.value
          : this.selectedDifficulty,
      completed: data.completed.present ? data.completed.value : this.completed,
      rewardClaimed: data.rewardClaimed.present
          ? data.rewardClaimed.value
          : this.rewardClaimed,
      bestSeconds: data.bestSeconds.present
          ? data.bestSeconds.value
          : this.bestSeconds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyRow(')
          ..write('date: $date, ')
          ..write('levelId: $levelId, ')
          ..write('selectedDifficulty: $selectedDifficulty, ')
          ..write('completed: $completed, ')
          ..write('rewardClaimed: $rewardClaimed, ')
          ..write('bestSeconds: $bestSeconds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    date,
    levelId,
    selectedDifficulty,
    completed,
    rewardClaimed,
    bestSeconds,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyRow &&
          other.date == this.date &&
          other.levelId == this.levelId &&
          other.selectedDifficulty == this.selectedDifficulty &&
          other.completed == this.completed &&
          other.rewardClaimed == this.rewardClaimed &&
          other.bestSeconds == this.bestSeconds);
}

class DailyPuzzlesCompanion extends UpdateCompanion<DailyRow> {
  final Value<String> date;
  final Value<int> levelId;
  final Value<String> selectedDifficulty;
  final Value<bool> completed;
  final Value<bool> rewardClaimed;
  final Value<int?> bestSeconds;
  final Value<int> rowid;
  const DailyPuzzlesCompanion({
    this.date = const Value.absent(),
    this.levelId = const Value.absent(),
    this.selectedDifficulty = const Value.absent(),
    this.completed = const Value.absent(),
    this.rewardClaimed = const Value.absent(),
    this.bestSeconds = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyPuzzlesCompanion.insert({
    required String date,
    required int levelId,
    required String selectedDifficulty,
    this.completed = const Value.absent(),
    this.rewardClaimed = const Value.absent(),
    this.bestSeconds = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : date = Value(date),
       levelId = Value(levelId),
       selectedDifficulty = Value(selectedDifficulty);
  static Insertable<DailyRow> custom({
    Expression<String>? date,
    Expression<int>? levelId,
    Expression<String>? selectedDifficulty,
    Expression<bool>? completed,
    Expression<bool>? rewardClaimed,
    Expression<int>? bestSeconds,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (date != null) 'date': date,
      if (levelId != null) 'level_id': levelId,
      if (selectedDifficulty != null) 'selected_difficulty': selectedDifficulty,
      if (completed != null) 'completed': completed,
      if (rewardClaimed != null) 'reward_claimed': rewardClaimed,
      if (bestSeconds != null) 'best_seconds': bestSeconds,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyPuzzlesCompanion copyWith({
    Value<String>? date,
    Value<int>? levelId,
    Value<String>? selectedDifficulty,
    Value<bool>? completed,
    Value<bool>? rewardClaimed,
    Value<int?>? bestSeconds,
    Value<int>? rowid,
  }) {
    return DailyPuzzlesCompanion(
      date: date ?? this.date,
      levelId: levelId ?? this.levelId,
      selectedDifficulty: selectedDifficulty ?? this.selectedDifficulty,
      completed: completed ?? this.completed,
      rewardClaimed: rewardClaimed ?? this.rewardClaimed,
      bestSeconds: bestSeconds ?? this.bestSeconds,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (levelId.present) {
      map['level_id'] = Variable<int>(levelId.value);
    }
    if (selectedDifficulty.present) {
      map['selected_difficulty'] = Variable<String>(selectedDifficulty.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (rewardClaimed.present) {
      map['reward_claimed'] = Variable<bool>(rewardClaimed.value);
    }
    if (bestSeconds.present) {
      map['best_seconds'] = Variable<int>(bestSeconds.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyPuzzlesCompanion(')
          ..write('date: $date, ')
          ..write('levelId: $levelId, ')
          ..write('selectedDifficulty: $selectedDifficulty, ')
          ..write('completed: $completed, ')
          ..write('rewardClaimed: $rewardClaimed, ')
          ..write('bestSeconds: $bestSeconds, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AchievementStatesTable extends AchievementStates
    with TableInfo<$AchievementStatesTable, AchievementRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AchievementStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _achievementIdMeta = const VerificationMeta(
    'achievementId',
  );
  @override
  late final GeneratedColumn<String> achievementId = GeneratedColumn<String>(
    'achievement_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _progressMeta = const VerificationMeta(
    'progress',
  );
  @override
  late final GeneratedColumn<int> progress = GeneratedColumn<int>(
    'progress',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _completedMeta = const VerificationMeta(
    'completed',
  );
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
    'completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _claimedMeta = const VerificationMeta(
    'claimed',
  );
  @override
  late final GeneratedColumn<bool> claimed = GeneratedColumn<bool>(
    'claimed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("claimed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    achievementId,
    progress,
    completed,
    claimed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'achievement_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<AchievementRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('achievement_id')) {
      context.handle(
        _achievementIdMeta,
        achievementId.isAcceptableOrUnknown(
          data['achievement_id']!,
          _achievementIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_achievementIdMeta);
    }
    if (data.containsKey('progress')) {
      context.handle(
        _progressMeta,
        progress.isAcceptableOrUnknown(data['progress']!, _progressMeta),
      );
    }
    if (data.containsKey('completed')) {
      context.handle(
        _completedMeta,
        completed.isAcceptableOrUnknown(data['completed']!, _completedMeta),
      );
    }
    if (data.containsKey('claimed')) {
      context.handle(
        _claimedMeta,
        claimed.isAcceptableOrUnknown(data['claimed']!, _claimedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {achievementId};
  @override
  AchievementRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AchievementRow(
      achievementId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}achievement_id'],
      )!,
      progress: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}progress'],
      )!,
      completed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completed'],
      )!,
      claimed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}claimed'],
      )!,
    );
  }

  @override
  $AchievementStatesTable createAlias(String alias) {
    return $AchievementStatesTable(attachedDatabase, alias);
  }
}

class AchievementRow extends DataClass implements Insertable<AchievementRow> {
  final String achievementId;
  final int progress;
  final bool completed;
  final bool claimed;
  const AchievementRow({
    required this.achievementId,
    required this.progress,
    required this.completed,
    required this.claimed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['achievement_id'] = Variable<String>(achievementId);
    map['progress'] = Variable<int>(progress);
    map['completed'] = Variable<bool>(completed);
    map['claimed'] = Variable<bool>(claimed);
    return map;
  }

  AchievementStatesCompanion toCompanion(bool nullToAbsent) {
    return AchievementStatesCompanion(
      achievementId: Value(achievementId),
      progress: Value(progress),
      completed: Value(completed),
      claimed: Value(claimed),
    );
  }

  factory AchievementRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AchievementRow(
      achievementId: serializer.fromJson<String>(json['achievementId']),
      progress: serializer.fromJson<int>(json['progress']),
      completed: serializer.fromJson<bool>(json['completed']),
      claimed: serializer.fromJson<bool>(json['claimed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'achievementId': serializer.toJson<String>(achievementId),
      'progress': serializer.toJson<int>(progress),
      'completed': serializer.toJson<bool>(completed),
      'claimed': serializer.toJson<bool>(claimed),
    };
  }

  AchievementRow copyWith({
    String? achievementId,
    int? progress,
    bool? completed,
    bool? claimed,
  }) => AchievementRow(
    achievementId: achievementId ?? this.achievementId,
    progress: progress ?? this.progress,
    completed: completed ?? this.completed,
    claimed: claimed ?? this.claimed,
  );
  AchievementRow copyWithCompanion(AchievementStatesCompanion data) {
    return AchievementRow(
      achievementId: data.achievementId.present
          ? data.achievementId.value
          : this.achievementId,
      progress: data.progress.present ? data.progress.value : this.progress,
      completed: data.completed.present ? data.completed.value : this.completed,
      claimed: data.claimed.present ? data.claimed.value : this.claimed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AchievementRow(')
          ..write('achievementId: $achievementId, ')
          ..write('progress: $progress, ')
          ..write('completed: $completed, ')
          ..write('claimed: $claimed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(achievementId, progress, completed, claimed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AchievementRow &&
          other.achievementId == this.achievementId &&
          other.progress == this.progress &&
          other.completed == this.completed &&
          other.claimed == this.claimed);
}

class AchievementStatesCompanion extends UpdateCompanion<AchievementRow> {
  final Value<String> achievementId;
  final Value<int> progress;
  final Value<bool> completed;
  final Value<bool> claimed;
  final Value<int> rowid;
  const AchievementStatesCompanion({
    this.achievementId = const Value.absent(),
    this.progress = const Value.absent(),
    this.completed = const Value.absent(),
    this.claimed = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AchievementStatesCompanion.insert({
    required String achievementId,
    this.progress = const Value.absent(),
    this.completed = const Value.absent(),
    this.claimed = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : achievementId = Value(achievementId);
  static Insertable<AchievementRow> custom({
    Expression<String>? achievementId,
    Expression<int>? progress,
    Expression<bool>? completed,
    Expression<bool>? claimed,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (achievementId != null) 'achievement_id': achievementId,
      if (progress != null) 'progress': progress,
      if (completed != null) 'completed': completed,
      if (claimed != null) 'claimed': claimed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AchievementStatesCompanion copyWith({
    Value<String>? achievementId,
    Value<int>? progress,
    Value<bool>? completed,
    Value<bool>? claimed,
    Value<int>? rowid,
  }) {
    return AchievementStatesCompanion(
      achievementId: achievementId ?? this.achievementId,
      progress: progress ?? this.progress,
      completed: completed ?? this.completed,
      claimed: claimed ?? this.claimed,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (achievementId.present) {
      map['achievement_id'] = Variable<String>(achievementId.value);
    }
    if (progress.present) {
      map['progress'] = Variable<int>(progress.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (claimed.present) {
      map['claimed'] = Variable<bool>(claimed.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AchievementStatesCompanion(')
          ..write('achievementId: $achievementId, ')
          ..write('progress: $progress, ')
          ..write('completed: $completed, ')
          ..write('claimed: $claimed, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RewardTransactionsTable extends RewardTransactions
    with TableInfo<$RewardTransactionsTable, RewardRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RewardTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  @override
  late final GeneratedColumn<int> transactionId = GeneratedColumn<int>(
    'transaction_id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rewardTypeMeta = const VerificationMeta(
    'rewardType',
  );
  @override
  late final GeneratedColumn<String> rewardType = GeneratedColumn<String>(
    'reward_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('coins'),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    check: () => ComparableExpr(amount).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idempotencyKeyMeta = const VerificationMeta(
    'idempotencyKey',
  );
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
    'idempotency_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    transactionId,
    eventId,
    rewardType,
    currency,
    amount,
    timestamp,
    idempotencyKey,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reward_transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<RewardRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('transaction_id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['transaction_id']!,
          _transactionIdMeta,
        ),
      );
    }
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('reward_type')) {
      context.handle(
        _rewardTypeMeta,
        rewardType.isAcceptableOrUnknown(data['reward_type']!, _rewardTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_rewardTypeMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
        _idempotencyKeyMeta,
        idempotencyKey.isAcceptableOrUnknown(
          data['idempotency_key']!,
          _idempotencyKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idempotencyKeyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {transactionId};
  @override
  RewardRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RewardRow(
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}transaction_id'],
      )!,
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_id'],
      )!,
      rewardType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reward_type'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      idempotencyKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}idempotency_key'],
      )!,
    );
  }

  @override
  $RewardTransactionsTable createAlias(String alias) {
    return $RewardTransactionsTable(attachedDatabase, alias);
  }
}

class RewardRow extends DataClass implements Insertable<RewardRow> {
  final int transactionId;
  final String eventId;
  final String rewardType;
  final String currency;
  final int amount;
  final DateTime timestamp;
  final String idempotencyKey;
  const RewardRow({
    required this.transactionId,
    required this.eventId,
    required this.rewardType,
    required this.currency,
    required this.amount,
    required this.timestamp,
    required this.idempotencyKey,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['transaction_id'] = Variable<int>(transactionId);
    map['event_id'] = Variable<String>(eventId);
    map['reward_type'] = Variable<String>(rewardType);
    map['currency'] = Variable<String>(currency);
    map['amount'] = Variable<int>(amount);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    return map;
  }

  RewardTransactionsCompanion toCompanion(bool nullToAbsent) {
    return RewardTransactionsCompanion(
      transactionId: Value(transactionId),
      eventId: Value(eventId),
      rewardType: Value(rewardType),
      currency: Value(currency),
      amount: Value(amount),
      timestamp: Value(timestamp),
      idempotencyKey: Value(idempotencyKey),
    );
  }

  factory RewardRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RewardRow(
      transactionId: serializer.fromJson<int>(json['transactionId']),
      eventId: serializer.fromJson<String>(json['eventId']),
      rewardType: serializer.fromJson<String>(json['rewardType']),
      currency: serializer.fromJson<String>(json['currency']),
      amount: serializer.fromJson<int>(json['amount']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'transactionId': serializer.toJson<int>(transactionId),
      'eventId': serializer.toJson<String>(eventId),
      'rewardType': serializer.toJson<String>(rewardType),
      'currency': serializer.toJson<String>(currency),
      'amount': serializer.toJson<int>(amount),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
    };
  }

  RewardRow copyWith({
    int? transactionId,
    String? eventId,
    String? rewardType,
    String? currency,
    int? amount,
    DateTime? timestamp,
    String? idempotencyKey,
  }) => RewardRow(
    transactionId: transactionId ?? this.transactionId,
    eventId: eventId ?? this.eventId,
    rewardType: rewardType ?? this.rewardType,
    currency: currency ?? this.currency,
    amount: amount ?? this.amount,
    timestamp: timestamp ?? this.timestamp,
    idempotencyKey: idempotencyKey ?? this.idempotencyKey,
  );
  RewardRow copyWithCompanion(RewardTransactionsCompanion data) {
    return RewardRow(
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      rewardType: data.rewardType.present
          ? data.rewardType.value
          : this.rewardType,
      currency: data.currency.present ? data.currency.value : this.currency,
      amount: data.amount.present ? data.amount.value : this.amount,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RewardRow(')
          ..write('transactionId: $transactionId, ')
          ..write('eventId: $eventId, ')
          ..write('rewardType: $rewardType, ')
          ..write('currency: $currency, ')
          ..write('amount: $amount, ')
          ..write('timestamp: $timestamp, ')
          ..write('idempotencyKey: $idempotencyKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    transactionId,
    eventId,
    rewardType,
    currency,
    amount,
    timestamp,
    idempotencyKey,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RewardRow &&
          other.transactionId == this.transactionId &&
          other.eventId == this.eventId &&
          other.rewardType == this.rewardType &&
          other.currency == this.currency &&
          other.amount == this.amount &&
          other.timestamp == this.timestamp &&
          other.idempotencyKey == this.idempotencyKey);
}

class RewardTransactionsCompanion extends UpdateCompanion<RewardRow> {
  final Value<int> transactionId;
  final Value<String> eventId;
  final Value<String> rewardType;
  final Value<String> currency;
  final Value<int> amount;
  final Value<DateTime> timestamp;
  final Value<String> idempotencyKey;
  const RewardTransactionsCompanion({
    this.transactionId = const Value.absent(),
    this.eventId = const Value.absent(),
    this.rewardType = const Value.absent(),
    this.currency = const Value.absent(),
    this.amount = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
  });
  RewardTransactionsCompanion.insert({
    this.transactionId = const Value.absent(),
    required String eventId,
    required String rewardType,
    this.currency = const Value.absent(),
    required int amount,
    required DateTime timestamp,
    required String idempotencyKey,
  }) : eventId = Value(eventId),
       rewardType = Value(rewardType),
       amount = Value(amount),
       timestamp = Value(timestamp),
       idempotencyKey = Value(idempotencyKey);
  static Insertable<RewardRow> custom({
    Expression<int>? transactionId,
    Expression<String>? eventId,
    Expression<String>? rewardType,
    Expression<String>? currency,
    Expression<int>? amount,
    Expression<DateTime>? timestamp,
    Expression<String>? idempotencyKey,
  }) {
    return RawValuesInsertable({
      if (transactionId != null) 'transaction_id': transactionId,
      if (eventId != null) 'event_id': eventId,
      if (rewardType != null) 'reward_type': rewardType,
      if (currency != null) 'currency': currency,
      if (amount != null) 'amount': amount,
      if (timestamp != null) 'timestamp': timestamp,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
    });
  }

  RewardTransactionsCompanion copyWith({
    Value<int>? transactionId,
    Value<String>? eventId,
    Value<String>? rewardType,
    Value<String>? currency,
    Value<int>? amount,
    Value<DateTime>? timestamp,
    Value<String>? idempotencyKey,
  }) {
    return RewardTransactionsCompanion(
      transactionId: transactionId ?? this.transactionId,
      eventId: eventId ?? this.eventId,
      rewardType: rewardType ?? this.rewardType,
      currency: currency ?? this.currency,
      amount: amount ?? this.amount,
      timestamp: timestamp ?? this.timestamp,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (transactionId.present) {
      map['transaction_id'] = Variable<int>(transactionId.value);
    }
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (rewardType.present) {
      map['reward_type'] = Variable<String>(rewardType.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RewardTransactionsCompanion(')
          ..write('transactionId: $transactionId, ')
          ..write('eventId: $eventId, ')
          ..write('rewardType: $rewardType, ')
          ..write('currency: $currency, ')
          ..write('amount: $amount, ')
          ..write('timestamp: $timestamp, ')
          ..write('idempotencyKey: $idempotencyKey')
          ..write(')'))
        .toString();
  }
}

class $PlayHistoryTable extends PlayHistory
    with TableInfo<$PlayHistoryTable, HistoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlayHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _puzzleKeyMeta = const VerificationMeta(
    'puzzleKey',
  );
  @override
  late final GeneratedColumn<String> puzzleKey = GeneratedColumn<String>(
    'puzzle_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _levelIdMeta = const VerificationMeta(
    'levelId',
  );
  @override
  late final GeneratedColumn<int> levelId = GeneratedColumn<int>(
    'level_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDailyMeta = const VerificationMeta(
    'isDaily',
  );
  @override
  late final GeneratedColumn<bool> isDaily = GeneratedColumn<bool>(
    'is_daily',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_daily" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _secondsMeta = const VerificationMeta(
    'seconds',
  );
  @override
  late final GeneratedColumn<int> seconds = GeneratedColumn<int>(
    'seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _starsMeta = const VerificationMeta('stars');
  @override
  late final GeneratedColumn<int> stars = GeneratedColumn<int>(
    'stars',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<DateTime> at = GeneratedColumn<DateTime>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    puzzleKey,
    levelId,
    isDaily,
    seconds,
    stars,
    at,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'play_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<HistoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('puzzle_key')) {
      context.handle(
        _puzzleKeyMeta,
        puzzleKey.isAcceptableOrUnknown(data['puzzle_key']!, _puzzleKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_puzzleKeyMeta);
    }
    if (data.containsKey('level_id')) {
      context.handle(
        _levelIdMeta,
        levelId.isAcceptableOrUnknown(data['level_id']!, _levelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_levelIdMeta);
    }
    if (data.containsKey('is_daily')) {
      context.handle(
        _isDailyMeta,
        isDaily.isAcceptableOrUnknown(data['is_daily']!, _isDailyMeta),
      );
    }
    if (data.containsKey('seconds')) {
      context.handle(
        _secondsMeta,
        seconds.isAcceptableOrUnknown(data['seconds']!, _secondsMeta),
      );
    } else if (isInserting) {
      context.missing(_secondsMeta);
    }
    if (data.containsKey('stars')) {
      context.handle(
        _starsMeta,
        stars.isAcceptableOrUnknown(data['stars']!, _starsMeta),
      );
    } else if (isInserting) {
      context.missing(_starsMeta);
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HistoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HistoryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      puzzleKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}puzzle_key'],
      )!,
      levelId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level_id'],
      )!,
      isDaily: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_daily'],
      )!,
      seconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seconds'],
      )!,
      stars: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stars'],
      )!,
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}at'],
      )!,
    );
  }

  @override
  $PlayHistoryTable createAlias(String alias) {
    return $PlayHistoryTable(attachedDatabase, alias);
  }
}

class HistoryRow extends DataClass implements Insertable<HistoryRow> {
  final int id;
  final String puzzleKey;
  final int levelId;
  final bool isDaily;
  final int seconds;
  final int stars;
  final DateTime at;
  const HistoryRow({
    required this.id,
    required this.puzzleKey,
    required this.levelId,
    required this.isDaily,
    required this.seconds,
    required this.stars,
    required this.at,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['puzzle_key'] = Variable<String>(puzzleKey);
    map['level_id'] = Variable<int>(levelId);
    map['is_daily'] = Variable<bool>(isDaily);
    map['seconds'] = Variable<int>(seconds);
    map['stars'] = Variable<int>(stars);
    map['at'] = Variable<DateTime>(at);
    return map;
  }

  PlayHistoryCompanion toCompanion(bool nullToAbsent) {
    return PlayHistoryCompanion(
      id: Value(id),
      puzzleKey: Value(puzzleKey),
      levelId: Value(levelId),
      isDaily: Value(isDaily),
      seconds: Value(seconds),
      stars: Value(stars),
      at: Value(at),
    );
  }

  factory HistoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HistoryRow(
      id: serializer.fromJson<int>(json['id']),
      puzzleKey: serializer.fromJson<String>(json['puzzleKey']),
      levelId: serializer.fromJson<int>(json['levelId']),
      isDaily: serializer.fromJson<bool>(json['isDaily']),
      seconds: serializer.fromJson<int>(json['seconds']),
      stars: serializer.fromJson<int>(json['stars']),
      at: serializer.fromJson<DateTime>(json['at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'puzzleKey': serializer.toJson<String>(puzzleKey),
      'levelId': serializer.toJson<int>(levelId),
      'isDaily': serializer.toJson<bool>(isDaily),
      'seconds': serializer.toJson<int>(seconds),
      'stars': serializer.toJson<int>(stars),
      'at': serializer.toJson<DateTime>(at),
    };
  }

  HistoryRow copyWith({
    int? id,
    String? puzzleKey,
    int? levelId,
    bool? isDaily,
    int? seconds,
    int? stars,
    DateTime? at,
  }) => HistoryRow(
    id: id ?? this.id,
    puzzleKey: puzzleKey ?? this.puzzleKey,
    levelId: levelId ?? this.levelId,
    isDaily: isDaily ?? this.isDaily,
    seconds: seconds ?? this.seconds,
    stars: stars ?? this.stars,
    at: at ?? this.at,
  );
  HistoryRow copyWithCompanion(PlayHistoryCompanion data) {
    return HistoryRow(
      id: data.id.present ? data.id.value : this.id,
      puzzleKey: data.puzzleKey.present ? data.puzzleKey.value : this.puzzleKey,
      levelId: data.levelId.present ? data.levelId.value : this.levelId,
      isDaily: data.isDaily.present ? data.isDaily.value : this.isDaily,
      seconds: data.seconds.present ? data.seconds.value : this.seconds,
      stars: data.stars.present ? data.stars.value : this.stars,
      at: data.at.present ? data.at.value : this.at,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HistoryRow(')
          ..write('id: $id, ')
          ..write('puzzleKey: $puzzleKey, ')
          ..write('levelId: $levelId, ')
          ..write('isDaily: $isDaily, ')
          ..write('seconds: $seconds, ')
          ..write('stars: $stars, ')
          ..write('at: $at')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, puzzleKey, levelId, isDaily, seconds, stars, at);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HistoryRow &&
          other.id == this.id &&
          other.puzzleKey == this.puzzleKey &&
          other.levelId == this.levelId &&
          other.isDaily == this.isDaily &&
          other.seconds == this.seconds &&
          other.stars == this.stars &&
          other.at == this.at);
}

class PlayHistoryCompanion extends UpdateCompanion<HistoryRow> {
  final Value<int> id;
  final Value<String> puzzleKey;
  final Value<int> levelId;
  final Value<bool> isDaily;
  final Value<int> seconds;
  final Value<int> stars;
  final Value<DateTime> at;
  const PlayHistoryCompanion({
    this.id = const Value.absent(),
    this.puzzleKey = const Value.absent(),
    this.levelId = const Value.absent(),
    this.isDaily = const Value.absent(),
    this.seconds = const Value.absent(),
    this.stars = const Value.absent(),
    this.at = const Value.absent(),
  });
  PlayHistoryCompanion.insert({
    this.id = const Value.absent(),
    required String puzzleKey,
    required int levelId,
    this.isDaily = const Value.absent(),
    required int seconds,
    required int stars,
    required DateTime at,
  }) : puzzleKey = Value(puzzleKey),
       levelId = Value(levelId),
       seconds = Value(seconds),
       stars = Value(stars),
       at = Value(at);
  static Insertable<HistoryRow> custom({
    Expression<int>? id,
    Expression<String>? puzzleKey,
    Expression<int>? levelId,
    Expression<bool>? isDaily,
    Expression<int>? seconds,
    Expression<int>? stars,
    Expression<DateTime>? at,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (puzzleKey != null) 'puzzle_key': puzzleKey,
      if (levelId != null) 'level_id': levelId,
      if (isDaily != null) 'is_daily': isDaily,
      if (seconds != null) 'seconds': seconds,
      if (stars != null) 'stars': stars,
      if (at != null) 'at': at,
    });
  }

  PlayHistoryCompanion copyWith({
    Value<int>? id,
    Value<String>? puzzleKey,
    Value<int>? levelId,
    Value<bool>? isDaily,
    Value<int>? seconds,
    Value<int>? stars,
    Value<DateTime>? at,
  }) {
    return PlayHistoryCompanion(
      id: id ?? this.id,
      puzzleKey: puzzleKey ?? this.puzzleKey,
      levelId: levelId ?? this.levelId,
      isDaily: isDaily ?? this.isDaily,
      seconds: seconds ?? this.seconds,
      stars: stars ?? this.stars,
      at: at ?? this.at,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (puzzleKey.present) {
      map['puzzle_key'] = Variable<String>(puzzleKey.value);
    }
    if (levelId.present) {
      map['level_id'] = Variable<int>(levelId.value);
    }
    if (isDaily.present) {
      map['is_daily'] = Variable<bool>(isDaily.value);
    }
    if (seconds.present) {
      map['seconds'] = Variable<int>(seconds.value);
    }
    if (stars.present) {
      map['stars'] = Variable<int>(stars.value);
    }
    if (at.present) {
      map['at'] = Variable<DateTime>(at.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlayHistoryCompanion(')
          ..write('id: $id, ')
          ..write('puzzleKey: $puzzleKey, ')
          ..write('levelId: $levelId, ')
          ..write('isDaily: $isDaily, ')
          ..write('seconds: $seconds, ')
          ..write('stars: $stars, ')
          ..write('at: $at')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PlayerProfilesTable playerProfiles = $PlayerProfilesTable(this);
  late final $PuzzleProgressTable puzzleProgress = $PuzzleProgressTable(this);
  late final $ActivePuzzlesTable activePuzzles = $ActivePuzzlesTable(this);
  late final $PuzzleFavoritesTable puzzleFavorites = $PuzzleFavoritesTable(
    this,
  );
  late final $DailyPuzzlesTable dailyPuzzles = $DailyPuzzlesTable(this);
  late final $AchievementStatesTable achievementStates =
      $AchievementStatesTable(this);
  late final $RewardTransactionsTable rewardTransactions =
      $RewardTransactionsTable(this);
  late final $PlayHistoryTable playHistory = $PlayHistoryTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    playerProfiles,
    puzzleProgress,
    activePuzzles,
    puzzleFavorites,
    dailyPuzzles,
    achievementStates,
    rewardTransactions,
    playHistory,
  ];
}

typedef $$PlayerProfilesTableCreateCompanionBuilder =
    PlayerProfilesCompanion Function({
      Value<int> id,
      Value<String> playerName,
      Value<int> totalCoins,
      Value<int> totalCompletedLevels,
      Value<int> totalStars,
      Value<DateTime> createdAt,
    });
typedef $$PlayerProfilesTableUpdateCompanionBuilder =
    PlayerProfilesCompanion Function({
      Value<int> id,
      Value<String> playerName,
      Value<int> totalCoins,
      Value<int> totalCompletedLevels,
      Value<int> totalStars,
      Value<DateTime> createdAt,
    });

class $$PlayerProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $PlayerProfilesTable> {
  $$PlayerProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get playerName => $composableBuilder(
    column: $table.playerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalCoins => $composableBuilder(
    column: $table.totalCoins,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalCompletedLevels => $composableBuilder(
    column: $table.totalCompletedLevels,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalStars => $composableBuilder(
    column: $table.totalStars,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlayerProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $PlayerProfilesTable> {
  $$PlayerProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get playerName => $composableBuilder(
    column: $table.playerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalCoins => $composableBuilder(
    column: $table.totalCoins,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalCompletedLevels => $composableBuilder(
    column: $table.totalCompletedLevels,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalStars => $composableBuilder(
    column: $table.totalStars,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlayerProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlayerProfilesTable> {
  $$PlayerProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get playerName => $composableBuilder(
    column: $table.playerName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalCoins => $composableBuilder(
    column: $table.totalCoins,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalCompletedLevels => $composableBuilder(
    column: $table.totalCompletedLevels,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalStars => $composableBuilder(
    column: $table.totalStars,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PlayerProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlayerProfilesTable,
          PlayerProfileRow,
          $$PlayerProfilesTableFilterComposer,
          $$PlayerProfilesTableOrderingComposer,
          $$PlayerProfilesTableAnnotationComposer,
          $$PlayerProfilesTableCreateCompanionBuilder,
          $$PlayerProfilesTableUpdateCompanionBuilder,
          (
            PlayerProfileRow,
            BaseReferences<
              _$AppDatabase,
              $PlayerProfilesTable,
              PlayerProfileRow
            >,
          ),
          PlayerProfileRow,
          PrefetchHooks Function()
        > {
  $$PlayerProfilesTableTableManager(
    _$AppDatabase db,
    $PlayerProfilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlayerProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlayerProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlayerProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> playerName = const Value.absent(),
                Value<int> totalCoins = const Value.absent(),
                Value<int> totalCompletedLevels = const Value.absent(),
                Value<int> totalStars = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PlayerProfilesCompanion(
                id: id,
                playerName: playerName,
                totalCoins: totalCoins,
                totalCompletedLevels: totalCompletedLevels,
                totalStars: totalStars,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> playerName = const Value.absent(),
                Value<int> totalCoins = const Value.absent(),
                Value<int> totalCompletedLevels = const Value.absent(),
                Value<int> totalStars = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PlayerProfilesCompanion.insert(
                id: id,
                playerName: playerName,
                totalCoins: totalCoins,
                totalCompletedLevels: totalCompletedLevels,
                totalStars: totalStars,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlayerProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlayerProfilesTable,
      PlayerProfileRow,
      $$PlayerProfilesTableFilterComposer,
      $$PlayerProfilesTableOrderingComposer,
      $$PlayerProfilesTableAnnotationComposer,
      $$PlayerProfilesTableCreateCompanionBuilder,
      $$PlayerProfilesTableUpdateCompanionBuilder,
      (
        PlayerProfileRow,
        BaseReferences<_$AppDatabase, $PlayerProfilesTable, PlayerProfileRow>,
      ),
      PlayerProfileRow,
      PrefetchHooks Function()
    >;
typedef $$PuzzleProgressTableCreateCompanionBuilder =
    PuzzleProgressCompanion Function({
      Value<int> levelId,
      Value<bool> completed,
      Value<int?> bestSeconds,
      Value<int> hintsUsed,
      Value<DateTime?> completionDate,
      Value<int> bestStars,
      Value<int> playCount,
    });
typedef $$PuzzleProgressTableUpdateCompanionBuilder =
    PuzzleProgressCompanion Function({
      Value<int> levelId,
      Value<bool> completed,
      Value<int?> bestSeconds,
      Value<int> hintsUsed,
      Value<DateTime?> completionDate,
      Value<int> bestStars,
      Value<int> playCount,
    });

class $$PuzzleProgressTableFilterComposer
    extends Composer<_$AppDatabase, $PuzzleProgressTable> {
  $$PuzzleProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get levelId => $composableBuilder(
    column: $table.levelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bestSeconds => $composableBuilder(
    column: $table.bestSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hintsUsed => $composableBuilder(
    column: $table.hintsUsed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completionDate => $composableBuilder(
    column: $table.completionDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bestStars => $composableBuilder(
    column: $table.bestStars,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get playCount => $composableBuilder(
    column: $table.playCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PuzzleProgressTableOrderingComposer
    extends Composer<_$AppDatabase, $PuzzleProgressTable> {
  $$PuzzleProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get levelId => $composableBuilder(
    column: $table.levelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bestSeconds => $composableBuilder(
    column: $table.bestSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hintsUsed => $composableBuilder(
    column: $table.hintsUsed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completionDate => $composableBuilder(
    column: $table.completionDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bestStars => $composableBuilder(
    column: $table.bestStars,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get playCount => $composableBuilder(
    column: $table.playCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PuzzleProgressTableAnnotationComposer
    extends Composer<_$AppDatabase, $PuzzleProgressTable> {
  $$PuzzleProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get levelId =>
      $composableBuilder(column: $table.levelId, builder: (column) => column);

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  GeneratedColumn<int> get bestSeconds => $composableBuilder(
    column: $table.bestSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get hintsUsed =>
      $composableBuilder(column: $table.hintsUsed, builder: (column) => column);

  GeneratedColumn<DateTime> get completionDate => $composableBuilder(
    column: $table.completionDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bestStars =>
      $composableBuilder(column: $table.bestStars, builder: (column) => column);

  GeneratedColumn<int> get playCount =>
      $composableBuilder(column: $table.playCount, builder: (column) => column);
}

class $$PuzzleProgressTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PuzzleProgressTable,
          ProgressRow,
          $$PuzzleProgressTableFilterComposer,
          $$PuzzleProgressTableOrderingComposer,
          $$PuzzleProgressTableAnnotationComposer,
          $$PuzzleProgressTableCreateCompanionBuilder,
          $$PuzzleProgressTableUpdateCompanionBuilder,
          (
            ProgressRow,
            BaseReferences<_$AppDatabase, $PuzzleProgressTable, ProgressRow>,
          ),
          ProgressRow,
          PrefetchHooks Function()
        > {
  $$PuzzleProgressTableTableManager(
    _$AppDatabase db,
    $PuzzleProgressTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PuzzleProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PuzzleProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PuzzleProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> levelId = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<int?> bestSeconds = const Value.absent(),
                Value<int> hintsUsed = const Value.absent(),
                Value<DateTime?> completionDate = const Value.absent(),
                Value<int> bestStars = const Value.absent(),
                Value<int> playCount = const Value.absent(),
              }) => PuzzleProgressCompanion(
                levelId: levelId,
                completed: completed,
                bestSeconds: bestSeconds,
                hintsUsed: hintsUsed,
                completionDate: completionDate,
                bestStars: bestStars,
                playCount: playCount,
              ),
          createCompanionCallback:
              ({
                Value<int> levelId = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<int?> bestSeconds = const Value.absent(),
                Value<int> hintsUsed = const Value.absent(),
                Value<DateTime?> completionDate = const Value.absent(),
                Value<int> bestStars = const Value.absent(),
                Value<int> playCount = const Value.absent(),
              }) => PuzzleProgressCompanion.insert(
                levelId: levelId,
                completed: completed,
                bestSeconds: bestSeconds,
                hintsUsed: hintsUsed,
                completionDate: completionDate,
                bestStars: bestStars,
                playCount: playCount,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PuzzleProgressTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PuzzleProgressTable,
      ProgressRow,
      $$PuzzleProgressTableFilterComposer,
      $$PuzzleProgressTableOrderingComposer,
      $$PuzzleProgressTableAnnotationComposer,
      $$PuzzleProgressTableCreateCompanionBuilder,
      $$PuzzleProgressTableUpdateCompanionBuilder,
      (
        ProgressRow,
        BaseReferences<_$AppDatabase, $PuzzleProgressTable, ProgressRow>,
      ),
      ProgressRow,
      PrefetchHooks Function()
    >;
typedef $$ActivePuzzlesTableCreateCompanionBuilder =
    ActivePuzzlesCompanion Function({
      required String puzzleKey,
      required int levelId,
      required String imageId,
      required int pieceCount,
      required int randomSeed,
      Value<int> placedCount,
      required String stateJson,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ActivePuzzlesTableUpdateCompanionBuilder =
    ActivePuzzlesCompanion Function({
      Value<String> puzzleKey,
      Value<int> levelId,
      Value<String> imageId,
      Value<int> pieceCount,
      Value<int> randomSeed,
      Value<int> placedCount,
      Value<String> stateJson,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$ActivePuzzlesTableFilterComposer
    extends Composer<_$AppDatabase, $ActivePuzzlesTable> {
  $$ActivePuzzlesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get puzzleKey => $composableBuilder(
    column: $table.puzzleKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get levelId => $composableBuilder(
    column: $table.levelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageId => $composableBuilder(
    column: $table.imageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pieceCount => $composableBuilder(
    column: $table.pieceCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get randomSeed => $composableBuilder(
    column: $table.randomSeed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get placedCount => $composableBuilder(
    column: $table.placedCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stateJson => $composableBuilder(
    column: $table.stateJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ActivePuzzlesTableOrderingComposer
    extends Composer<_$AppDatabase, $ActivePuzzlesTable> {
  $$ActivePuzzlesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get puzzleKey => $composableBuilder(
    column: $table.puzzleKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get levelId => $composableBuilder(
    column: $table.levelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageId => $composableBuilder(
    column: $table.imageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pieceCount => $composableBuilder(
    column: $table.pieceCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get randomSeed => $composableBuilder(
    column: $table.randomSeed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get placedCount => $composableBuilder(
    column: $table.placedCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stateJson => $composableBuilder(
    column: $table.stateJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ActivePuzzlesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActivePuzzlesTable> {
  $$ActivePuzzlesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get puzzleKey =>
      $composableBuilder(column: $table.puzzleKey, builder: (column) => column);

  GeneratedColumn<int> get levelId =>
      $composableBuilder(column: $table.levelId, builder: (column) => column);

  GeneratedColumn<String> get imageId =>
      $composableBuilder(column: $table.imageId, builder: (column) => column);

  GeneratedColumn<int> get pieceCount => $composableBuilder(
    column: $table.pieceCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get randomSeed => $composableBuilder(
    column: $table.randomSeed,
    builder: (column) => column,
  );

  GeneratedColumn<int> get placedCount => $composableBuilder(
    column: $table.placedCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get stateJson =>
      $composableBuilder(column: $table.stateJson, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ActivePuzzlesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActivePuzzlesTable,
          ActivePuzzleRow,
          $$ActivePuzzlesTableFilterComposer,
          $$ActivePuzzlesTableOrderingComposer,
          $$ActivePuzzlesTableAnnotationComposer,
          $$ActivePuzzlesTableCreateCompanionBuilder,
          $$ActivePuzzlesTableUpdateCompanionBuilder,
          (
            ActivePuzzleRow,
            BaseReferences<_$AppDatabase, $ActivePuzzlesTable, ActivePuzzleRow>,
          ),
          ActivePuzzleRow,
          PrefetchHooks Function()
        > {
  $$ActivePuzzlesTableTableManager(_$AppDatabase db, $ActivePuzzlesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivePuzzlesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivePuzzlesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivePuzzlesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> puzzleKey = const Value.absent(),
                Value<int> levelId = const Value.absent(),
                Value<String> imageId = const Value.absent(),
                Value<int> pieceCount = const Value.absent(),
                Value<int> randomSeed = const Value.absent(),
                Value<int> placedCount = const Value.absent(),
                Value<String> stateJson = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivePuzzlesCompanion(
                puzzleKey: puzzleKey,
                levelId: levelId,
                imageId: imageId,
                pieceCount: pieceCount,
                randomSeed: randomSeed,
                placedCount: placedCount,
                stateJson: stateJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String puzzleKey,
                required int levelId,
                required String imageId,
                required int pieceCount,
                required int randomSeed,
                Value<int> placedCount = const Value.absent(),
                required String stateJson,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ActivePuzzlesCompanion.insert(
                puzzleKey: puzzleKey,
                levelId: levelId,
                imageId: imageId,
                pieceCount: pieceCount,
                randomSeed: randomSeed,
                placedCount: placedCount,
                stateJson: stateJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ActivePuzzlesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActivePuzzlesTable,
      ActivePuzzleRow,
      $$ActivePuzzlesTableFilterComposer,
      $$ActivePuzzlesTableOrderingComposer,
      $$ActivePuzzlesTableAnnotationComposer,
      $$ActivePuzzlesTableCreateCompanionBuilder,
      $$ActivePuzzlesTableUpdateCompanionBuilder,
      (
        ActivePuzzleRow,
        BaseReferences<_$AppDatabase, $ActivePuzzlesTable, ActivePuzzleRow>,
      ),
      ActivePuzzleRow,
      PrefetchHooks Function()
    >;
typedef $$PuzzleFavoritesTableCreateCompanionBuilder =
    PuzzleFavoritesCompanion Function({
      Value<int> levelId,
      Value<DateTime> createdAt,
    });
typedef $$PuzzleFavoritesTableUpdateCompanionBuilder =
    PuzzleFavoritesCompanion Function({
      Value<int> levelId,
      Value<DateTime> createdAt,
    });

class $$PuzzleFavoritesTableFilterComposer
    extends Composer<_$AppDatabase, $PuzzleFavoritesTable> {
  $$PuzzleFavoritesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get levelId => $composableBuilder(
    column: $table.levelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PuzzleFavoritesTableOrderingComposer
    extends Composer<_$AppDatabase, $PuzzleFavoritesTable> {
  $$PuzzleFavoritesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get levelId => $composableBuilder(
    column: $table.levelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PuzzleFavoritesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PuzzleFavoritesTable> {
  $$PuzzleFavoritesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get levelId =>
      $composableBuilder(column: $table.levelId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PuzzleFavoritesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PuzzleFavoritesTable,
          FavoriteRow,
          $$PuzzleFavoritesTableFilterComposer,
          $$PuzzleFavoritesTableOrderingComposer,
          $$PuzzleFavoritesTableAnnotationComposer,
          $$PuzzleFavoritesTableCreateCompanionBuilder,
          $$PuzzleFavoritesTableUpdateCompanionBuilder,
          (
            FavoriteRow,
            BaseReferences<_$AppDatabase, $PuzzleFavoritesTable, FavoriteRow>,
          ),
          FavoriteRow,
          PrefetchHooks Function()
        > {
  $$PuzzleFavoritesTableTableManager(
    _$AppDatabase db,
    $PuzzleFavoritesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PuzzleFavoritesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PuzzleFavoritesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PuzzleFavoritesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> levelId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PuzzleFavoritesCompanion(
                levelId: levelId,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> levelId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PuzzleFavoritesCompanion.insert(
                levelId: levelId,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PuzzleFavoritesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PuzzleFavoritesTable,
      FavoriteRow,
      $$PuzzleFavoritesTableFilterComposer,
      $$PuzzleFavoritesTableOrderingComposer,
      $$PuzzleFavoritesTableAnnotationComposer,
      $$PuzzleFavoritesTableCreateCompanionBuilder,
      $$PuzzleFavoritesTableUpdateCompanionBuilder,
      (
        FavoriteRow,
        BaseReferences<_$AppDatabase, $PuzzleFavoritesTable, FavoriteRow>,
      ),
      FavoriteRow,
      PrefetchHooks Function()
    >;
typedef $$DailyPuzzlesTableCreateCompanionBuilder =
    DailyPuzzlesCompanion Function({
      required String date,
      required int levelId,
      required String selectedDifficulty,
      Value<bool> completed,
      Value<bool> rewardClaimed,
      Value<int?> bestSeconds,
      Value<int> rowid,
    });
typedef $$DailyPuzzlesTableUpdateCompanionBuilder =
    DailyPuzzlesCompanion Function({
      Value<String> date,
      Value<int> levelId,
      Value<String> selectedDifficulty,
      Value<bool> completed,
      Value<bool> rewardClaimed,
      Value<int?> bestSeconds,
      Value<int> rowid,
    });

class $$DailyPuzzlesTableFilterComposer
    extends Composer<_$AppDatabase, $DailyPuzzlesTable> {
  $$DailyPuzzlesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get levelId => $composableBuilder(
    column: $table.levelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get selectedDifficulty => $composableBuilder(
    column: $table.selectedDifficulty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get rewardClaimed => $composableBuilder(
    column: $table.rewardClaimed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bestSeconds => $composableBuilder(
    column: $table.bestSeconds,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailyPuzzlesTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyPuzzlesTable> {
  $$DailyPuzzlesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get levelId => $composableBuilder(
    column: $table.levelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get selectedDifficulty => $composableBuilder(
    column: $table.selectedDifficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get rewardClaimed => $composableBuilder(
    column: $table.rewardClaimed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bestSeconds => $composableBuilder(
    column: $table.bestSeconds,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyPuzzlesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyPuzzlesTable> {
  $$DailyPuzzlesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get levelId =>
      $composableBuilder(column: $table.levelId, builder: (column) => column);

  GeneratedColumn<String> get selectedDifficulty => $composableBuilder(
    column: $table.selectedDifficulty,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  GeneratedColumn<bool> get rewardClaimed => $composableBuilder(
    column: $table.rewardClaimed,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bestSeconds => $composableBuilder(
    column: $table.bestSeconds,
    builder: (column) => column,
  );
}

class $$DailyPuzzlesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyPuzzlesTable,
          DailyRow,
          $$DailyPuzzlesTableFilterComposer,
          $$DailyPuzzlesTableOrderingComposer,
          $$DailyPuzzlesTableAnnotationComposer,
          $$DailyPuzzlesTableCreateCompanionBuilder,
          $$DailyPuzzlesTableUpdateCompanionBuilder,
          (
            DailyRow,
            BaseReferences<_$AppDatabase, $DailyPuzzlesTable, DailyRow>,
          ),
          DailyRow,
          PrefetchHooks Function()
        > {
  $$DailyPuzzlesTableTableManager(_$AppDatabase db, $DailyPuzzlesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyPuzzlesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyPuzzlesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyPuzzlesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> date = const Value.absent(),
                Value<int> levelId = const Value.absent(),
                Value<String> selectedDifficulty = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<bool> rewardClaimed = const Value.absent(),
                Value<int?> bestSeconds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyPuzzlesCompanion(
                date: date,
                levelId: levelId,
                selectedDifficulty: selectedDifficulty,
                completed: completed,
                rewardClaimed: rewardClaimed,
                bestSeconds: bestSeconds,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String date,
                required int levelId,
                required String selectedDifficulty,
                Value<bool> completed = const Value.absent(),
                Value<bool> rewardClaimed = const Value.absent(),
                Value<int?> bestSeconds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyPuzzlesCompanion.insert(
                date: date,
                levelId: levelId,
                selectedDifficulty: selectedDifficulty,
                completed: completed,
                rewardClaimed: rewardClaimed,
                bestSeconds: bestSeconds,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyPuzzlesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyPuzzlesTable,
      DailyRow,
      $$DailyPuzzlesTableFilterComposer,
      $$DailyPuzzlesTableOrderingComposer,
      $$DailyPuzzlesTableAnnotationComposer,
      $$DailyPuzzlesTableCreateCompanionBuilder,
      $$DailyPuzzlesTableUpdateCompanionBuilder,
      (DailyRow, BaseReferences<_$AppDatabase, $DailyPuzzlesTable, DailyRow>),
      DailyRow,
      PrefetchHooks Function()
    >;
typedef $$AchievementStatesTableCreateCompanionBuilder =
    AchievementStatesCompanion Function({
      required String achievementId,
      Value<int> progress,
      Value<bool> completed,
      Value<bool> claimed,
      Value<int> rowid,
    });
typedef $$AchievementStatesTableUpdateCompanionBuilder =
    AchievementStatesCompanion Function({
      Value<String> achievementId,
      Value<int> progress,
      Value<bool> completed,
      Value<bool> claimed,
      Value<int> rowid,
    });

class $$AchievementStatesTableFilterComposer
    extends Composer<_$AppDatabase, $AchievementStatesTable> {
  $$AchievementStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get achievementId => $composableBuilder(
    column: $table.achievementId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get claimed => $composableBuilder(
    column: $table.claimed,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AchievementStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $AchievementStatesTable> {
  $$AchievementStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get achievementId => $composableBuilder(
    column: $table.achievementId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get claimed => $composableBuilder(
    column: $table.claimed,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AchievementStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AchievementStatesTable> {
  $$AchievementStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get achievementId => $composableBuilder(
    column: $table.achievementId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get progress =>
      $composableBuilder(column: $table.progress, builder: (column) => column);

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  GeneratedColumn<bool> get claimed =>
      $composableBuilder(column: $table.claimed, builder: (column) => column);
}

class $$AchievementStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AchievementStatesTable,
          AchievementRow,
          $$AchievementStatesTableFilterComposer,
          $$AchievementStatesTableOrderingComposer,
          $$AchievementStatesTableAnnotationComposer,
          $$AchievementStatesTableCreateCompanionBuilder,
          $$AchievementStatesTableUpdateCompanionBuilder,
          (
            AchievementRow,
            BaseReferences<
              _$AppDatabase,
              $AchievementStatesTable,
              AchievementRow
            >,
          ),
          AchievementRow,
          PrefetchHooks Function()
        > {
  $$AchievementStatesTableTableManager(
    _$AppDatabase db,
    $AchievementStatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AchievementStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AchievementStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AchievementStatesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> achievementId = const Value.absent(),
                Value<int> progress = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<bool> claimed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AchievementStatesCompanion(
                achievementId: achievementId,
                progress: progress,
                completed: completed,
                claimed: claimed,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String achievementId,
                Value<int> progress = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<bool> claimed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AchievementStatesCompanion.insert(
                achievementId: achievementId,
                progress: progress,
                completed: completed,
                claimed: claimed,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AchievementStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AchievementStatesTable,
      AchievementRow,
      $$AchievementStatesTableFilterComposer,
      $$AchievementStatesTableOrderingComposer,
      $$AchievementStatesTableAnnotationComposer,
      $$AchievementStatesTableCreateCompanionBuilder,
      $$AchievementStatesTableUpdateCompanionBuilder,
      (
        AchievementRow,
        BaseReferences<_$AppDatabase, $AchievementStatesTable, AchievementRow>,
      ),
      AchievementRow,
      PrefetchHooks Function()
    >;
typedef $$RewardTransactionsTableCreateCompanionBuilder =
    RewardTransactionsCompanion Function({
      Value<int> transactionId,
      required String eventId,
      required String rewardType,
      Value<String> currency,
      required int amount,
      required DateTime timestamp,
      required String idempotencyKey,
    });
typedef $$RewardTransactionsTableUpdateCompanionBuilder =
    RewardTransactionsCompanion Function({
      Value<int> transactionId,
      Value<String> eventId,
      Value<String> rewardType,
      Value<String> currency,
      Value<int> amount,
      Value<DateTime> timestamp,
      Value<String> idempotencyKey,
    });

class $$RewardTransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $RewardTransactionsTable> {
  $$RewardTransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rewardType => $composableBuilder(
    column: $table.rewardType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RewardTransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $RewardTransactionsTable> {
  $$RewardTransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rewardType => $composableBuilder(
    column: $table.rewardType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RewardTransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RewardTransactionsTable> {
  $$RewardTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);

  GeneratedColumn<String> get rewardType => $composableBuilder(
    column: $table.rewardType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => column,
  );
}

class $$RewardTransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RewardTransactionsTable,
          RewardRow,
          $$RewardTransactionsTableFilterComposer,
          $$RewardTransactionsTableOrderingComposer,
          $$RewardTransactionsTableAnnotationComposer,
          $$RewardTransactionsTableCreateCompanionBuilder,
          $$RewardTransactionsTableUpdateCompanionBuilder,
          (
            RewardRow,
            BaseReferences<_$AppDatabase, $RewardTransactionsTable, RewardRow>,
          ),
          RewardRow,
          PrefetchHooks Function()
        > {
  $$RewardTransactionsTableTableManager(
    _$AppDatabase db,
    $RewardTransactionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RewardTransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RewardTransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RewardTransactionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> transactionId = const Value.absent(),
                Value<String> eventId = const Value.absent(),
                Value<String> rewardType = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<String> idempotencyKey = const Value.absent(),
              }) => RewardTransactionsCompanion(
                transactionId: transactionId,
                eventId: eventId,
                rewardType: rewardType,
                currency: currency,
                amount: amount,
                timestamp: timestamp,
                idempotencyKey: idempotencyKey,
              ),
          createCompanionCallback:
              ({
                Value<int> transactionId = const Value.absent(),
                required String eventId,
                required String rewardType,
                Value<String> currency = const Value.absent(),
                required int amount,
                required DateTime timestamp,
                required String idempotencyKey,
              }) => RewardTransactionsCompanion.insert(
                transactionId: transactionId,
                eventId: eventId,
                rewardType: rewardType,
                currency: currency,
                amount: amount,
                timestamp: timestamp,
                idempotencyKey: idempotencyKey,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RewardTransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RewardTransactionsTable,
      RewardRow,
      $$RewardTransactionsTableFilterComposer,
      $$RewardTransactionsTableOrderingComposer,
      $$RewardTransactionsTableAnnotationComposer,
      $$RewardTransactionsTableCreateCompanionBuilder,
      $$RewardTransactionsTableUpdateCompanionBuilder,
      (
        RewardRow,
        BaseReferences<_$AppDatabase, $RewardTransactionsTable, RewardRow>,
      ),
      RewardRow,
      PrefetchHooks Function()
    >;
typedef $$PlayHistoryTableCreateCompanionBuilder =
    PlayHistoryCompanion Function({
      Value<int> id,
      required String puzzleKey,
      required int levelId,
      Value<bool> isDaily,
      required int seconds,
      required int stars,
      required DateTime at,
    });
typedef $$PlayHistoryTableUpdateCompanionBuilder =
    PlayHistoryCompanion Function({
      Value<int> id,
      Value<String> puzzleKey,
      Value<int> levelId,
      Value<bool> isDaily,
      Value<int> seconds,
      Value<int> stars,
      Value<DateTime> at,
    });

class $$PlayHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $PlayHistoryTable> {
  $$PlayHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get puzzleKey => $composableBuilder(
    column: $table.puzzleKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get levelId => $composableBuilder(
    column: $table.levelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDaily => $composableBuilder(
    column: $table.isDaily,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seconds => $composableBuilder(
    column: $table.seconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stars => $composableBuilder(
    column: $table.stars,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlayHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $PlayHistoryTable> {
  $$PlayHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get puzzleKey => $composableBuilder(
    column: $table.puzzleKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get levelId => $composableBuilder(
    column: $table.levelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDaily => $composableBuilder(
    column: $table.isDaily,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seconds => $composableBuilder(
    column: $table.seconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stars => $composableBuilder(
    column: $table.stars,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlayHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlayHistoryTable> {
  $$PlayHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get puzzleKey =>
      $composableBuilder(column: $table.puzzleKey, builder: (column) => column);

  GeneratedColumn<int> get levelId =>
      $composableBuilder(column: $table.levelId, builder: (column) => column);

  GeneratedColumn<bool> get isDaily =>
      $composableBuilder(column: $table.isDaily, builder: (column) => column);

  GeneratedColumn<int> get seconds =>
      $composableBuilder(column: $table.seconds, builder: (column) => column);

  GeneratedColumn<int> get stars =>
      $composableBuilder(column: $table.stars, builder: (column) => column);

  GeneratedColumn<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);
}

class $$PlayHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlayHistoryTable,
          HistoryRow,
          $$PlayHistoryTableFilterComposer,
          $$PlayHistoryTableOrderingComposer,
          $$PlayHistoryTableAnnotationComposer,
          $$PlayHistoryTableCreateCompanionBuilder,
          $$PlayHistoryTableUpdateCompanionBuilder,
          (
            HistoryRow,
            BaseReferences<_$AppDatabase, $PlayHistoryTable, HistoryRow>,
          ),
          HistoryRow,
          PrefetchHooks Function()
        > {
  $$PlayHistoryTableTableManager(_$AppDatabase db, $PlayHistoryTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlayHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlayHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlayHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> puzzleKey = const Value.absent(),
                Value<int> levelId = const Value.absent(),
                Value<bool> isDaily = const Value.absent(),
                Value<int> seconds = const Value.absent(),
                Value<int> stars = const Value.absent(),
                Value<DateTime> at = const Value.absent(),
              }) => PlayHistoryCompanion(
                id: id,
                puzzleKey: puzzleKey,
                levelId: levelId,
                isDaily: isDaily,
                seconds: seconds,
                stars: stars,
                at: at,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String puzzleKey,
                required int levelId,
                Value<bool> isDaily = const Value.absent(),
                required int seconds,
                required int stars,
                required DateTime at,
              }) => PlayHistoryCompanion.insert(
                id: id,
                puzzleKey: puzzleKey,
                levelId: levelId,
                isDaily: isDaily,
                seconds: seconds,
                stars: stars,
                at: at,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlayHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlayHistoryTable,
      HistoryRow,
      $$PlayHistoryTableFilterComposer,
      $$PlayHistoryTableOrderingComposer,
      $$PlayHistoryTableAnnotationComposer,
      $$PlayHistoryTableCreateCompanionBuilder,
      $$PlayHistoryTableUpdateCompanionBuilder,
      (
        HistoryRow,
        BaseReferences<_$AppDatabase, $PlayHistoryTable, HistoryRow>,
      ),
      HistoryRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PlayerProfilesTableTableManager get playerProfiles =>
      $$PlayerProfilesTableTableManager(_db, _db.playerProfiles);
  $$PuzzleProgressTableTableManager get puzzleProgress =>
      $$PuzzleProgressTableTableManager(_db, _db.puzzleProgress);
  $$ActivePuzzlesTableTableManager get activePuzzles =>
      $$ActivePuzzlesTableTableManager(_db, _db.activePuzzles);
  $$PuzzleFavoritesTableTableManager get puzzleFavorites =>
      $$PuzzleFavoritesTableTableManager(_db, _db.puzzleFavorites);
  $$DailyPuzzlesTableTableManager get dailyPuzzles =>
      $$DailyPuzzlesTableTableManager(_db, _db.dailyPuzzles);
  $$AchievementStatesTableTableManager get achievementStates =>
      $$AchievementStatesTableTableManager(_db, _db.achievementStates);
  $$RewardTransactionsTableTableManager get rewardTransactions =>
      $$RewardTransactionsTableTableManager(_db, _db.rewardTransactions);
  $$PlayHistoryTableTableManager get playHistory =>
      $$PlayHistoryTableTableManager(_db, _db.playHistory);
}
