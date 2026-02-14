import 'package:drift/drift.dart';

import 'formulas_database_unsupported.dart'
if (dart.library.html) 'formulas_database_web.dart'
if (dart.library.ffi) 'formulas_database_native.dart';


part 'formulas_database.g.dart';

// Define the FORMULAELEMENT table to store both formulas and units as text
class FormulaElements extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get elementText => text()();
}

@DriftDatabase(tables: [FormulaElements])
class FormulasDatabase extends _$FormulasDatabase {
  FormulasDatabase() : super(openConnection());

  @override
  int get schemaVersion => 1;

  // Method to insert a new formula element (either formula or unit)
  Future<int> insertFormulaElement(String elementText) {
    return into(formulaElements).insert(FormulaElementsCompanion.insert(elementText: elementText));
  }

  // Method to get all formula elements
  Future<List<FormulaElement>> getAllFormulaElements() {
    return select(formulaElements).get();
  }

  // Method to get a formula element by ID
  Future<FormulaElement?> getFormulaElementById(int id) {
    return (select(formulaElements)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  // Method to update a formula element
  Future<void> updateFormulaElement(int id, String newElementText) {
    return (update(formulaElements)..where((tbl) => tbl.id.equals(id)))
        .write(FormulaElementsCompanion.insert(elementText: newElementText));
  }

  // Method to delete a formula element
  Future<void> deleteFormulaElement(int id) {
    return (delete(formulaElements)..where((tbl) => tbl.id.equals(id))).go();
  }

  // Additional helper methods for direct access to the table
  SimpleSelectStatement get allFormulaElements => select(formulaElements);
}

