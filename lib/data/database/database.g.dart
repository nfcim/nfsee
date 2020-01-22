// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps, unnecessary_this
class DumpedRecord extends DataClass implements Insertable<DumpedRecord> {
  final int id;
  final DateTime time;
  final String data;
  DumpedRecord({@required this.id, @required this.time, @required this.data});
  factory DumpedRecord.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final intType = db.typeSystem.forDartType<int>();
    final dateTimeType = db.typeSystem.forDartType<DateTime>();
    final stringType = db.typeSystem.forDartType<String>();
    return DumpedRecord(
      id: intType.mapFromDatabaseResponse(data['${effectivePrefix}id']),
      time:
          dateTimeType.mapFromDatabaseResponse(data['${effectivePrefix}time']),
      data: stringType.mapFromDatabaseResponse(data['${effectivePrefix}data']),
    );
  }
  factory DumpedRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return DumpedRecord(
      id: serializer.fromJson<int>(json['id']),
      time: serializer.fromJson<DateTime>(json['time']),
      data: serializer.fromJson<String>(json['data']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'time': serializer.toJson<DateTime>(time),
      'data': serializer.toJson<String>(data),
    };
  }

  @override
  DumpedRecordsCompanion createCompanion(bool nullToAbsent) {
    return DumpedRecordsCompanion(
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      time: time == null && nullToAbsent ? const Value.absent() : Value(time),
      data: data == null && nullToAbsent ? const Value.absent() : Value(data),
    );
  }

  DumpedRecord copyWith({int id, DateTime time, String data}) => DumpedRecord(
        id: id ?? this.id,
        time: time ?? this.time,
        data: data ?? this.data,
      );
  @override
  String toString() {
    return (StringBuffer('DumpedRecord(')
          ..write('id: $id, ')
          ..write('time: $time, ')
          ..write('data: $data')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      $mrjf($mrjc(id.hashCode, $mrjc(time.hashCode, data.hashCode)));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is DumpedRecord &&
          other.id == this.id &&
          other.time == this.time &&
          other.data == this.data);
}

class DumpedRecordsCompanion extends UpdateCompanion<DumpedRecord> {
  final Value<int> id;
  final Value<DateTime> time;
  final Value<String> data;
  const DumpedRecordsCompanion({
    this.id = const Value.absent(),
    this.time = const Value.absent(),
    this.data = const Value.absent(),
  });
  DumpedRecordsCompanion.insert({
    this.id = const Value.absent(),
    @required DateTime time,
    @required String data,
  })  : time = Value(time),
        data = Value(data);
  DumpedRecordsCompanion copyWith(
      {Value<int> id, Value<DateTime> time, Value<String> data}) {
    return DumpedRecordsCompanion(
      id: id ?? this.id,
      time: time ?? this.time,
      data: data ?? this.data,
    );
  }
}

class $DumpedRecordsTable extends DumpedRecords
    with TableInfo<$DumpedRecordsTable, DumpedRecord> {
  final GeneratedDatabase _db;
  final String _alias;
  $DumpedRecordsTable(this._db, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  GeneratedIntColumn _id;
  @override
  GeneratedIntColumn get id => _id ??= _constructId();
  GeneratedIntColumn _constructId() {
    return GeneratedIntColumn('id', $tableName, false,
        hasAutoIncrement: true, declaredAsPrimaryKey: true);
  }

  final VerificationMeta _timeMeta = const VerificationMeta('time');
  GeneratedDateTimeColumn _time;
  @override
  GeneratedDateTimeColumn get time => _time ??= _constructTime();
  GeneratedDateTimeColumn _constructTime() {
    return GeneratedDateTimeColumn(
      'time',
      $tableName,
      false,
    );
  }

  final VerificationMeta _dataMeta = const VerificationMeta('data');
  GeneratedTextColumn _data;
  @override
  GeneratedTextColumn get data => _data ??= _constructData();
  GeneratedTextColumn _constructData() {
    return GeneratedTextColumn(
      'data',
      $tableName,
      false,
    );
  }

  @override
  List<GeneratedColumn> get $columns => [id, time, data];
  @override
  $DumpedRecordsTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'dumped_records';
  @override
  final String actualTableName = 'dumped_records';
  @override
  VerificationContext validateIntegrity(DumpedRecordsCompanion d,
      {bool isInserting = false}) {
    final context = VerificationContext();
    if (d.id.present) {
      context.handle(_idMeta, id.isAcceptableValue(d.id.value, _idMeta));
    }
    if (d.time.present) {
      context.handle(
          _timeMeta, time.isAcceptableValue(d.time.value, _timeMeta));
    } else if (isInserting) {
      context.missing(_timeMeta);
    }
    if (d.data.present) {
      context.handle(
          _dataMeta, data.isAcceptableValue(d.data.value, _dataMeta));
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DumpedRecord map(Map<String, dynamic> data, {String tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return DumpedRecord.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  Map<String, Variable> entityToSql(DumpedRecordsCompanion d) {
    final map = <String, Variable>{};
    if (d.id.present) {
      map['id'] = Variable<int, IntType>(d.id.value);
    }
    if (d.time.present) {
      map['time'] = Variable<DateTime, DateTimeType>(d.time.value);
    }
    if (d.data.present) {
      map['data'] = Variable<String, StringType>(d.data.value);
    }
    return map;
  }

  @override
  $DumpedRecordsTable createAlias(String alias) {
    return $DumpedRecordsTable(_db, alias);
  }
}

abstract class _$Database extends GeneratedDatabase {
  _$Database(QueryExecutor e) : super(SqlTypeSystem.defaultInstance, e);
  $DumpedRecordsTable _dumpedRecords;
  $DumpedRecordsTable get dumpedRecords =>
      _dumpedRecords ??= $DumpedRecordsTable(this);
  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [dumpedRecords];
}
