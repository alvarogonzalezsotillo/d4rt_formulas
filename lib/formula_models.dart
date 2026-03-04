import 'package:d4rt/d4rt.dart';
import 'package:collection/collection.dart';
import 'package:d4rt_formulas/d4rt_formulas.dart';

typedef Number = double;

abstract class SetUtils {
  static Object safeGet(Map<Object?, Object?> map, String key) {
    if (!map.containsKey(key)) {
      throw ArgumentError("Key not found: $key -- $map");
    }
    return map[key] ?? "Not possible!!!";
  }

  static String stringValue(Map<Object?, Object?> map, String key) {
    return safeGet(map, key).toString();
  }

  static List<Object?> listValue(Map<Object?, Object?> map, String key) {
    return safeGet(map, key) as List<Object?>;
  }

  static Number numberValue(Map<Object?, Object?> map, String key) {
    return double.parse(stringValue(map, key));
  }

  /// Parses a d4rt array literal (containing maps and arrays) to a List<Object?>
  /// using d4rt
  static List<Object?> parseD4rtLiteral(String arrayStringLiteral) {
    var d4rt = D4rt();
    final buffer = StringBuffer();
    buffer.write("main(){ return $arrayStringLiteral; }");
    final code = buffer.toString();

    final List<Object?> list = d4rt.execute(source: code);

    return list;
  }

  /// Escapes special characters in a string for use in D4RT literals
  @deprecated
  static String escapeD4rtString(String input) {
    return input
        .replaceAll(r'\\', r'\\\\') // escape backslashes first
        .replaceAll('\n', r'\\n')
        .replaceAll('\r', r'\\r')
        .replaceAll('\t', r'\\t')
        .replaceAll('"', r'\\"');
  }

  /// Parses corpus elements from an array string literal.
  /// Determines if each element is a formula or a unit and converts accordingly.
  static List<FormulaElement> parseCorpusElements(String arrayStringLiteral) {
    final List<Object?> elements = parseD4rtLiteral(arrayStringLiteral);

    final List<FormulaElement> result = [];
    for (final element in elements) {
      if (element is Map<Object?, Object?>) {
        if (element.containsKey('d4rtCode')) {
          result.add(Formula.fromSet(element));
        } else
        if (element.containsKey('name') && element.containsKey('symbol')) {
          result.add(UnitSpec.fromSet(element));
        } else {
          throw ArgumentError('Unknown element type: $element');
        }
      } else {
        throw ArgumentError('Element must be a Map: $element');
      }
    }

    return result;
  }

  /// Pretty prints a dynamic value (Set, Array, string or number) as a Dart literal.
  /// Uses JSON-like formatting but for Dart language, with proper indentation.
  static String prettyPrint(dynamic value, {int indent = 0}) {
    if (value   is String) {
      return _prettyPrintString(value, indent);
    } else if (value is num) {
      return _prettyPrintNumber(value, indent);
    } else if (value is Set) {
      return _prettyPrintSet(value, indent);
    } else if (value is List) {
      return _prettyPrintArray(value, indent);
    } else if (value is Map) {
      return _prettyPrintMap(value, indent);
    } else {
      return value.toString();
    }
  }

