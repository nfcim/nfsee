import 'dart:convert';

import 'package:moor/moor.dart';
import 'package:nfsee/data/database/database.dart';

class NFSeeAppBloc {
  final Database db;

  NFSeeAppBloc() : db = constructDb();

  void createDumpedData(Map<String, String> data) {
    db.createDumpedData(DumpedDataCompanion(
      time: Value(DateTime.now()),
      data: Value(jsonEncode(data)),
    ));
  }

  void dispose() {}
}
