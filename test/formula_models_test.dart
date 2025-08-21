import 'dart:convert';

import 'package:test/test.dart';
import 'package:d4rt_formulas/formula_models.dart';

void main() {
  group('Formula models', () {
    test('parses a formula with multiple input variables', () {
      const jsonStr = '''
      {
        "name": "Newton's second law (scalar)",
        "input": {
          "m": {"magnitude": "mass"},
          "a": {"magnitude": "acceleration"}
        },
        "output": {
          "F": {"magnitude": "Force"}
        },
        "d4rt_code": {"code": "return m*a;"}
      }
      ''';

      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      final f = Formula.fromJson(map);

      expect(f.name, "Newton's second law (scalar)");
      expect(f.input.length, 2);
      expect(f.input['m']!.magnitude, 'mass');
      expect(f.input['a']!.magnitude, 'acceleration');
      expect(f.output.length, 1);
      expect(f.output['F']!.magnitude, 'Force');
      expect(f.d4rtCode, 'return m*a;');

      final back = f.toJson();
      expect(back['name'], f.name);
      expect((back['input'] as Map)['m']['magnitude'], 'mass');
      expect((back['input'] as Map)['a']['magnitude'], 'acceleration');
      expect((back['output'] as Map)['F']['magnitude'], 'Force');
      expect((back['d4rt_code'] as Map)['code'], 'return m*a;');
    });

    test('rejects typo magitude (must be magnitude)', () {
      const badJson = '''
      {
        "name": "Bad formula",
        "input": {
          "x": {"magitude": "oops"}
        },
        "output": {
          "y": {"magnitude": "ok"}
        },
        "d4rt_code": "return x;"
      }
      ''';

      final map = jsonDecode(badJson) as Map<String, dynamic>;
      expect(() => Formula.fromJson(map), throwsFormatException);
    });

    test('accepts d4rt_code as a plain string', () {
      const jsonStr = '''
      {
        "name": "Simple",
        "input": {"x": {"magnitude": "scalar"}},
        "output": {"y": {"magnitude": "scalar"}},
        "d4rt_code": "return x;"
      }
      ''';
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      final f = Formula.fromJson(map);
      expect(f.d4rtCode, 'return x;');
    });
  });
}
