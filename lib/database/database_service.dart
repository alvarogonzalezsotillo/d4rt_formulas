import 'corpus_database_interface.dart';
import 'formulas_database.dart'
    if (dart.library.html) 'formulas_database_web.dart';
import 'package:d4rt_formulas/formula_models.dart' as models;

// Extension to add corpus loading/saving functionality to FormulasDatabase
extension CorpusDatabaseExtension on FormulasDatabase {
  // Method to load corpus elements from database
  Future<List<models.FormulaElement>> loadCorpusElements() async {
    final elements = await getAllFormulaElements();
    final List<models.FormulaElement> parsedElements = [];

    for (final element in elements) {
      try {
        final parsed = models.parseCorpusElements('[${element.elementText}]');
        parsedElements.addAll(parsed);
      } catch (e) {
        print('Error parsing database element: $e');
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
}