  /// Pretty prints a simple string, escaping special characters if needed.
  static String _prettyPrintString(String s, int indent) {
    // Check if the string needs raw string formatting (newlines, $, backslashes, quotes)
    final needsRawString = s.contains('\n') || 
                            s.contains(r'$') || 
                            s.contains(r'\') || 
                            s.contains('"');
    
    if (needsRawString) {
      return _prettyPrintRawString(s, indent);
    }
    
    // Simple string with escaped quotes
    return '"${s.replaceAll('"', r'\"')}"';
    //'
  }

  /// Pretty prints a number.
  static String _prettyPrintNumber(num n, int indent) {
    return n.toString();
  }

  /// Pretty prints a Set as a Dart set literal.
  static String _prettyPrintSet(Set s, int indent) {
    if (s.isEmpty) {
      return '{}';
    }
    
    final indentStr = '  ' * indent;
    final innerIndent = '  ' * (indent + 1);
    
    final elements = s.map((e) => '$innerIndent${prettyPrint(e, indent: indent + 1)}').join(',\n');
    return '{$elements\n$indentStr}';
  }

  /// Pretty prints an Array/List as a Dart list literal.
  static String _prettyPrintArray(List a, int indent) {
    if (a.isEmpty) {
      return '[]';
    }
    
    final indentStr = '  ' * indent;
    final innerIndent = '  ' * (indent + 1);
    
    final elements = a.map((e) => '$innerIndent${prettyPrint(e, indent: indent + 1)}').join(',\n');
    return '[\n$elements\n$indentStr]';
  }

  /// Pretty prints a Map as a Dart map literal.
  static String _prettyPrintMap(Map m, int indent) {
    if (m.isEmpty) {
      return '{}';
    }

    final indentStr = '  ' * indent;
    final innerIndent = '  ' * (indent + 1);
    
    final entries = m.entries.map((e) {
      final key = prettyPrint(e.key, indent: indent + 1);
      final value = prettyPrint(e.value, indent: indent + 1);
      return '$innerIndent$key: $value';
    }).join(',\n');
    
    return '{\n$entries\n$indentStr}';
  }

  /// Pretty prints a raw string (for strings containing newlines, $, backslashes, etc.)
  /// Uses Dart's raw string syntax r"""..."""
  static String _prettyPrintRawString(String s, int indent) {
    // Escape triple quotes by replacing """ with ""\"
    final escaped = s.replaceAll('"""', r'""\"');
    return 'r"""$escaped"""';
  }
}


/// Abstract base class for formula elements
abstract class FormulaElement {
  Map<String,dynamic> toMap();

  String toStringLiteral() {
    final map = toMap();
    return SetUtils.prettyPrint(map);
  }
}

class UnitSpec extends FormulaElement {
  final String name;
  final String baseUnit;
  final String symbol;
  final Number? factorFromUnitToBase;
  final String? codeFromUnitToBase;
  final String? codeFromBaseToUnit;

  @override
  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "baseUnit": baseUnit,
      "symbol": symbol,
      if (factorFromUnitToBase != null) 'factor': factorFromUnitToBase,
      if (codeFromUnitToBase != null) 'toBase': codeFromUnitToBase,
      if (codeFromBaseToUnit != null) 'fromBase': codeFromBaseToUnit,
    };
  }


  UnitSpec({
    required this.name,
    required this.baseUnit,
    required this.symbol,
    this.factorFromUnitToBase,
    this.codeFromBaseToUnit,
    this.codeFromUnitToBase,
  });

  factory UnitSpec.fromSet(Map<Object?, Object?> theSet) {
    String name = SetUtils.stringValue(theSet, "name");
    String symbol = SetUtils.stringValue(theSet, "symbol");

    if (theSet.containsKey("isBase")) {
      return UnitSpec(name: name, baseUnit: name, symbol: symbol, factorFromUnitToBase: 1);
    }

    String baseUnit = SetUtils.stringValue(theSet, "baseUnit");

    if (theSet.containsKey("factor")) {
      Number factorFromUnitToBase = SetUtils.numberValue(theSet, "factor");
      return UnitSpec(
        name: name,
        baseUnit: baseUnit,
        symbol: symbol,
        factorFromUnitToBase: factorFromUnitToBase,
      );
    } else if (theSet.containsKey("toBase")) {
      String codeFromBaseToUnit = SetUtils.stringValue(theSet, "fromBase");
      String codeFromUnitToBase = SetUtils.stringValue(theSet, "toBase");

      return UnitSpec(
        name: name,
        baseUnit: baseUnit,
        symbol: symbol,
        codeFromBaseToUnit: codeFromBaseToUnit,
        codeFromUnitToBase: codeFromUnitToBase,
      );
    } else {
      throw ArgumentError("Need factor or toBase/fromBase");
    }
  }

  static List<UnitSpec> fromArrayStringLiteral(String arrayStringLiteral) {
    final List<Object?> list = SetUtils.parseD4rtLiteral(arrayStringLiteral);

    final units = list.map((set) => UnitSpec.fromSet(set as Map));

    return units.toList(growable: false);
  }

}

