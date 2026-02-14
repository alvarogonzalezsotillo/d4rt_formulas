import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';


LazyDatabase openConnection() {
  return LazyDatabase(() async {
    final db = await WasmDatabase.open(
      databaseName: 'd4rt_formulas',
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.js'),
    );

    return db.resolvedExecutor;

  });
}