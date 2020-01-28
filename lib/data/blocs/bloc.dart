import 'dart:convert';

import 'package:moor/moor.dart';

import '../database/database.dart';

class NFSeeAppBloc {
  final Database db;

  Stream<List<DumpedRecord>> _dumpedRecords;

  Stream<List<DumpedRecord>> get dumpedRecords => _dumpedRecords;

  NFSeeAppBloc() : db = constructDb() {
    _dumpedRecords = db.watchDumpedRecords();
  }

  void addDumpedRecord(dynamic data) {
    db.addDumpedRecord(DumpedRecordsCompanion(
      time: Value(DateTime.now()),
      data: Value(jsonEncode(data)),
    ));
  }

  Future<List<DumpedRecord>> listDumpedRecords() {
    return db.listDumpedRecords();
  }

  Future<void> addScript(String name, String source) async {
    await db.addScript(SavedScriptsCompanion.insert(
      name: name,
      source: source,
    ));
  }

  Future<void> useScript(SavedScript script) async {
    await db.updateScript(SavedScriptsCompanion(
      id: Value(script.id),
      name: Value(script.name),
      source: Value(script.source),
      lastUsed: Value(DateTime.now()),
    ));
  }

  Future<void> delScript(SavedScript script) async {
    await db.delScript(SavedScriptsCompanion(
      id: Value(script.id),
      name: Value(script.name),
      source: Value(script.source),
      lastUsed: Value(script.lastUsed),
    ));
  }

  Future<List<SavedScript>> listScripts() {
    return db.listScripts();
  }

  void dispose() {}
}
