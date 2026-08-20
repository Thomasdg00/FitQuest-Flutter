// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $WorkoutRecordsTable extends WorkoutRecords
    with TableInfo<$WorkoutRecordsTable, WorkoutRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutRecordsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _distanceMetersMeta = const VerificationMeta(
    'distanceMeters',
  );
  @override
  late final GeneratedColumn<double> distanceMeters = GeneratedColumn<double>(
    'distance_meters',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    startedAt,
    durationSeconds,
    distanceMeters,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workouts';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationSecondsMeta);
    }
    if (data.containsKey('distance_meters')) {
      context.handle(
        _distanceMetersMeta,
        distanceMeters.isAcceptableOrUnknown(
          data['distance_meters']!,
          _distanceMetersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_distanceMetersMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      )!,
      distanceMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance_meters'],
      )!,
    );
  }

  @override
  $WorkoutRecordsTable createAlias(String alias) {
    return $WorkoutRecordsTable(attachedDatabase, alias);
  }
}

class WorkoutRecord extends DataClass implements Insertable<WorkoutRecord> {
  final int id;
  final DateTime startedAt;
  final int durationSeconds;
  final double distanceMeters;
  const WorkoutRecord({
    required this.id,
    required this.startedAt,
    required this.durationSeconds,
    required this.distanceMeters,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['started_at'] = Variable<DateTime>(startedAt);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['distance_meters'] = Variable<double>(distanceMeters);
    return map;
  }

  WorkoutRecordsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutRecordsCompanion(
      id: Value(id),
      startedAt: Value(startedAt),
      durationSeconds: Value(durationSeconds),
      distanceMeters: Value(distanceMeters),
    );
  }

  factory WorkoutRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutRecord(
      id: serializer.fromJson<int>(json['id']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      distanceMeters: serializer.fromJson<double>(json['distanceMeters']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'distanceMeters': serializer.toJson<double>(distanceMeters),
    };
  }

  WorkoutRecord copyWith({
    int? id,
    DateTime? startedAt,
    int? durationSeconds,
    double? distanceMeters,
  }) => WorkoutRecord(
    id: id ?? this.id,
    startedAt: startedAt ?? this.startedAt,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    distanceMeters: distanceMeters ?? this.distanceMeters,
  );
  WorkoutRecord copyWithCompanion(WorkoutRecordsCompanion data) {
    return WorkoutRecord(
      id: data.id.present ? data.id.value : this.id,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      distanceMeters: data.distanceMeters.present
          ? data.distanceMeters.value
          : this.distanceMeters,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutRecord(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('distanceMeters: $distanceMeters')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, startedAt, durationSeconds, distanceMeters);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutRecord &&
          other.id == this.id &&
          other.startedAt == this.startedAt &&
          other.durationSeconds == this.durationSeconds &&
          other.distanceMeters == this.distanceMeters);
}

class WorkoutRecordsCompanion extends UpdateCompanion<WorkoutRecord> {
  final Value<int> id;
  final Value<DateTime> startedAt;
  final Value<int> durationSeconds;
  final Value<double> distanceMeters;
  const WorkoutRecordsCompanion({
    this.id = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.distanceMeters = const Value.absent(),
  });
  WorkoutRecordsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime startedAt,
    required int durationSeconds,
    required double distanceMeters,
  }) : startedAt = Value(startedAt),
       durationSeconds = Value(durationSeconds),
       distanceMeters = Value(distanceMeters);
  static Insertable<WorkoutRecord> custom({
    Expression<int>? id,
    Expression<DateTime>? startedAt,
    Expression<int>? durationSeconds,
    Expression<double>? distanceMeters,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startedAt != null) 'started_at': startedAt,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (distanceMeters != null) 'distance_meters': distanceMeters,
    });
  }

  WorkoutRecordsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? startedAt,
    Value<int>? durationSeconds,
    Value<double>? distanceMeters,
  }) {
    return WorkoutRecordsCompanion(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      distanceMeters: distanceMeters ?? this.distanceMeters,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (distanceMeters.present) {
      map['distance_meters'] = Variable<double>(distanceMeters.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutRecordsCompanion(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('distanceMeters: $distanceMeters')
          ..write(')'))
        .toString();
  }
}

class $RoutePointRecordsTable extends RoutePointRecords
    with TableInfo<$RoutePointRecordsTable, RoutePointRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutePointRecordsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _workoutIdMeta = const VerificationMeta(
    'workoutId',
  );
  @override
  late final GeneratedColumn<int> workoutId = GeneratedColumn<int>(
    'workout_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES workouts(id) ON DELETE CASCADE',
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workoutId,
    latitude,
    longitude,
    timestamp,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'route_points';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoutePointRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('workout_id')) {
      context.handle(
        _workoutIdMeta,
        workoutId.isAcceptableOrUnknown(data['workout_id']!, _workoutIdMeta),
      );
    } else if (isInserting) {
      context.missing(_workoutIdMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RoutePointRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoutePointRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      workoutId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}workout_id'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
    );
  }

  @override
  $RoutePointRecordsTable createAlias(String alias) {
    return $RoutePointRecordsTable(attachedDatabase, alias);
  }
}

