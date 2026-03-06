import '../formula_models.dart';
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
        print("PARSED:$element");
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

    // Insert new elements
    for (final element in elements) {
      await insertFormulaElement(element.toStringLiteral());
    }
  }

  // Method to update a formula in the database by name
  Future<bool> updateFormula(models.Formula formula) async {
    final elements = await getAllFormulaElements();
    
    for (final element in elements) {
      try {
        final parsed = models.parseCorpusElements('[${element.elementText}]');
        if (parsed.isNotEmpty && parsed.first is models.Formula) {
          final existingFormula = parsed.first as models.Formula;
          if (existingFormula.name == formula.name) {
            // Update this element
            await updateFormulaElement(
              element.id, 
              formula.toStringLiteral()
            );
            return true;
          }
        }
      } catch (e) {
        print('Error parsing database element during update: $e');
        continue;
      }
    }
    
    return false; // Formula not found
  }

  // Method to add a new formula to the database
  Future<void> addFormula(models.Formula formula) async {
    await insertFormulaElement(formula.toStringLiteral());
  }

  // Method to delete a formula from the database by name
  Future<bool> deleteFormula(String formulaName) async {
    final elements = await getAllFormulaElements();
    
    for (final element in elements) {
      try {
        final parsed = models.parseCorpusElements('[${element.elementText}]');
        if (parsed.isNotEmpty && parsed.first is models.Formula) {
          final existingFormula = parsed.first as models.Formula;
          if (existingFormula.name == formulaName) {
            await deleteFormulaElement(element.id);
            return true;
          }
        }
      } catch (e) {
        print('Error parsing database element during delete: $e');
        continue;
      }
    }
    
    return false; // Formula not found
  }
}