class VariableSpec extends FormulaElement{
  final String name;
  final String? unit;
  final List<dynamic>? values;

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      if (unit != null) 'unit': unit,
      if (values != null) 'values': List.from(values!,growable: false),
    };
 }

  VariableSpec({required this.name, this.unit, this.values}) {
    validate();
  }

  void validate() {
    if (FormulaEvaluator.reservedVariableNames.contains(name)) {
      throw ArgumentError("$name: is a reserved variable name for FormulaEvaluator");
    }
    final valuesValid = values != null && values?.isNotEmpty == true;
    if (unit == null && !valuesValid) {
      throw ArgumentError("$name: at least unit or allowedValues should be valid");
    }
  }

  @override
  String toString() => 'var($name: $unit${values != null ? ' allowed: $values' : ''})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VariableSpec &&
          runtimeType == other.runtimeType &&
          unit == other.unit &&
          name == other.name &&
          const DeepCollectionEquality().equals(values, other.values);

  @override
  int get hashCode => Object.hash(unit, name, values != null ? const DeepCollectionEquality().hash(values!) : 0);


}

class Formula extends FormulaElement {
  final String name;
  final String? description;
  final List<VariableSpec> input;
  final VariableSpec output;
  final String d4rtCode;
  final List<String> tags;

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      if (description != null) 'description': description,
      'input': input.map((v) => v.toMap()).toList(growable: false),
      'output': output.toMap(),
      'd4rtCode': d4rtCode,
      if (tags.isNotEmpty) 'tags': List.from(tags, growable: false),
    };
  }

  Formula({
    required this.name,
    this.description,
    required this.input,
    required this.output,
    required this.d4rtCode,
    this.tags = const [],
  }) {
    validate();
  }

  void validate() {
    if (name
        .trim()
        .isEmpty) {
      throw ArgumentError('Formula name cannot be empty');
    }
  }

  @override
  String toString() =>
      'Formula(name: $name, description: $description, input: $input, output: $output, d4rtCode: $d4rtCode, tags: $tags)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Formula &&
              runtimeType == other.runtimeType &&
              name == other.name &&
              description == other.description &&
              output == other.output &&
              ListEquality().equals(input, other.input) &&
              d4rtCode == other.d4rtCode &&
              ListEquality().equals(tags, other.tags);

  @override
  int get hashCode =>
      Object.hash(
          name, description, ListEquality().hash(input), output, d4rtCode,
          ListEquality().hash(tags));

  List<String> inputVarNames() =>
      input.map((v) => v.name).toList(growable: false);

  factory Formula.fromStringLiteral(String setStringLiteral) {
    var d4rt = D4rt();
    final buffer = StringBuffer();
    buffer.write("main(){ return $setStringLiteral; }");
    final code = buffer.toString();

    final Map<Object?, Object?> setLiteral = d4rt.execute(source: code);

    return Formula.fromSet(setLiteral);
  }

  static List<Formula> fromArrayStringLiteral(String arrayStringLiteral) {
    final List<Object?> list = SetUtils.parseD4rtLiteral(arrayStringLiteral);

    final formulas = list.map((set) => Formula.fromSet(set as Map));

    return formulas.toList(growable: false);
  }

  factory Formula.fromSet(Map<Object?, Object?> theSet) {
    VariableSpec parseVar(Map<Object?, Object?> varSpec) {
      String name = SetUtils.stringValue(varSpec, "name");
      String? unit;
      if (varSpec.containsKey("unit")) {
        unit = SetUtils.stringValue(varSpec, "unit");
      }
      final allowed = varSpec['values'] as List<dynamic>?;
      if (allowed != null) {
        final types = allowed.map((v) => v.runtimeType).toSet();
        if (types.length > 1) {
          throw ArgumentError(
              'Allowed values must be all Strings or all Numbers');
        }
        if (!types.contains(String) && !types.contains(double) &&
            !types.contains(int)) {
          throw ArgumentError('Allowed values must be Strings or Numbers');
        }
      }
      return VariableSpec(
        name: name,
        unit: unit,
        values: allowed?.toList(growable: false),
      );
    }

    String name = SetUtils.stringValue(theSet, "name");
    String? description = theSet["description"] as String?;
    List<String> tags = (theSet["tags"] as List<Object?>? ?? []).map((t) =>
        t.toString()).toList();
    final List<Object?> inputSet = SetUtils.listValue(theSet, "input");
    List<VariableSpec> input = inputSet.map((v) => parseVar(v as Map)).toList(
        growable: false);
    Map<Object?, Object?> outputSet = theSet['output'] as Map<Object?, Object?>;
    VariableSpec output = parseVar(outputSet);
    String d4rtCode = SetUtils.stringValue(theSet, "d4rtCode");

    return Formula(
      name: name,
      description: description,
      tags: tags,
      input: input,
      output: output,
      d4rtCode: d4rtCode,
    );
  }
}

