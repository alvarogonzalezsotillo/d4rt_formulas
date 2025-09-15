import 'package:d4rt/d4rt.dart';
import 'package:collection/collection.dart';

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

typedef Number = double;


class UnitSpec {
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
    var d4rt = D4rt();
    final buffer = StringBuffer();
    buffer.write("main(){ return $arrayStringLiteral; }");
    final code = buffer.toString();

    final List<Object?> list = d4rt.execute(source: code);

    final units = list.map((set) => UnitSpec.fromSet(set as Map));

    return units.toList(growable: false);
  }

}

class VariableSpec {
  final String name;
  final String unit;
  static final MAGNITUDELESS = "magnitudeless";

  VariableSpec({required this.name, required this.unit});

  @override
  String toString() => 'var($name: $unit)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VariableSpec &&
          runtimeType == other.runtimeType &&
          unit == other.unit &&
          name == other.name;

  @override
  int get hashCode => Object.hash(unit, name);
}

class Formula {
  final String name;
  final List<VariableSpec> input;
  final VariableSpec output;
  final String d4rtCode;

  Formula({
    required this.name,
    required this.input,
    required this.output,
    required this.d4rtCode,
  }) {
    validate();
  }

  validate() {
    if (name.trim().isEmpty) {
      throw ArgumentError('Formula name cannot be empty');
    }
  }

  @override
  String toString() =>
      'Formula(name: $name, input: $input, output: $output, d4rtCode: $d4rtCode)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Formula &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          output == other.output &&
          ListEquality().equals(input, other.input) &&
          d4rtCode == other.d4rtCode;

  @override
  int get hashCode =>
      Object.hash(name, ListEquality().hash(input), output, d4rtCode);

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
    var d4rt = D4rt();
    final buffer = StringBuffer();
    buffer.write("main(){ return $arrayStringLiteral; }");
    final code = buffer.toString();

    final List<Object?> list = d4rt.execute(source: code);

    final formulas = list.map((set) => Formula.fromSet(set as Map));

    return formulas.toList(growable: false);
  }

  factory Formula.fromSet(Map<Object?, Object?> theSet) {
    VariableSpec parseVar(Map<Object?, Object?> varSpec) {
      String name = SetUtils.stringValue(varSpec, "name");
      String magnitude = SetUtils.stringValue(varSpec, "magnitude");
      return VariableSpec(name: name, unit: magnitude);
    }

    String name = SetUtils.stringValue(theSet, "name");
    final List<Object?> inputSet = SetUtils.listValue(theSet, "input");
    List<VariableSpec> input = inputSet
        .map((v) => parseVar(v as Map))
        .toList(growable: false);
    Map<Object?, Object?> outputSet = theSet.get("output");
    VariableSpec output = parseVar(outputSet);
    String d4rtCode = SetUtils.stringValue(theSet, "d4rtCode");

    return Formula(
      name: name,
      input: input,
      output: output,
      d4rtCode: d4rtCode,
    );
  }
}
