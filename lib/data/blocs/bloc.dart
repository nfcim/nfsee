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
    db.writeDumpedRecord(
        id,
        DumpedRecordsCompanion(
          config: Value(jsonEncode(config)),
        ));
  }

  Future<void> changeDumpedRecordVisibility(int id, bool visible) async {
    db.writeDumpedRecord(
        id,
        DumpedRecordsCompanion(
          visible: Value(visible)
        ));
  }

  Future<void> delDumpedRecord(int id) async {
    await db.deleteDumpedRecord(id);
  }

  Future<void> delAllDumpedRecord() async {
    await db.deleteAllDumpedRecords();
  }

  Future<void> addScript(String name, String source) async {
    await db.addSavedScript(SavedScriptsCompanion.insert(
      name: name,
      source: source,
    ));
  }

  Future<void> updateScriptContent(int id, String name, String source) async {
    await db.writeSavedScripts(SavedScriptsCompanion(
      id: Value(id),
      name: Value(name),
      source: Value(source),
      lastUsed: Value(null),
    ));
  }

  Future<void> updateScriptUseTime(int id) async {
    await db.writeSavedScripts(SavedScriptsCompanion(
      id: Value(id),
      lastUsed: Value(DateTime.now()),
    ));
  }

  Future<void> changeScriptVisibility(int id, bool visible) async {
    await db.writeSavedScripts(SavedScriptsCompanion(
      id: Value(id),
      visible: Value(visible),
    ));
  }

  Future<void> delScript(int id) async {
    await db.deleteSavedScript(id);
  }

  Future<void> delAllScripts() async {
    await db.deleteAllSavedScripts();
  }
}
