// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps, unnecessary_this
class DumpedRecord extends DataClass implements Insertable<DumpedRecord> {
  final int id;
  final DateTime time;
  final String config;
  final String data;
  DumpedRecord(
      {required this.id,
      required this.time,
      required this.config,
      required this.data});
  factory DumpedRecord.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return DumpedRecord(
      id: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      time: const DateTimeType()
          .mapFromDatabaseResponse(data['${effectivePrefix}time'])!,
      config: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}config'])!,
      data: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}data'])!,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['time'] = Variable<DateTime>(time);
    map['config'] = Variable<String>(config);
    map['data'] = Variable<String>(data);
    return map;
  }

  DumpedRecordsCompanion toCompanion(bool nullToAbsent) {
    return DumpedRecordsCompanion(
      id: Value(id),
      time: Value(time),
      config: Value(config),
      data: Value(data),
    );
  }

  factory DumpedRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return DumpedRecord(
      id: serializer.fromJson<int>(json['id']),
      time: serializer.fromJson<DateTime>(json['time']),
      config: serializer.fromJson<String>(json['config']),
      data: serializer.fromJson<String>(json['data']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'time': serializer.toJson<DateTime>(time),
      'config': serializer.toJson<String>(config),
      'data': serializer.toJson<String>(data),
    };
  }

  DumpedRecord copyWith(
          {int? id, DateTime? time, String? config, String? data}) =>
      DumpedRecord(
        id: id ?? this.id,
        time: time ?? this.time,
        config: config ?? this.config,
        data: data ?? this.data,
      );
  @override
  String toString() {
    return (StringBuffer('DumpedRecord(')
          ..write('id: $id, ')
          ..write('time: $time, ')
          ..write('config: $config, ')
          ..write('data: $data')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, time, config, data);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DumpedRecord &&
          other.id == this.id &&
          other.time == this.time &&
          other.config == this.config &&
          other.data == this.data);
}

