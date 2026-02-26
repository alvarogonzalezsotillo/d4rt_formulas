import 'package:d4rt/d4rt.dart';
import 'package:get_it/get_it.dart';
import 'corpus.dart';
import 'formula_evaluator.dart';

part 'd4rt_bridge.g.dart';

@D4rtBridge(libraryUri: 'package:formulas/runtime_bridge.dart')
class D4rtBridgeImpl {
  static dynamic fn(String formulaName, Map<String, dynamic> inputValues) {
    var corpus = GetIt.instance.get<Corpus>();
    var evaluator = FormulaEvaluator();
    var formula = corpus.getFormula(formulaName);
    if (formula == null) {
      throw ArgumentError("Formula not found in corpus: $formulaName");
    }
    return evaluator.evaluate(formula, inputValues);
  }
}