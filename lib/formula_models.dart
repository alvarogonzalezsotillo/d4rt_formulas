
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
  }){
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

  List<String> inputVarNames() => input.map( (v) => v.name ).toList(growable: false);

  factory Formula.fromSetLiteral(Map<String, Object> set ) {

      VariableSpec parseVar(Map<String, String> varSpec ){
        String name = varSpec.get("name");
        String magnitude = varSpec.get("magnitude");
        return VariableSpec(name: name, magnitude: magnitude);
      }

      String name = set.get("name");
      List<Map<String,String>> inputSet = set.get("input");
      List<VariableSpec> input = inputSet.map(parseVar).toList(growable:false);
      Map<String,String> outputSet = set.get("output");
      VariableSpec output = parseVar(outputSet);
      String d4rtCode = set.get("d4rtCode");

      return new Formula(name:name, input:input, output:output, d4rtCode:d4rtCode );

  }
}