class DumpedRecordsCompanion extends UpdateCompanion<DumpedRecord> {
  final Value<int> id;
  final Value<DateTime> time;
  final Value<String> config;
  final Value<String> data;
  const DumpedRecordsCompanion({
    this.id = const Value.absent(),
    this.time = const Value.absent(),
    this.config = const Value.absent(),
    this.data = const Value.absent(),
  });
  DumpedRecordsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime time,
    this.config = const Value.absent(),
    required String data,
  })  : time = Value(time),
        data = Value(data);
  static Insertable<DumpedRecord> custom({
    Expression<int>? id,
    Expression<DateTime>? time,
    Expression<String>? config,
    Expression<String>? data,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (time != null) 'time': time,
      if (config != null) 'config': config,
      if (data != null) 'data': data,
    });
  }

  DumpedRecordsCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? time,
      Value<String>? config,
      Value<String>? data}) {
    return DumpedRecordsCompanion(
      id: id ?? this.id,
      time: time ?? this.time,
      config: config ?? this.config,
      data: data ?? this.data,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (time.present) {
      map['time'] = Variable<DateTime>(time.value);
    }
    if (config.present) {
      map['config'] = Variable<String>(config.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DumpedRecordsCompanion(')
          ..write('id: $id, ')
          ..write('time: $time, ')
          ..write('config: $config, ')
          ..write('data: $data')
          ..write(')'))
        .toString();
  }
}

class $DumpedRecordsTable extends DumpedRecords
    with TableInfo<$DumpedRecordsTable, DumpedRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DumpedRecordsTable(this.attachedDatabase, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int?> id = GeneratedColumn<int?>(
      'id', aliasedName, false,
      type: const IntType(),
      requiredDuringInsert: false,
      defaultConstraints: 'PRIMARY KEY AUTOINCREMENT');
  final VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumn<DateTime?> time = GeneratedColumn<DateTime?>(
      'time', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  final VerificationMeta _configMeta = const VerificationMeta('config');
  @override
  late final GeneratedColumn<String?> config = GeneratedColumn<String?>(
      'config', aliasedName, false,
      type: const StringType(),
      requiredDuringInsert: false,
      defaultValue: const Constant(DEFAULT_CONFIG));
  final VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String?> data = GeneratedColumn<String?>(
      'data', aliasedName, false,
      type: const StringType(), requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, time, config, data];
  @override
  String get aliasedName => _alias ?? 'dumped_records';
  @override
  String get actualTableName => 'dumped_records';
  @override
  VerificationContext validateIntegrity(Insertable<DumpedRecord> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('time')) {
      context.handle(
          _timeMeta, time.isAcceptableOrUnknown(data['time']!, _timeMeta));
    } else if (isInserting) {
      context.missing(_timeMeta);
    }
    if (data.containsKey('config')) {
      context.handle(_configMeta,
          config.isAcceptableOrUnknown(data['config']!, _configMeta));
    }
    if (data.containsKey('data')) {
      context.handle(
          _dataMeta, this.data.isAcceptableOrUnknown(data['data']!, _dataMeta));
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DumpedRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    return DumpedRecord.fromData(data, attachedDatabase,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $DumpedRecordsTable createAlias(String alias) {
    return $DumpedRecordsTable(attachedDatabase, alias);
  }
}

class SavedScript extends DataClass implements Insertable<SavedScript> {
  final int id;
  final String name;
  final String source;
  final DateTime creationTime;
  final DateTime? lastUsed;
  SavedScript(
      {required this.id,
      required this.name,
      required this.source,
      required this.creationTime,
      this.lastUsed});
  factory SavedScript.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return SavedScript(
      id: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      name: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}name'])!,
      source: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}source'])!,
      creationTime: const DateTimeType()
          .mapFromDatabaseResponse(data['${effectivePrefix}creation_time'])!,
      lastUsed: const DateTimeType()
          .mapFromDatabaseResponse(data['${effectivePrefix}last_used']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['source'] = Variable<String>(source);
    map['creation_time'] = Variable<DateTime>(creationTime);
    if (!nullToAbsent || lastUsed != null) {
      map['last_used'] = Variable<DateTime?>(lastUsed);
    }
    return map;
  }

  SavedScriptsCompanion toCompanion(bool nullToAbsent) {
    return SavedScriptsCompanion(
      id: Value(id),
      name: Value(name),
      source: Value(source),
      creationTime: Value(creationTime),
      lastUsed: lastUsed == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUsed),
    );
  }

  factory SavedScript.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return SavedScript(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      source: serializer.fromJson<String>(json['source']),
      creationTime: serializer.fromJson<DateTime>(json['creationTime']),
      lastUsed: serializer.fromJson<DateTime?>(json['lastUsed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'source': serializer.toJson<String>(source),
      'creationTime': serializer.toJson<DateTime>(creationTime),
      'lastUsed': serializer.toJson<DateTime?>(lastUsed),
    };
  }

  SavedScript copyWith(
          {int? id,
          String? name,
          String? source,
          DateTime? creationTime,
          DateTime? lastUsed}) =>
      SavedScript(
        id: id ?? this.id,
        name: name ?? this.name,
        source: source ?? this.source,
        creationTime: creationTime ?? this.creationTime,
        lastUsed: lastUsed ?? this.lastUsed,
      );
  @override
  String toString() {
    return (StringBuffer('SavedScript(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('source: $source, ')
          ..write('creationTime: $creationTime, ')
          ..write('lastUsed: $lastUsed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, source, creationTime, lastUsed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedScript &&
          other.id == this.id &&
          other.name == this.name &&
          other.source == this.source &&
          other.creationTime == this.creationTime &&
          other.lastUsed == this.lastUsed);
}

class SavedScriptsCompanion extends UpdateCompanion<SavedScript> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> source;
  final Value<DateTime> creationTime;
  final Value<DateTime?> lastUsed;
  const SavedScriptsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.source = const Value.absent(),
    this.creationTime = const Value.absent(),
    this.lastUsed = const Value.absent(),
  });
  SavedScriptsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String source,
    required DateTime creationTime,
    this.lastUsed = const Value.absent(),
  })  : name = Value(name),
        source = Value(source),
        creationTime = Value(creationTime);
  static Insertable<SavedScript> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? source,
    Expression<DateTime>? creationTime,
    Expression<DateTime?>? lastUsed,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (source != null) 'source': source,
      if (creationTime != null) 'creation_time': creationTime,
      if (lastUsed != null) 'last_used': lastUsed,
    });
  }

  SavedScriptsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? source,
      Value<DateTime>? creationTime,
      Value<DateTime?>? lastUsed}) {
    return SavedScriptsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      source: source ?? this.source,
      creationTime: creationTime ?? this.creationTime,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (creationTime.present) {
      map['creation_time'] = Variable<DateTime>(creationTime.value);
    }
    if (lastUsed.present) {
      map['last_used'] = Variable<DateTime?>(lastUsed.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedScriptsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('source: $source, ')
          ..write('creationTime: $creationTime, ')
          ..write('lastUsed: $lastUsed')
          ..write(')'))
        .toString();
  }
}

