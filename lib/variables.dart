import 'package:d4rt_formulas/debounced_executor.dart';
import 'package:d4rt_formulas/formula_evaluator.dart';
import 'package:d4rt_formulas/set_utils.dart';

class GlobalVariables {
  Map<K, V> map<K, V>(MapEntry<K, V> convert(String key, FormulaResult value)) {
    return _map.map(convert);
  }

  final Map<String, FormulaResult> _map = {};
  DebouncedExecutor? _persister;

  void enablePersistence(Future<void> Function(Map<String, String>) onSave) {
    _persister?.dispose();
    _persister = DebouncedExecutor( () async {
      await onSave(toMap());
    });
  }

  void disablePersistence() {
    _persister?.dispose();
    _persister = null;
  }

  bool containsKey(String variableName) {
    return _map.containsKey(variableName);
  }

  FormulaResult? operator [](String variableName) {
    return _map[variableName];
  }

  void operator []=(String variableName, FormulaResult value) {
    _map[variableName] = value;
    _persister?.requestPersist();
  }

  FormulaResult? deleteKey(String variableName) {
    final result = _map.remove(variableName);
    _persister?.requestPersist();
    return result;
  }

  List<String> variableNames() {
    return _map.keys.toList()..sort();
  }

  Map<String, String> toMap() {
    final result = <String, String>{};
    for (final entry in _map.entries) {
      switch (entry.value) {
        case NumberResult n:
          result[entry.key] = n.value.toString();
          break;
        case StringResult s:
          result[entry.key] = s.value;
          break;
        case FunctionResult _:
          break;
      }
    }
    return result;
  }

  void loadFromMap(Map<String, String> data) {
    _map.clear();
    for (final entry in data.entries) {
      _map[entry.key] = StringResult(entry.value);
    }
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
          declaration = 'final $name = "${SetUtils.escapeD4rtString(s.value)}";';
          break;
        case NumberResult n:
          declaration = "final $name = ${n.value};";
          break;
        case FunctionResult f:
          declaration = "final $name = ${f.code};";
          break;
      }
      return declaration;
    });
    final ret = declarations.join("\n");
    print("VARIABLES:");
    print("$ret");
    return ret;
  }
}