class RoutePointRecord extends DataClass
    implements Insertable<RoutePointRecord> {
  final int id;
  final int workoutId;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  const RoutePointRecord({
    required this.id,
    required this.workoutId,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['workout_id'] = Variable<int>(workoutId);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['timestamp'] = Variable<DateTime>(timestamp);
    return map;
  }

  RoutePointRecordsCompanion toCompanion(bool nullToAbsent) {
    return RoutePointRecordsCompanion(
      id: Value(id),
      workoutId: Value(workoutId),
      latitude: Value(latitude),
      longitude: Value(longitude),
      timestamp: Value(timestamp),
    );
  }

  factory RoutePointRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoutePointRecord(
      id: serializer.fromJson<int>(json['id']),
      workoutId: serializer.fromJson<int>(json['workoutId']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'workoutId': serializer.toJson<int>(workoutId),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  RoutePointRecord copyWith({
    int? id,
    int? workoutId,
    double? latitude,
    double? longitude,
    DateTime? timestamp,
  }) => RoutePointRecord(
    id: id ?? this.id,
    workoutId: workoutId ?? this.workoutId,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    timestamp: timestamp ?? this.timestamp,
  );
  RoutePointRecord copyWithCompanion(RoutePointRecordsCompanion data) {
    return RoutePointRecord(
      id: data.id.present ? data.id.value : this.id,
      workoutId: data.workoutId.present ? data.workoutId.value : this.workoutId,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoutePointRecord(')
          ..write('id: $id, ')
          ..write('workoutId: $workoutId, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, workoutId, latitude, longitude, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoutePointRecord &&
          other.id == this.id &&
          other.workoutId == this.workoutId &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.timestamp == this.timestamp);
}

class RoutePointRecordsCompanion extends UpdateCompanion<RoutePointRecord> {
  final Value<int> id;
  final Value<int> workoutId;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<DateTime> timestamp;
  const RoutePointRecordsCompanion({
    this.id = const Value.absent(),
    this.workoutId = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.timestamp = const Value.absent(),
  });
  RoutePointRecordsCompanion.insert({
    this.id = const Value.absent(),
    required int workoutId,
    required double latitude,
    required double longitude,
    required DateTime timestamp,
  }) : workoutId = Value(workoutId),
       latitude = Value(latitude),
       longitude = Value(longitude),
       timestamp = Value(timestamp);
  static Insertable<RoutePointRecord> custom({
    Expression<int>? id,
    Expression<int>? workoutId,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<DateTime>? timestamp,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workoutId != null) 'workout_id': workoutId,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (timestamp != null) 'timestamp': timestamp,
    });
  }

  RoutePointRecordsCompanion copyWith({
    Value<int>? id,
    Value<int>? workoutId,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<DateTime>? timestamp,
  }) {
    return RoutePointRecordsCompanion(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (workoutId.present) {
      map['workout_id'] = Variable<int>(workoutId.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutePointRecordsCompanion(')
          ..write('id: $id, ')
          ..write('workoutId: $workoutId, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }
}

class $WeeklyGoalRecordsTable extends WeeklyGoalRecords
    with TableInfo<$WeeklyGoalRecordsTable, WeeklyGoalRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WeeklyGoalRecordsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _weekStartDateMeta = const VerificationMeta(
    'weekStartDate',
  );
  @override
  late final GeneratedColumn<DateTime> weekStartDate =
      GeneratedColumn<DateTime>(
        'week_start_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _targetDistanceMetersMeta =
      const VerificationMeta('targetDistanceMeters');
  @override
  late final GeneratedColumn<double> targetDistanceMeters =
      GeneratedColumn<double>(
        'target_distance_meters',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    weekStartDate,
    targetDistanceMeters,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'weekly_goals';
  @override
  VerificationContext validateIntegrity(
    Insertable<WeeklyGoalRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('week_start_date')) {
      context.handle(
        _weekStartDateMeta,
        weekStartDate.isAcceptableOrUnknown(
          data['week_start_date']!,
          _weekStartDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_weekStartDateMeta);
    }
    if (data.containsKey('target_distance_meters')) {
      context.handle(
        _targetDistanceMetersMeta,
        targetDistanceMeters.isAcceptableOrUnknown(
          data['target_distance_meters']!,
          _targetDistanceMetersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetDistanceMetersMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WeeklyGoalRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WeeklyGoalRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      weekStartDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}week_start_date'],
      )!,
      targetDistanceMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_distance_meters'],
      )!,
    );
  }

  @override
  $WeeklyGoalRecordsTable createAlias(String alias) {
    return $WeeklyGoalRecordsTable(attachedDatabase, alias);
  }
}

class WeeklyGoalRecord extends DataClass
    implements Insertable<WeeklyGoalRecord> {
  final int id;
  final DateTime weekStartDate;
  final double targetDistanceMeters;
  const WeeklyGoalRecord({
    required this.id,
    required this.weekStartDate,
    required this.targetDistanceMeters,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['week_start_date'] = Variable<DateTime>(weekStartDate);
    map['target_distance_meters'] = Variable<double>(targetDistanceMeters);
    return map;
  }

  WeeklyGoalRecordsCompanion toCompanion(bool nullToAbsent) {
    return WeeklyGoalRecordsCompanion(
      id: Value(id),
      weekStartDate: Value(weekStartDate),
      targetDistanceMeters: Value(targetDistanceMeters),
    );
  }

  factory WeeklyGoalRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WeeklyGoalRecord(
      id: serializer.fromJson<int>(json['id']),
      weekStartDate: serializer.fromJson<DateTime>(json['weekStartDate']),
      targetDistanceMeters: serializer.fromJson<double>(
        json['targetDistanceMeters'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'weekStartDate': serializer.toJson<DateTime>(weekStartDate),
      'targetDistanceMeters': serializer.toJson<double>(targetDistanceMeters),
    };
  }

  WeeklyGoalRecord copyWith({
    int? id,
    DateTime? weekStartDate,
    double? targetDistanceMeters,
  }) => WeeklyGoalRecord(
    id: id ?? this.id,
    weekStartDate: weekStartDate ?? this.weekStartDate,
    targetDistanceMeters: targetDistanceMeters ?? this.targetDistanceMeters,
  );
  WeeklyGoalRecord copyWithCompanion(WeeklyGoalRecordsCompanion data) {
    return WeeklyGoalRecord(
      id: data.id.present ? data.id.value : this.id,
      weekStartDate: data.weekStartDate.present
          ? data.weekStartDate.value
          : this.weekStartDate,
      targetDistanceMeters: data.targetDistanceMeters.present
          ? data.targetDistanceMeters.value
          : this.targetDistanceMeters,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WeeklyGoalRecord(')
          ..write('id: $id, ')
          ..write('weekStartDate: $weekStartDate, ')
          ..write('targetDistanceMeters: $targetDistanceMeters')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, weekStartDate, targetDistanceMeters);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WeeklyGoalRecord &&
          other.id == this.id &&
          other.weekStartDate == this.weekStartDate &&
          other.targetDistanceMeters == this.targetDistanceMeters);
}

class WeeklyGoalRecordsCompanion extends UpdateCompanion<WeeklyGoalRecord> {
  final Value<int> id;
  final Value<DateTime> weekStartDate;
  final Value<double> targetDistanceMeters;
  const WeeklyGoalRecordsCompanion({
    this.id = const Value.absent(),
    this.weekStartDate = const Value.absent(),
    this.targetDistanceMeters = const Value.absent(),
  });
  WeeklyGoalRecordsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime weekStartDate,
    required double targetDistanceMeters,
  }) : weekStartDate = Value(weekStartDate),
       targetDistanceMeters = Value(targetDistanceMeters);
  static Insertable<WeeklyGoalRecord> custom({
    Expression<int>? id,
    Expression<DateTime>? weekStartDate,
    Expression<double>? targetDistanceMeters,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (weekStartDate != null) 'week_start_date': weekStartDate,
      if (targetDistanceMeters != null)
        'target_distance_meters': targetDistanceMeters,
    });
  }

  WeeklyGoalRecordsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? weekStartDate,
    Value<double>? targetDistanceMeters,
  }) {
    return WeeklyGoalRecordsCompanion(
      id: id ?? this.id,
      weekStartDate: weekStartDate ?? this.weekStartDate,
      targetDistanceMeters: targetDistanceMeters ?? this.targetDistanceMeters,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (weekStartDate.present) {
      map['week_start_date'] = Variable<DateTime>(weekStartDate.value);
    }
    if (targetDistanceMeters.present) {
      map['target_distance_meters'] = Variable<double>(
        targetDistanceMeters.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WeeklyGoalRecordsCompanion(')
          ..write('id: $id, ')
          ..write('weekStartDate: $weekStartDate, ')
          ..write('targetDistanceMeters: $targetDistanceMeters')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $WorkoutRecordsTable workoutRecords = $WorkoutRecordsTable(this);
  late final $RoutePointRecordsTable routePointRecords =
      $RoutePointRecordsTable(this);
  late final $WeeklyGoalRecordsTable weeklyGoalRecords =
      $WeeklyGoalRecordsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    workoutRecords,
    routePointRecords,
    weeklyGoalRecords,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'workouts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('route_points', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$WorkoutRecordsTableCreateCompanionBuilder =
    WorkoutRecordsCompanion Function({
      Value<int> id,
      required DateTime startedAt,
      required int durationSeconds,
      required double distanceMeters,
    });
typedef $$WorkoutRecordsTableUpdateCompanionBuilder =
    WorkoutRecordsCompanion Function({
      Value<int> id,
      Value<DateTime> startedAt,
      Value<int> durationSeconds,
      Value<double> distanceMeters,
    });

final class $$WorkoutRecordsTableReferences
    extends BaseReferences<_$AppDatabase, $WorkoutRecordsTable, WorkoutRecord> {
  $$WorkoutRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$RoutePointRecordsTable, List<RoutePointRecord>>
  _routePointRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.routePointRecords,
        aliasName: $_aliasNameGenerator(
          db.workoutRecords.id,
          db.routePointRecords.workoutId,
        ),
      );

  $$RoutePointRecordsTableProcessedTableManager get routePointRecordsRefs {
    final manager = $$RoutePointRecordsTableTableManager(
      $_db,
      $_db.routePointRecords,
    ).filter((f) => f.workoutId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _routePointRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WorkoutRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutRecordsTable> {
  $$WorkoutRecordsTableFilterComposer({
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

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> routePointRecordsRefs(
    Expression<bool> Function($$RoutePointRecordsTableFilterComposer f) f,
  ) {
    final $$RoutePointRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routePointRecords,
      getReferencedColumn: (t) => t.workoutId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutePointRecordsTableFilterComposer(
            $db: $db,
            $table: $db.routePointRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkoutRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutRecordsTable> {
  $$WorkoutRecordsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkoutRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutRecordsTable> {
  $$WorkoutRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => column,
  );

  Expression<T> routePointRecordsRefs<T extends Object>(
    Expression<T> Function($$RoutePointRecordsTableAnnotationComposer a) f,
  ) {
    final $$RoutePointRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.routePointRecords,
          getReferencedColumn: (t) => t.workoutId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RoutePointRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.routePointRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$WorkoutRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutRecordsTable,
          WorkoutRecord,
          $$WorkoutRecordsTableFilterComposer,
          $$WorkoutRecordsTableOrderingComposer,
          $$WorkoutRecordsTableAnnotationComposer,
          $$WorkoutRecordsTableCreateCompanionBuilder,
          $$WorkoutRecordsTableUpdateCompanionBuilder,
          (WorkoutRecord, $$WorkoutRecordsTableReferences),
          WorkoutRecord,
          PrefetchHooks Function({bool routePointRecordsRefs})
        > {
  $$WorkoutRecordsTableTableManager(
    _$AppDatabase db,
    $WorkoutRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<double> distanceMeters = const Value.absent(),
              }) => WorkoutRecordsCompanion(
                id: id,
                startedAt: startedAt,
                durationSeconds: durationSeconds,
                distanceMeters: distanceMeters,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime startedAt,
                required int durationSeconds,
                required double distanceMeters,
              }) => WorkoutRecordsCompanion.insert(
                id: id,
                startedAt: startedAt,
                durationSeconds: durationSeconds,
                distanceMeters: distanceMeters,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WorkoutRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({routePointRecordsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (routePointRecordsRefs) db.routePointRecords,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (routePointRecordsRefs)
                    await $_getPrefetchedData<
                      WorkoutRecord,
                      $WorkoutRecordsTable,
                      RoutePointRecord
                    >(
                      currentTable: table,
                      referencedTable: $$WorkoutRecordsTableReferences
                          ._routePointRecordsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$WorkoutRecordsTableReferences(
                            db,
                            table,
                            p0,
                          ).routePointRecordsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.workoutId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$WorkoutRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutRecordsTable,
      WorkoutRecord,
      $$WorkoutRecordsTableFilterComposer,
      $$WorkoutRecordsTableOrderingComposer,
      $$WorkoutRecordsTableAnnotationComposer,
      $$WorkoutRecordsTableCreateCompanionBuilder,
      $$WorkoutRecordsTableUpdateCompanionBuilder,
      (WorkoutRecord, $$WorkoutRecordsTableReferences),
      WorkoutRecord,
      PrefetchHooks Function({bool routePointRecordsRefs})
    >;
typedef $$RoutePointRecordsTableCreateCompanionBuilder =
    RoutePointRecordsCompanion Function({
      Value<int> id,
      required int workoutId,
      required double latitude,
      required double longitude,
      required DateTime timestamp,
    });
typedef $$RoutePointRecordsTableUpdateCompanionBuilder =
    RoutePointRecordsCompanion Function({
      Value<int> id,
      Value<int> workoutId,
      Value<double> latitude,
      Value<double> longitude,
      Value<DateTime> timestamp,
    });

final class $$RoutePointRecordsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $RoutePointRecordsTable,
          RoutePointRecord
        > {
  $$RoutePointRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkoutRecordsTable _workoutIdTable(_$AppDatabase db) =>
      db.workoutRecords.createAlias(
        $_aliasNameGenerator(
          db.routePointRecords.workoutId,
          db.workoutRecords.id,
        ),
      );

  $$WorkoutRecordsTableProcessedTableManager get workoutId {
    final $_column = $_itemColumn<int>('workout_id')!;

    final manager = $$WorkoutRecordsTableTableManager(
      $_db,
      $_db.workoutRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workoutIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RoutePointRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $RoutePointRecordsTable> {
  $$RoutePointRecordsTableFilterComposer({
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

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkoutRecordsTableFilterComposer get workoutId {
    final $$WorkoutRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutId,
      referencedTable: $db.workoutRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutRecordsTableFilterComposer(
            $db: $db,
            $table: $db.workoutRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutePointRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $RoutePointRecordsTable> {
  $$RoutePointRecordsTableOrderingComposer({
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

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkoutRecordsTableOrderingComposer get workoutId {
    final $$WorkoutRecordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutId,
      referencedTable: $db.workoutRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutRecordsTableOrderingComposer(
            $db: $db,
            $table: $db.workoutRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutePointRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoutePointRecordsTable> {
  $$RoutePointRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  $$WorkoutRecordsTableAnnotationComposer get workoutId {
    final $$WorkoutRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutId,
      referencedTable: $db.workoutRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.workoutRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutePointRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoutePointRecordsTable,
          RoutePointRecord,
          $$RoutePointRecordsTableFilterComposer,
          $$RoutePointRecordsTableOrderingComposer,
          $$RoutePointRecordsTableAnnotationComposer,
          $$RoutePointRecordsTableCreateCompanionBuilder,
          $$RoutePointRecordsTableUpdateCompanionBuilder,
          (RoutePointRecord, $$RoutePointRecordsTableReferences),
          RoutePointRecord,
          PrefetchHooks Function({bool workoutId})
        > {
  $$RoutePointRecordsTableTableManager(
    _$AppDatabase db,
    $RoutePointRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutePointRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutePointRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutePointRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> workoutId = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
              }) => RoutePointRecordsCompanion(
                id: id,
                workoutId: workoutId,
                latitude: latitude,
                longitude: longitude,
                timestamp: timestamp,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int workoutId,
                required double latitude,
                required double longitude,
                required DateTime timestamp,
              }) => RoutePointRecordsCompanion.insert(
                id: id,
                workoutId: workoutId,
                latitude: latitude,
                longitude: longitude,
                timestamp: timestamp,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RoutePointRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({workoutId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (workoutId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.workoutId,
                                referencedTable:
                                    $$RoutePointRecordsTableReferences
                                        ._workoutIdTable(db),
                                referencedColumn:
                                    $$RoutePointRecordsTableReferences
                                        ._workoutIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RoutePointRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoutePointRecordsTable,
      RoutePointRecord,
      $$RoutePointRecordsTableFilterComposer,
      $$RoutePointRecordsTableOrderingComposer,
      $$RoutePointRecordsTableAnnotationComposer,
      $$RoutePointRecordsTableCreateCompanionBuilder,
      $$RoutePointRecordsTableUpdateCompanionBuilder,
      (RoutePointRecord, $$RoutePointRecordsTableReferences),
      RoutePointRecord,
      PrefetchHooks Function({bool workoutId})
    >;
typedef $$WeeklyGoalRecordsTableCreateCompanionBuilder =
    WeeklyGoalRecordsCompanion Function({
      Value<int> id,
      required DateTime weekStartDate,
      required double targetDistanceMeters,
    });
typedef $$WeeklyGoalRecordsTableUpdateCompanionBuilder =
    WeeklyGoalRecordsCompanion Function({
      Value<int> id,
      Value<DateTime> weekStartDate,
      Value<double> targetDistanceMeters,
    });

class $$WeeklyGoalRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $WeeklyGoalRecordsTable> {
  $$WeeklyGoalRecordsTableFilterComposer({
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

  ColumnFilters<DateTime> get weekStartDate => $composableBuilder(
    column: $table.weekStartDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetDistanceMeters => $composableBuilder(
    column: $table.targetDistanceMeters,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WeeklyGoalRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $WeeklyGoalRecordsTable> {
  $$WeeklyGoalRecordsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get weekStartDate => $composableBuilder(
    column: $table.weekStartDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetDistanceMeters => $composableBuilder(
    column: $table.targetDistanceMeters,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WeeklyGoalRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WeeklyGoalRecordsTable> {
  $$WeeklyGoalRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get weekStartDate => $composableBuilder(
    column: $table.weekStartDate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get targetDistanceMeters => $composableBuilder(
    column: $table.targetDistanceMeters,
    builder: (column) => column,
  );
}

class $$WeeklyGoalRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WeeklyGoalRecordsTable,
          WeeklyGoalRecord,
          $$WeeklyGoalRecordsTableFilterComposer,
          $$WeeklyGoalRecordsTableOrderingComposer,
          $$WeeklyGoalRecordsTableAnnotationComposer,
          $$WeeklyGoalRecordsTableCreateCompanionBuilder,
          $$WeeklyGoalRecordsTableUpdateCompanionBuilder,
          (
            WeeklyGoalRecord,
            BaseReferences<
              _$AppDatabase,
              $WeeklyGoalRecordsTable,
              WeeklyGoalRecord
            >,
          ),
          WeeklyGoalRecord,
          PrefetchHooks Function()
        > {
  $$WeeklyGoalRecordsTableTableManager(
    _$AppDatabase db,
    $WeeklyGoalRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WeeklyGoalRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WeeklyGoalRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WeeklyGoalRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> weekStartDate = const Value.absent(),
                Value<double> targetDistanceMeters = const Value.absent(),
              }) => WeeklyGoalRecordsCompanion(
                id: id,
                weekStartDate: weekStartDate,
                targetDistanceMeters: targetDistanceMeters,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime weekStartDate,
                required double targetDistanceMeters,
              }) => WeeklyGoalRecordsCompanion.insert(
                id: id,
                weekStartDate: weekStartDate,
                targetDistanceMeters: targetDistanceMeters,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WeeklyGoalRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WeeklyGoalRecordsTable,
      WeeklyGoalRecord,
      $$WeeklyGoalRecordsTableFilterComposer,
      $$WeeklyGoalRecordsTableOrderingComposer,
      $$WeeklyGoalRecordsTableAnnotationComposer,
      $$WeeklyGoalRecordsTableCreateCompanionBuilder,
      $$WeeklyGoalRecordsTableUpdateCompanionBuilder,
      (
        WeeklyGoalRecord,
        BaseReferences<
          _$AppDatabase,
          $WeeklyGoalRecordsTable,
          WeeklyGoalRecord
        >,
      ),
      WeeklyGoalRecord,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$WorkoutRecordsTableTableManager get workoutRecords =>
      $$WorkoutRecordsTableTableManager(_db, _db.workoutRecords);
  $$RoutePointRecordsTableTableManager get routePointRecords =>
      $$RoutePointRecordsTableTableManager(_db, _db.routePointRecords);
  $$WeeklyGoalRecordsTableTableManager get weeklyGoalRecords =>
      $$WeeklyGoalRecordsTableTableManager(_db, _db.weeklyGoalRecords);
}
