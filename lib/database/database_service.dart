import '../formula_models.dart';
import '../set_utils.dart';
import 'corpus_database_interface.dart';
import 'formulas_database.dart';
import 'package:d4rt_formulas/formula_models.dart' as models;

// Extension to add corpus loading/saving functionality to FormulasDatabase
extension CorpusDatabaseExtension on FormulasDatabase {
  // Method to load corpus elements from database
  Future<List<models.FormulaElement>> loadCorpusElements() async {
    final elements = await getAllFormulaElements();
    final List<models.FormulaElement> parsedElements = [];

    for (final element in elements) {
      try {
        final parsed = SetUtils.parseCorpusElements('[${element.elementText}]');
        parsedElements.addAll(parsed);
      } catch (e) {
        print('Error parsing database element: $e');
        print("NOT PARSED: $element");
        // Skip invalid elements but continue processing others
        continue;
      }
    }

    return parsedElements;
  }

  // Method to save corpus elements to database
  Future<void> saveCorpusElements(List<models.FormulaElement> elements) async {
    // Clear existing elements first
    await delete(formulaElements).go();

    // Insert new elements with their UUIDs
    for (final element in elements) {
      await insertFormulaElement(element.uuid, element.toStringLiteral());
    }
  }

  // Method to update a formula in the database by UUID
  Future<bool> updateFormula(models.Formula formula) async {
    final existingElement = await getFormulaElementByUuid(formula.uuid);
    if (existingElement != null) {
      await updateFormulaElement(formula.uuid, formula.toStringLiteral());
      return true;
    }
    return false;
  }

  // Method to add a new formula to the database
  Future<void> addFormula(models.Formula formula) async {
    await insertFormulaElement(formula.uuid, formula.toStringLiteral());
  }

  // Method to add a new formula element (formula or unit) to the database
  Future<void> addFormulaElement(models.FormulaElement element) async {
    await insertFormulaElement(element.uuid, element.toStringLiteral());
  }

  // Method to delete a formula from the database by UUID
  Future<bool> deleteFormula(String uuid) async {
    final existingElement = await getFormulaElementByUuid(uuid);
    if (existingElement != null) {
      await deleteFormulaElement(uuid);
      return true;
    }
    return false;
  }
}
