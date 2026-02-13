import 'package:d4rt_formulas/formula_models.dart' as models;

// Interface for corpus database operations
abstract class CorpusDatabaseInterface {
  Future<List<models.FormulaElement>> loadCorpusElements();
  Future<void> saveCorpusElements(List<models.FormulaElement> elements);
}