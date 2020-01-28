import 'package:moor/moor.dart';
import 'package:moor_ffi/moor_ffi.dart';

part 'database.g.dart';

@DataClassName('DumpedRecord')
class DumpedRecords extends Table {
  IntColumn get id => integer().autoIncrement()();

  DateTimeColumn get time => dateTime()();

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
  int get schemaVersion => 2;

  Future<int> addDumpedRecord(DumpedRecordsCompanion entry) {
    return into(dumpedRecords).insert(entry);
  }

  Future<List<DumpedRecord>> listDumpedRecords() {
    return select(dumpedRecords).get();
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

  Future<List<SavedScript>> listScripts() {
    return select(savedScripts).get();
  }
}

Database constructDb({bool logStatements = false}) {
//  if (Platform.isIOS || Platform.isAndroid) {
//    final executor = LazyDatabase(() async {
//      final dataDir = await paths.getApplicationDocumentsDirectory();
//      final dbFile = File(p.join(dataDir.path, 'db.sqlite'));
//      return VmDatabase(dbFile, logStatements: logStatements);
//    });
//    return Database(executor);
//  }
  return Database(VmDatabase.memory(logStatements: logStatements));
}
