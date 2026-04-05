import 'package:drift/drift.dart';

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

@DriftDatabase(tables: [FormulaElements])
class FormulasDatabase extends _$FormulasDatabase {
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
}

