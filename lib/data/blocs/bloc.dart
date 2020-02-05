import 'dart:convert';

import 'package:moor/moor.dart';

import '../database/database.dart';

class NFSeeAppBloc {
  final Database db;

  Stream<List<DumpedRecord>> _dumpedRecords;
  Stream<List<SavedScript>> _savedScripts;

  Stream<List<DumpedRecord>> get dumpedRecords => _dumpedRecords;
  Stream<List<SavedScript>> get savedScripts => _savedScripts;

  NFSeeAppBloc() : db = constructDb() {
    _dumpedRecords = db.watchDumpedRecords();
    _savedScripts = db.watchSavedScripts();
  }

  void addDumpedRecord(dynamic data) {
    db.addDumpedRecord(DumpedRecordsCompanion(
      time: Value(DateTime.now()),
      data: Value(jsonEncode(data)),
    ));
  }

  void updateDumpedRecordConfig(int id, dynamic config) {
    db.writeDumpedRecord(id, DumpedRecordsCompanion(
      config: Value(jsonEncode(config)),
    ));
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
}
