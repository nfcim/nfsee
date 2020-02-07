import 'dart:convert';

import 'package:moor/moor.dart';
import 'package:nfsee/models.dart';

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

  Future<void> addDumpedRecord(String data,
      [DateTime time, String config]) async {
    await db.addDumpedRecord(DumpedRecordsCompanion().copyWith(
        data: Value(data),
        time: Value(time ?? DateTime.now()),
        config: Value(config ?? DEFAULT_CONFIG)
    ));
  }

  void updateDumpedRecordConfig(int id, dynamic config) {
    db.writeDumpedRecord(
        id,
        DumpedRecordsCompanion(
          config: Value(jsonEncode(config)),
        ));
  }

  Future<void> delDumpedRecord(int id) async {
    await db.deleteDumpedRecord(id);
  }

  Future<void> delAllDumpedRecord() async {
    await db.deleteAllDumpedRecords();
  }

  Future<void> addScript(String name, String source,
      [DateTime creationTime]) async {
    await db.addSavedScript(SavedScriptsCompanion.insert(
      name: name,
      source: source,
      creationTime: creationTime ?? DateTime.now(),
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

  Future<void> delScript(int id) async {
    await db.deleteSavedScript(id);
  }

  Future<void> delAllScripts() async {
    await db.deleteAllSavedScripts();
  }
}
