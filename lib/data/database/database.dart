import 'dart:developer';
import 'dart:io';

import 'package:moor/moor.dart';
import 'package:moor_ffi/moor_ffi.dart';
import 'package:nfsee/models.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

part 'database.g.dart';

@DataClassName('DumpedRecord')
class DumpedRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get time => dateTime()();
  TextColumn get config => text().withDefault(const Constant(DEFAULT_CONFIG))(); // Name, color, etc...
  TextColumn get data => text()();
}

@DataClassName('SavedScript')
class SavedScripts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get source => text()();
  DateTimeColumn get lastUsed => dateTime().nullable()();
}

@UseMoor(
  tables: [DumpedRecords, SavedScripts],
)
class Database extends _$Database {
  Database(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) => m.createAll(),
    onUpgrade: (Migrator m, int from, int to) async {
      log("Migrate db from $from to $to");
      if(from < 5) {
        await m.addColumn(dumpedRecords, dumpedRecords.config);
      }
    }
  );

  Future<int> addDumpedRecord(DumpedRecordsCompanion entry) {
    return into(dumpedRecords).insert(entry);
  }

  Stream<List<DumpedRecord>> watchDumpedRecords() {
    return select(dumpedRecords).watch();
  }

  Future<bool> writeDumpedRecord(int id, DumpedRecordsCompanion entry) {
    return (update(dumpedRecords)..where((u) => u.id.equals(id))).write(entry).then((count) => count > 0);
  }

  Future<int> delDumpedRecord(DumpedRecordsCompanion entry) {
    return delete(dumpedRecords).delete(entry);
  }

  Stream<List<SavedScript>> watchSavedScripts() {
    return select(savedScripts).watch();
  }

  Future<int> addScript(SavedScriptsCompanion entry) {
    return into(savedScripts).insert(entry);
  }

  Future<bool> updateScript(SavedScriptsCompanion entry) {
    return update(savedScripts).replace(entry);
  }

  Future<int> delScript(SavedScriptsCompanion entry) {
    return delete(savedScripts).delete(entry);
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
