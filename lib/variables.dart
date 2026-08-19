import 'package:d4rt_formulas/formula_evaluator.dart';
import 'package:d4rt_formulas/set_utils.dart';

// TODO: If CompileConstants.useDatabase, persist in database all values
class GlobalVariables {
  Map<K, V> map<K, V>(MapEntry<K, V> convert(String key, FormulaResult value)) {
    return _map.map(convert);
  }

  final Map<String, FormulaResult> _map = {};

  bool containsKey(String variableName) {
    return _map.containsKey(variableName);
  }

  FormulaResult? operator [](String variableName) {
    return _map[variableName];
  }

  void operator []=(String variableName, FormulaResult value) {
    _map[variableName] = value;
  }

  FormulaResult? deleteKey(String variableName) {
    return _map.remove(variableName);
  }

  List<String> variableNames() {
    return _map.keys.toList()..sort();
  }

  String d4rtDeclarations([List<String>? includedVariables]) {
    List<T> sorted<T>(List<T> l) => l..sort();

    final variables = includedVariables != null
        ? sorted(List.from(includedVariables))
        : variableNames();
    final declarations = variables.map((name) {
      if (!containsKey(name)) {
        throw ArgumentError("Variable not exists: $name");
      }
      FormulaResult value = this[name]!;
      late String declaration;
      switch (value) {
        case StringResult s:
          declaration = "final $name = ${SetUtils.prettyPrint(s.value)};";
          break;
        case NumberResult n:
          declaration = "final $name = ${n.value};";
          break;
        case FunctionResult _:
          throw ArgumentError("Variable type not supoorted");
      }
      return declaration;
    });
    final ret = declarations.join("\n");
    print("VARIABLES:");
    print("$ret");
    return ret;
  }
}
