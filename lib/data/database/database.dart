import 'dart:io';

import 'package:moor/moor.dart';
import 'package:moor_ffi/moor_ffi.dart';

import 'package:path_provider/path_provider.dart' as paths;
import 'package:path/path.dart' as p;

part 'database.g.dart';

class DumpedData extends Table {
  IntColumn get id => integer().autoIncrement()();

  DateTimeColumn get time => dateTime()();

  TextColumn get data => text()();
}

@UseMoor(
  tables: [DumpedData],
)
class Database extends _$Database {
  Database(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;

  Future createDumpedData(DumpedDataCompanion entry) {
    return into(dumpedData).insert(entry);
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
