import 'package:d4rt_formulas/formula_evaluator.dart';
import 'package:d4rt_formulas/variables.dart';
import 'package:get_it/get_it.dart';

class CalculatorState {
  final GlobalVariables _variables = GetIt.instance.get<GlobalVariables>();

  static inputName(int index) => "input$index";
  static outputName(int index) => "ans$index";

  void setInput(int index, String value) {
    _variables[inputName(index)] = StringResult(value);
  }

  void removeInput(int index) {
    _variables.deleteKey(inputName(index));
  }

  String getInput(int index) => (_variables[inputName(index)] as StringResult).value;


  void setAnswer(int index, FormulaResult value) {
    _variables[outputName(index)] = value;
  }

  void removeAnswer(int index) {
    _variables.deleteKey(outputName(index));
  }

  int get minIndex => 1;

  int get maxIndex {
    var index = minIndex;
    while (_variables.containsKey(inputName(index))) {
      index += 1;
    }
    return index - 1;
  }

  void clear() {
    for (var index = minIndex; index <= maxIndex; index += 1) {
      removeInput(index);
      removeAnswer(index);
    }
  }
}
