import 'package:drift/drift.dart';
import 'package:drift/web.dart';
import 'package:path_provider/path_provider.dart';

part 'formulas_database_web.g.dart';

// Define the formulas table with a single text column for formula descriptions
class Formulas extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get formula => text()();
}

@DriftDatabase(tables: [Formulas])
class FormulasDatabase extends _$FormulasDatabase {
  FormulasDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Method to insert a new formula
  Future<int> insertFormula(String formulaText) {
    return into(formulas).insert(FormulasCompanion.insert(formula: formulaText));
  }

  // Method to get all formulas
  Future<List<Formula>> getAllFormulas() {
    return select(formulas).get();
  }

  // Method to get a formula by ID
  Future<Formula?> getFormulaById(int id) {
    return (select(formulas)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  // Method to update a formula
  Future<void> updateFormula(int id, String newFormula) {
    return (update(formulas)..where((tbl) => tbl.id.equals(id)))
        .write(FormulasCompanion.insert(formula: newFormula));
  }

  // Method to delete a formula
  Future<void> deleteFormula(int id) {
    return (delete(formulas)..where((tbl) => tbl.id.equals(id))).go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    // For web, use the web implementation
    return WebDatabase.withStorage(
      await DriftWebStorage.indexedDb('formulas_db'),
    );
  });
}