import 'package:d4rt/d4rt.dart';
import 'package:collection/collection.dart';
import 'package:d4rt_formulas/d4rt_formulas.dart';

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
}

/// Parses a d4rt array literal (containing maps and arrays) to a List<Object?>
/// using d4rt
List<Object?> parseD4rtLiteral(String arrayStringLiteral) {
  var d4rt = D4rt();
  final buffer = StringBuffer();
  buffer.write("main(){ return $arrayStringLiteral; }");
  final code = buffer.toString();

  final List<Object?> list = d4rt.execute(source: code);

  return list;
}

/// Escapes special characters in a string for use in D4RT literals
String escapeD4rtString(String input) {
  return input
      .replaceAll(r'\', r'\\')  // Escape backslashes first
      .replaceAll('\n', r'\n')   // Escape newlines
      .replaceAll('\r', r'\r')   // Escape carriage returns
      .replaceAll('\t', r'\t')   // Escape tabs
      .replaceAll('"', r'\"');   // Escape quotes last
}

/// Parses corpus elements from an array string literal.
/// Determines if each element is a formula or a unit and converts accordingly.
List<FormulaElement> parseCorpusElements(String arrayStringLiteral) {
  final List<Object?> elements = parseD4rtLiteral(arrayStringLiteral);

  final List<FormulaElement> result = [];
  for (final element in elements) {
    if (element is Map<Object?, Object?>) {
      // Check if it's a formula by looking for required formula properties
      // Formulas typically have 'd4rtCode' and 'input'/'output' properties
      if (element.containsKey('d4rtCode')) {
        result.add(Formula.fromSet(element));
      }
      // Units typically have 'name', 'symbol', and 'baseUnit' properties
      else if (element.containsKey('name') && element.containsKey('symbol')) {
        result.add(UnitSpec.fromSet(element));
      }
      else {
        throw ArgumentError('Unknown element type: $element');
      }
    } else {
      throw ArgumentError('Element must be a Map: $element');
    }
  }

  return result;
}

typedef Number = double;

/// Abstract base class for formula elements
abstract class FormulaElement {
  /// Creates a string literal representation of the FormulaElement that can be parsed
  /// by the D4RT parser to recreate the same FormulaElement object.
  String toStringLiteral();
}

class UnitSpec implements FormulaElement {
  final String name;
  final String baseUnit;
  final String symbol;
  final Number? factorFromUnitToBase;
  final String? codeFromUnitToBase;
  final String? codeFromBaseToUnit;

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

    if( theSet.containsKey("isBase") ){
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
    }
    else if( theSet.containsKey("toBase")) {
      String codeFromBaseToUnit = SetUtils.stringValue(
        theSet,
        "fromBase",
      );
      String codeFromUnitToBase = SetUtils.stringValue(
        theSet,
        "toBase",
      );

      return UnitSpec(name: name,
          baseUnit: baseUnit,
          symbol: symbol,
          codeFromBaseToUnit: codeFromBaseToUnit,
          codeFromUnitToBase: codeFromUnitToBase);
    }
    else{
      throw ArgumentError( "Need factor or toBase/fromBase");
    }


  }

  static List<UnitSpec> fromArrayStringLiteral(String arrayStringLiteral) {
    final List<Object?> list = parseD4rtLiteral(arrayStringLiteral);

    final units = list.map((set) => UnitSpec.fromSet(set as Map));

    return units.toList(growable: false);
  }

  @override
  String toStringLiteral() {
    final buffer = StringBuffer('{');
    buffer.write('"name": "${escapeD4rtString(name)}", "symbol": "${escapeD4rtString(symbol)}"');

    if (name == baseUnit && factorFromUnitToBase == 1) {
      // This is a base unit
      buffer.write(', "isBase": true');
    } else {
      buffer.write(', "baseUnit": "${escapeD4rtString(baseUnit)}"');

      if (factorFromUnitToBase != null) {
        buffer.write(', "factor": $factorFromUnitToBase');
      } else if (codeFromUnitToBase != null && codeFromBaseToUnit != null) {
        buffer.write(', "toBase": "${escapeD4rtString(codeFromUnitToBase!)}", "fromBase": "${escapeD4rtString(codeFromBaseToUnit!)}"');
      }
    }

    buffer.write('}');
    return buffer.toString();
  }
}

class VariableSpec {
  final String name;
  final String? unit;
  final List<dynamic>? values;

  VariableSpec({required this.name, this.unit, this.values}){
    validate();
  }

  void validate(){
    if( FormulaEvaluator.reservedVariableNames.contains(name) ){
      throw ArgumentError("$name: is a reserved variable name for FormulaEvaluator");
    }
    final valuesValid = values != null && values?.isNotEmpty == true;
    if( unit == null && !valuesValid ){
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

  @override
  String toStringLiteral() {
    final buffer = StringBuffer('{');
    buffer.write('"name": "${escapeD4rtString(name)}"');

    if (unit != null) {
      buffer.write(', "unit": "${escapeD4rtString(unit!)}"');
    }

    if (values != null && values!.isNotEmpty) {
      buffer.write(', "values": [${values!.map((value) {
        if (value is String) {
          return '"${escapeD4rtString(value)}"';
        } else {
          return value.toString();
        }
      }).join(", ")}]');
    }

    buffer.write('}');
    return buffer.toString();
  }
}

class Formula implements FormulaElement {
  final String name;
  final String? description;
  final List<VariableSpec> input;
  final VariableSpec output;
  final String d4rtCode;
  final List<String> tags;

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
    if (name.trim().isEmpty) {
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
      Object.hash(name, description, ListEquality().hash(input), output, d4rtCode, ListEquality().hash(tags));

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
    final List<Object?> list = parseD4rtLiteral(arrayStringLiteral);

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
          throw ArgumentError('Allowed values must be all Strings or all Numbers');
        }
        if (!types.contains(String) && !types.contains(double) && !types.contains(int)) {
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
    String? description = theSet ["description"] as String?;
    List<String> tags = (theSet["tags"] as List<Object?>? ?? []).map((t) => t.toString()).toList();
    final List<Object?> inputSet = SetUtils.listValue(theSet, "input");
    List<VariableSpec> input = inputSet
        .map((v) => parseVar(v as Map))
        .toList(growable: false);
    Map<Object?, Object?> outputSet = theSet.get("output");
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

  /// Creates a string literal representation of the Formula that can be parsed
  /// by the D4RT parser to recreate the same Formula object.
  @override
  String toStringLiteral() {
    final inputStrings = input.map((varSpec) => varSpec.toStringLiteral()).toList();

    final buffer = StringBuffer('{');
    buffer.write('"name": "$name"');

    if (description != null) {
      buffer.write(', "description": r"""${description!}"""');
    }

    buffer.write(', "input": [${inputStrings.join(", ")}]');
    buffer.write(', "output": ${output.toStringLiteral()}');

    buffer.write(', "d4rtCode": r"""$d4rtCode"""');

    if (tags.isNotEmpty) {
      buffer.write(', "tags": [${tags.map((tag) => '"${escapeD4rtString(tag)}"').join(", ")}]');
    }

    buffer.write('}');
    return buffer.toString();
  }
}
