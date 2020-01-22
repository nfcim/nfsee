import 'dart:convert';

import 'package:moor/moor.dart';
import 'package:nfsee/data/database/database.dart';

class NFSeeAppBloc {
  final Database db;

  NFSeeAppBloc() : db = constructDb();

  void addDumpedRecord(dynamic data) {
    db.addDumpedRecord(DumpedRecordsCompanion(
      time: Value(DateTime.now()),
      data: Value(jsonEncode(data)),
    ));
  }

  Future<List<DumpedRecord>> listDumpedRecords() {
    return db.listDumpedRecords();
  }

  void dispose() {}
}
