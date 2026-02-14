import 'package:drift/drift.dart';
import 'package:drift/web.dart';


LazyDatabase openConnection() {
  return LazyDatabase(() async {
    // For web, use the web implementation
    return WebDatabase.withStorage(
      await DriftWebStorage.indexedDb('formulas_db'),
    );
  });
}