class $SavedScriptsTable extends SavedScripts
    with TableInfo<$SavedScriptsTable, SavedScript> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedScriptsTable(this.attachedDatabase, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int?> id = GeneratedColumn<int?>(
      'id', aliasedName, false,
      type: const IntType(),
      requiredDuringInsert: false,
      defaultConstraints: 'PRIMARY KEY AUTOINCREMENT');
  final VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String?> name = GeneratedColumn<String?>(
      'name', aliasedName, false,
      type: const StringType(), requiredDuringInsert: true);
  final VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String?> source = GeneratedColumn<String?>(
      'source', aliasedName, false,
      type: const StringType(), requiredDuringInsert: true);
  final VerificationMeta _creationTimeMeta =
      const VerificationMeta('creationTime');
  @override
  late final GeneratedColumn<DateTime?> creationTime =
      GeneratedColumn<DateTime?>('creation_time', aliasedName, false,
          type: const IntType(), requiredDuringInsert: true);
  final VerificationMeta _lastUsedMeta = const VerificationMeta('lastUsed');
  @override
  late final GeneratedColumn<DateTime?> lastUsed = GeneratedColumn<DateTime?>(
      'last_used', aliasedName, true,
      type: const IntType(), requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, source, creationTime, lastUsed];
  @override
  String get aliasedName => _alias ?? 'saved_scripts';
  @override
  String get actualTableName => 'saved_scripts';
  @override
  VerificationContext validateIntegrity(Insertable<SavedScript> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('creation_time')) {
      context.handle(
          _creationTimeMeta,
          creationTime.isAcceptableOrUnknown(
              data['creation_time']!, _creationTimeMeta));
    } else if (isInserting) {
      context.missing(_creationTimeMeta);
    }
    if (data.containsKey('last_used')) {
      context.handle(_lastUsedMeta,
          lastUsed.isAcceptableOrUnknown(data['last_used']!, _lastUsedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavedScript map(Map<String, dynamic> data, {String? tablePrefix}) {
    return SavedScript.fromData(data, attachedDatabase,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $SavedScriptsTable createAlias(String alias) {
    return $SavedScriptsTable(attachedDatabase, alias);
  }
}

abstract class _$Database extends GeneratedDatabase {
  _$Database(QueryExecutor e) : super(SqlTypeSystem.defaultInstance, e);
  late final $DumpedRecordsTable dumpedRecords = $DumpedRecordsTable(this);
  late final $SavedScriptsTable savedScripts = $SavedScriptsTable(this);
  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [dumpedRecords, savedScripts];
}
