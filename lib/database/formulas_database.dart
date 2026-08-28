import 'package:drift/drift.dart';

/*
TODO: migrate to driftDatabase, drop NativeDatabase
The future-proof upgrade to sqlite3 v3 + drift_flutter is not possible with the current project's dependency graph.

Why
d4rt (even the latest 0.2.4) pins analyzer: ^8.4.0. That forces drift_dev to a version that requires sqlite3 < 3.0.0. Since drift_flutter requires sqlite3: ^3.0.0, they're mutually incompatible:

snippet ⧉

d4rt_formulas depends on both sqlite3 ^3.0.0 and drift_dev any, version solving failed.


What remains
The project stays on the sqlite3 v2 line, which needs sqlite3_flutter_libs to bundle the native .so. The fix remains the 0.5.42 pin (the last version that actually bundles libsqlite3.so for Android; 0.6.0+eol is a do-nothing stub that causes your error).


yaml ⧉

sqlite3_flutter_libs: 0.5.42

Path forward (what unblocks the real upgrade)
The future-proof migration requires d4rt to drop its analyzer: ^8.4.0 pin (support analyzer ≥13). Once a d4rt release does that, you'd:

1. flutter pub add sqlite3:^3.0.0 drift_flutter (remove sqlite3_flutter_libs)
2. Replace the NativeDatabase.createInBackground / WasmDatabase.open calls with driftDatabase(name: ...) in formulas_database_native.dart / _web.dart
*/

import 'formulas_database_unsupported.dart'
if (dart.library.html) 'formulas_database_web.dart'
if (dart.library.ffi) 'formulas_database_native.dart';


part 'formulas_database.g.dart';


class FormulaElements extends Table {
  TextColumn get uuid => text()();
  TextColumn get elementText => text()();

  @override
  Set<Column> get primaryKey => {uuid};
}

class GlobalVariablesTable extends Table {
  TextColumn get name => text()();
  TextColumn get valueText => text()();

  @override
  Set<Column> get primaryKey => {name};
}

@DriftDatabase(tables: [FormulaElements, GlobalVariablesTable])
class FormulasDatabase extends _$FormulasDatabase {

  static String underlyingStorage(){
    return openConnectionStorage();
  }
  
  FormulasDatabase() : super(openConnection());

  @override
  int get schemaVersion => 1;

  // Method to insert a new formula element (either formula or unit)
  Future<void> insertFormulaElement(String uuid, String elementText) {
    return into(formulaElements).insert(
      FormulaElementsCompanion.insert(uuid: uuid, elementText: elementText),
    );
  }

  // Method to get all formula elements
  Future<List<FormulaElement>> getAllFormulaElements() {
    return select(formulaElements).get();
  }

  // Method to get a formula element by UUID
  Future<FormulaElement?> getFormulaElementByUuid(String uuid) {
    return (select(formulaElements)..where((tbl) => tbl.uuid.equals(uuid))).getSingleOrNull();
  }

  // Method to update a formula element
  Future<void> updateFormulaElement(String uuid, String newElementText) {
    return (update(formulaElements)..where((tbl) => tbl.uuid.equals(uuid)))
        .write(FormulaElementsCompanion(elementText: Value(newElementText)));
  }

  // Method to delete a formula element
  Future<void> deleteFormulaElement(String uuid) {
    return (delete(formulaElements)..where((tbl) => tbl.uuid.equals(uuid))).go();
  }

  // Additional helper methods for direct access to the table
  SimpleSelectStatement get allFormulaElements => select(formulaElements);

  // GlobalVariablesTable methods
  Future<void> saveGlobalVariable(String name, String valueText) {
    return into(globalVariablesTable).insert(
      GlobalVariablesTableCompanion.insert(name: name, valueText: valueText),
      mode: InsertMode.replace,
    );
  }

  Future<List<GlobalVariablesTableData>> getAllGlobalVariables() {
    return select(globalVariablesTable).get();
  }

  Future<void> deleteAllGlobalVariables() {
    return delete(globalVariablesTable).go();
  }
}

