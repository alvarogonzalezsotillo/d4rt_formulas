import 'package:d4rt/d4rt.dart';
import 'package:collection/collection.dart';
import 'package:d4rt_formulas/d4rt_formulas.dart';
import 'package:d4rt_formulas/set_utils.dart';
import 'dart:math';
import 'package:uuid/uuid.dart';

typedef Number = double;

/// Abstract base class for formula elements
abstract class FormulaElement {
  Map<String, dynamic> toMap();

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
      return UnitSpec(name: name, baseUnit: baseUnit, symbol: symbol, factorFromUnitToBase: factorFromUnitToBase);
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

class VariableSpec extends FormulaElement {
  final String name;
  final String? unit;
  final List<dynamic>? values;

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      if (unit != null) 'unit': unit,
      if (values != null) 'values': List.from(values!, growable: false),
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

String _generateUuidV4() => Uuid().v4();

abstract class FormulaInterface {
  String get uuid;

  String get name;

  String? get description;

  List<VariableSpec> get input;

  VariableSpec get output;

  String get d4rtCode;

  List<String> get tags;

  Map<String, dynamic> toMap();

  Formula get originalFormula;

  static Formula getRootFormula( FormulaInterface fi ){
    if( fi is DerivedFormula ){
       return getRootFormula(fi.originalFormula);
    }
    if( fi is Formula ){
       return fi as Formula;
    }
    throw ArgumentError("Is not a known Formula subclass: ${fi} ${fi.runtimeType}");
  }
}

class DerivedFormula implements FormulaInterface {
  @override
  String get uuid => originalFormula.uuid;

  @override
  String get name => "${originalFormula.name} (Solving for ${_output.name})";

  @override
  String? get description => originalFormula.description;

  @override
  List<VariableSpec> get input => _input;

  @override
  VariableSpec get output => _output;

  @override
  String get d4rtCode => "signal('no code for derived formula, use formulaSolver')";

  @override
  List<String> get tags => originalFormula.tags;

  @override
  late final Formula originalFormula;

  @override
  Map<String, dynamic> toMap() => originalFormula.toMap();

  String outputName;
  late List<VariableSpec> _input;
  late VariableSpec _output;

  static bool isDerivable(Formula f){
    return f.input.every( (vs) => vs.unit != "string") && f.output.unit != "string";
  }

  DerivedFormula({required this.outputName, required this.originalFormula}) {


    if( !isDerivable(originalFormula) ){
      throw ArgumentError(
          "Derived formulas are not supported for formulas with string inputs, because we can't solve for them. Original formula: ${originalFormula.toString()}");
    }
    _init();
  }

  void _init(){
    var newInput = List<VariableSpec>.from(originalFormula.input).where((v) => v.name != outputName).toList();
    newInput.add(originalFormula.output);
    _input = newInput.toList(growable: false);
    _output = originalFormula.input.firstWhere(
      (v) => v.name == outputName,
      orElse: () => throw ArgumentError("New output variable $outputName not found in original formula input"),
    );
  }
}

class Formula extends FormulaElement implements FormulaInterface {
  @override
  final String uuid;
  @override
  final String name;
  @override
  final String? description;
  @override
  final List<VariableSpec> input;
  @override
  final VariableSpec output;
  @override
  final String d4rtCode;
  @override
  final List<String> tags;

  @override
  Formula get originalFormula => this;

  @override
  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'name': name,
      if (description != null) 'description': description,
      'input': input.map((v) => v.toMap()).toList(growable: false),
      'output': output.toMap(),
      'd4rtCode': d4rtCode,
      if (tags.isNotEmpty) 'tags': List.from(tags, growable: false),
    };
  }

  Formula({
    String? uuid,
    required this.name,
    this.description,
    required this.input,
    required this.output,
    required this.d4rtCode,
    this.tags = const [],
  }) : uuid = uuid ?? _generateUuidV4() {
    validate();
  }

  void validate() {
    if (name.trim().isEmpty) {
      throw ArgumentError('Formula name cannot be empty');
    }
  }

  @override
  String toString() =>
      'Formula(uuid: $uuid, name: $name, description: $description, input: $input, output: $output, d4rtCode: $d4rtCode, tags: $tags)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Formula && runtimeType == other.runtimeType && uuid == other.uuid;

  @override
  int get hashCode => uuid.hashCode;

  List<String> inputVarNames() => input.map((v) => v.name).toList(growable: false);

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
          throw ArgumentError('Allowed values must be all Strings or all Numbers');
        }
        if (!types.contains(String) && !types.contains(double) && !types.contains(int)) {
          throw ArgumentError('Allowed values must be Strings or Numbers');
        }
      }
      return VariableSpec(name: name, unit: unit, values: allowed?.toList(growable: false));
    }

    String? uuid = theSet['uuid'] as String?;
    String name = SetUtils.stringValue(theSet, "name");
    String? description = theSet["description"] as String?;
    List<String> tags = (theSet["tags"] as List<Object?>? ?? []).map((t) => t.toString()).toList();
    final List<Object?> inputSet = SetUtils.listValue(theSet, "input");
    List<VariableSpec> input = inputSet.map((v) => parseVar(v as Map)).toList(growable: false);
    Map<Object?, Object?> outputSet = theSet['output'] as Map<Object?, Object?>;
    VariableSpec output = parseVar(outputSet);
    String d4rtCode = SetUtils.stringValue(theSet, "d4rtCode");

    return Formula(
      uuid: uuid,
      name: name,
      description: description,
      tags: tags,
      input: input,
      output: output,
      d4rtCode: d4rtCode,
    );
  }
}
