import 'package:d4rt/d4rt.dart';

class VariableSpec {
  final String name;
  final String magnitude;
  static final MAGNITUDELESS = "magnitudeless";

  VariableSpec({required this.name, required this.magnitude});

  @override
  String toString() => 'var($name: $magnitude)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VariableSpec &&
          runtimeType == other.runtimeType &&
          magnitude == other.magnitude &&
          name == other.name;

  @override
  int get hashCode => Object.hash(magnitude, name);
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

  factory Formula.fromStringLiteral( String setStringLiteral ){
    var d4rt = D4rt();
    final buffer = StringBuffer();
    buffer.write( "main(){ return $setStringLiteral; }");
    final code = buffer.toString();

    final Map<Object?, Object?> setLiteral = d4rt.execute(source: code);

    return Formula.fromSet(setLiteral);
  }

  factory Formula.fromSet(Map<Object?, Object?> theSet) {

    Object safeGet(Map<Object?, Object?> map, String key){
      if( !map.containsKey(key) ){
        throw ArgumentError( "Key not found: $key -- $map" );
      }
      return map[key] ?? "Not possible!!!";
    }

    String stringValue(Map<Object?, Object?> map, String key){
      return safeGet(map, key).toString();
    }

    List<Object?> listValue(Map<Object?, Object?> map, String key){
      return safeGet(map,key) as List<Object?>;
    }

    Map<String, Object?> mapValue(Map<Object?, Object?> map, String key){
      return safeGet(map,key) as Map<String, Object?>;
    }

    VariableSpec parseVar(Map<Object?, Object?> varSpec) {
      String name = stringValue(varSpec, "name");
      String magnitude = stringValue(varSpec, "magnitude");
      return VariableSpec(name: name, magnitude: magnitude);
    }

    String name = stringValue( theSet, "name" );
    final List<Object?> inputSet = listValue( theSet, "input");
    List<VariableSpec> input = inputSet.map( (v) => parseVar(v as Map)).toList(growable: false);
    Map<Object?, Object?> outputSet = theSet.get("output");
    VariableSpec output = parseVar(outputSet);
    String d4rtCode = theSet.get("d4rtCode");

    return new Formula(
      name: name,
      input: input,
      output: output,
      d4rtCode: d4rtCode,
    );
  }
}
