/// Data classes to represent a formula and its I/O specs.
///
/// Structure (from README.md):
/// - name: String
/// - input: { varName: { magnitude: String } }
/// - output: { varName: { magnitude: String } }
/// - d4rt_code: { code: String } or String
///
/// - Accept d4rt_code as either a plain string or an object { code: "..." }.

class VariableSpec {
  final String magnitude;

  const VariableSpec({required this.magnitude});

  factory VariableSpec.fromJson(Map<String, dynamic> json) {
    final mag = json['magnitude'];
    if (mag is! String || mag.trim().isEmpty) {
      throw FormatException("'magnitude' must be a non-empty string");
    }
    return VariableSpec(magnitude: mag);
  }

  Map<String, dynamic> toJson() => {'magnitude': magnitude};

  @override
  String toString() => 'VariableSpec(magnitude: $magnitude)';

  VariableSpec copyWith({String? magnitude}) =>
      VariableSpec(magnitude: magnitude ?? this.magnitude);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VariableSpec &&
          runtimeType == other.runtimeType &&
          magnitude == other.magnitude;

  @override
  int get hashCode => magnitude.hashCode;
}

class Formula {
  final String name;
  final Map<String, VariableSpec> input; // Supports multiple input variables
  final Map<String, VariableSpec> output; // Supports multiple output variables
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
    if (output.length != 1) {
      throw ArgumentError(
        'Formula "$name" must have exactly one output variable, '
        'but has ${output.length}',
      );
    }
  }

  factory Formula.fromJson(Map<String, dynamic> json) {
    final name = json['name'];
    if (name is! String || name.trim().isEmpty) {
      throw FormatException('Formula requires a non-empty name string');
    }

    Map<String, VariableSpec> parseVars(dynamic obj, String fieldName) {
      if (obj == null) return <String, VariableSpec>{};
      if (obj is! Map<String, dynamic>) {
        throw FormatException('$fieldName must be an object map');
      }
      return obj.map((k, v) {
        if (v is! Map<String, dynamic>) {
          throw FormatException(
            'Variable "$k" in $fieldName must be an object',
          );
        }
        return MapEntry(k, VariableSpec.fromJson(v));
      });
    }

    String parseCode(dynamic code) {
      if (code == null) {
        throw FormatException('d4rt_code is required');
      }
      if (code is String) return code;
      if (code is Map<String, dynamic>) {
        final explicit = code['code'];
        if (explicit is String) return explicit;
        for (final entry in code.entries) {
          if (entry.value is String) return entry.value as String;
        }
      }
      throw FormatException(
        'd4rt_code must be a string or an object containing a code string',
      );
    }

    final input = parseVars(json['input'], 'input');
    final output = parseVars(json['output'], 'output');
    final d4rtCode = parseCode(json['d4rt_code']);

    return Formula(
      name: name,
      input: input,
      output: output,
      d4rtCode: d4rtCode,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'input': input.map((k, v) => MapEntry(k, v.toJson())),
    'output': output.map((k, v) => MapEntry(k, v.toJson())),
    'd4rt_code': {'code': d4rtCode},
  };

  @override
  String toString() =>
      'Formula(name: $name, input: $input, output: $output, d4rtCode: $d4rtCode)';

  Formula copyWith({
    String? name,
    Map<String, VariableSpec>? input,
    Map<String, VariableSpec>? output,
    String? d4rtCode,
  }) => Formula(
    name: name ?? this.name,
    input: input ?? this.input,
    output: output ?? this.output,
    d4rtCode: d4rtCode ?? this.d4rtCode,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Formula &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          _mapEquals(input, other.input) &&
          _mapEquals(output, other.output) &&
          d4rtCode == other.d4rtCode;

  @override
  int get hashCode =>
      Object.hash(name, _mapHash(input), _mapHash(output), d4rtCode);
}

bool _mapEquals<K, V>(Map<K, V> a, Map<K, V> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (final entry in a.entries) {
    if (!b.containsKey(entry.key)) return false;
    if (b[entry.key] != entry.value) return false;
  }
  return true;
}

int _mapHash<K, V>(Map<K, V> m) {
  var h = 0;
  for (final e in m.entries) {
    h = h ^ Object.hash(e.key, e.value);
  }
  return h;
}
