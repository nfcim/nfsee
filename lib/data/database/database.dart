import 'dart:developer';
import 'dart:io';

import 'package:moor/ffi.dart';
import 'package:moor/moor.dart';
import 'package:nfsee/models.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

@DataClassName('DumpedRecord')
class DumpedRecords extends Table {
  IntColumn get id => integer().autoIncrement()();

  DateTimeColumn get time => dateTime()();

  TextColumn? get config => text()
      .withDefault(const Constant(DEFAULT_CONFIG))(); // Name, color, etc...
  TextColumn get data => text()();
}

@DataClassName('SavedScript')
class SavedScripts extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text()();

  TextColumn get source => text()();

  DateTimeColumn get creationTime => dateTime()();

  DateTimeColumn get lastUsed => dateTime().nullable()();
}

@UseMoor(
  tables: [DumpedRecords, SavedScripts],
)
class Database extends _$Database {
  Database(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
      onCreate: (Migrator m) => m.createAll(),
      onUpgrade: (Migrator m, int from, int to) async {
        log("Migrate db from $from to $to");
        if (from < 5) {
          await m.addColumn(dumpedRecords, dumpedRecords.config);
        }
        if (from < 6) {
          await m.addColumn(savedScripts, savedScripts.creationTime);
        }
      });

  Future<int> addDumpedRecord(DumpedRecordsCompanion entry) {
    return into(dumpedRecords).insert(entry);
  }

  Stream<List<DumpedRecord>> watchDumpedRecords() {
    return select(dumpedRecords).watch();
  }

  Future<int> countDumpedRecords() {
    return select(dumpedRecords).get().then((l) => l.length);
  }

  Future<bool> writeDumpedRecord(int? id, DumpedRecordsCompanion entry) {
    return (update(dumpedRecords)..where((u) => u.id.equals(id)))
        .write(entry)
        .then((count) => count > 0);
  }

  Future<int> deleteDumpedRecord(int? id) {
    return (delete(dumpedRecords)..where((t) => t.id.equals(id))).go();
  }

  Future<int> deleteAllDumpedRecords() {
    return delete(dumpedRecords).go();
  }

  Stream<List<SavedScript>> watchSavedScripts() {
    return select(savedScripts).watch();
  }

  Future<int> countSavedScripts() {
    return select(savedScripts).get().then((l) => l.length);
  }

  Future<int> addSavedScript(SavedScriptsCompanion entry) {
    return into(savedScripts).insert(entry);
  }

  Future<bool> writeSavedScripts(SavedScriptsCompanion entry) {
    return (update(savedScripts)..where((t) => t.id.equals(entry.id.value)))
        .write(entry)
        .then((count) => count > 0);
  }

  Future<int> deleteSavedScript(int id) {
    return (delete(savedScripts)..where((t) => t.id.equals(id))).go();
  }

  Future<int> deleteAllSavedScripts() {
    return delete(savedScripts).go();
  }
}

Database constructDb({bool logStatements = false}) {
  var vmdb = LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(path.join(dbFolder.path, 'db.sqlite'));
    return VmDatabase(file);
  });
  return Database(vmdb);
}
