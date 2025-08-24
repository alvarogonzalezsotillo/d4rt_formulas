
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
}

