import 'package:test/test.dart';
import 'package:d4rt_formulas/formula_models.dart';
import 'package:d4rt_formulas/formula_evaluator.dart';

void main() {
  group('FormulaEvaluator', () {
    late FormulaEvaluator evaluator;

    setUp(() {
      evaluator = FormulaEvaluator();
    });

    group('Basic evaluation', () {
      test('evaluates Newton\'s second law formula', () {
        final formula = Formula(
          name: "Newton's second law",
          input: {
            'm': VariableSpec(magnitude: 'mass'),
            'a': VariableSpec(magnitude: 'acceleration'),
          },
          output: {'F': VariableSpec(magnitude: 'force')},
          d4rtCode: '''
            main() {
              return a * m;
            }
          ''',
        );

        final result = evaluator.evaluate(formula, {
          'm': 10.0, // 10 kg
          'a': 9.8, // 9.8 m/s²
        });

        expect(result, 98.0); // F = m * a = 10 * 9.8 = 98 N
      });

      test('evaluates simple arithmetic formula', () {
        final formula = Formula(
          name: 'Simple addition',
          input: {
            'x': VariableSpec(magnitude: 'scalar'),
            'y': VariableSpec(magnitude: 'scalar'),
          },
          output: {'result': VariableSpec(magnitude: 'scalar')},
          d4rtCode: '''
            main() {
              return x + y;
            }
          ''',
        );

        final result = evaluator.evaluate(formula, {'x': 5, 'y': 3});

        expect(result, 8);
      });

      test('handles single input variable', () {
        final formula = Formula(
          name: 'Square function',
          input: {'n': VariableSpec(magnitude: 'scalar')},
          output: {'result': VariableSpec(magnitude: 'scalar')},
          d4rtCode: '''
            main() {
              return n * n;
            }
          ''',
        );

        final result = evaluator.evaluate(formula, {'n': 7});
        expect(result, 49);
      });

      test('handles complex mathematical operations', () {
        final formula = Formula(
          name: 'Quadratic formula discriminant',
          input: {
            'a': VariableSpec(magnitude: 'scalar'),
            'b': VariableSpec(magnitude: 'scalar'),
            'c': VariableSpec(magnitude: 'scalar'),
          },
          output: {'discriminant': VariableSpec(magnitude: 'scalar')},
          d4rtCode: '''
            main() {
              return b * b - 4 * a * c;
            }
          ''',
        );

        final result = evaluator.evaluate(formula, {'a': 1, 'b': 5, 'c': 6});

        expect(result, 1); // b² - 4ac = 25 - 24 = 1
      });
    });

    group('Input variable order', () {
      test('maintains consistent alphabetical order for input variables', () {
        final formula = Formula(
          name: 'Test order',
          input: {
            'z': VariableSpec(magnitude: 'scalar'),
            'a': VariableSpec(magnitude: 'scalar'),
            'b': VariableSpec(magnitude: 'scalar'),
          },
          output: {'result': VariableSpec(magnitude: 'scalar')},
          d4rtCode: 'main() { return a + b + z; }',
        );

        final order = evaluator.getInputVariableOrder(formula);
        expect(order, ['a', 'b', 'z']);
      });

      test('passes arguments in correct alphabetical order', () {
        final formula = Formula(
          name: 'Test argument order',
          input: {
            'z': VariableSpec(magnitude: 'scalar'),
            'a': VariableSpec(magnitude: 'scalar'),
            'y': VariableSpec(magnitude: 'scalar'),
          },
          output: {'result': VariableSpec(magnitude: 'scalar')},
          d4rtCode: '''
            main() {
              // Variables: a=1, y=2, z=3
              return a * 100 + y * 10 + z;
            }
          ''',
        );

        final result = evaluator.evaluate(formula, {'z': 3, 'a': 1, 'y': 2});

        expect(result, 123); // 1*100 + 2*10 + 3 = 123
      });
    });

    group('Error handling', () {
      test(
        'throws exception for formula with no output variables during construction',
        () {
          expect(() {
            return Formula(
              name: 'Invalid formula',
              input: {'x': VariableSpec(magnitude: 'scalar')},
              output: {}, // No output variables
              d4rtCode: 'main() { return x; }',
            );
          }, throwsA(isA<ArgumentError>()));
        },
      );

      test(
        'throws exception for formula with multiple output variables during construction',
        () {
          expect(
            () => Formula(
              name: 'Invalid formula',
              input: {'x': VariableSpec(magnitude: 'scalar')},
              output: {
                'y': VariableSpec(magnitude: 'scalar'),
                'z': VariableSpec(magnitude: 'scalar'),
              },
              d4rtCode: 'main() { return x; }',
            ),
            throwsA(isA<ArgumentError>()),
          );
        },
      );

      test('throws exception for missing input variables', () {
        final formula = Formula(
          name: 'Test formula',
          input: {
            'x': VariableSpec(magnitude: 'scalar'),
            'y': VariableSpec(magnitude: 'scalar'),
          },
          output: {'result': VariableSpec(magnitude: 'scalar')},
          d4rtCode: 'main() { return x + y; }',
        );

        expect(
          () => evaluator.evaluate(formula, {'x': 1}), // Missing 'y'
          throwsA(isA<FormulaEvaluationException>()),
        );
      });

      test('throws exception for invalid d4rt code', () {
        final formula = Formula(
          name: 'Invalid code formula',
          input: {'x': VariableSpec(magnitude: 'scalar')},
          output: {'result': VariableSpec(magnitude: 'scalar')},
          d4rtCode: 'invalid dart code here!',
        );

        expect(
          () => evaluator.evaluate(formula, {'x': 1}),
          throwsA(isA<FormulaEvaluationException>()),
        );
      });
    });

    group('Utility methods', () {
      test('getOutputVariableName returns the single output variable name', () {
        final formula = Formula(
          name: 'Test',
          input: {'x': VariableSpec(magnitude: 'scalar')},
          output: {'force': VariableSpec(magnitude: 'Newton')},
          d4rtCode: 'main() { return x; }',
        );

        expect(evaluator.getOutputVariableName(formula), 'force');
      });

      test(
        'getOutputVariableMagnitude returns the output variable magnitude',
        () {
          final formula = Formula(
            name: 'Test',
            input: {'x': VariableSpec(magnitude: 'scalar')},
            output: {'force': VariableSpec(magnitude: 'Newton')},
            d4rtCode: 'main() { return x; }',
          );

          expect(evaluator.getOutputVariableMagnitude(formula), 'Newton');
        },
      );

      test('utility methods work correctly with valid formulas', () {
        final validFormula = Formula(
          name: 'Valid Formula',
          input: {'x': VariableSpec(magnitude: 'scalar')},
          output: {'result': VariableSpec(magnitude: 'Newton')},
          d4rtCode: 'main() { return x; }',
        );

        expect(evaluator.getOutputVariableName(validFormula), 'result');
        expect(evaluator.getOutputVariableMagnitude(validFormula), 'Newton');
      });

      test('validates formula construction with factory method', () {
        // Test the factory method validation
        expect(
          () => Formula(
            name: 'Invalid',
            input: {'x': VariableSpec(magnitude: 'scalar')},
            output: {}, // No output variables
            d4rtCode: 'main() { return x; }',
          ),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => Formula(
            name: 'Invalid',
            input: {'x': VariableSpec(magnitude: 'scalar')},
            output: {
              'y': VariableSpec(magnitude: 'scalar'),
              'z': VariableSpec(magnitude: 'scalar'),
            },
            d4rtCode: 'main() { return x; }',
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Data types', () {
      test('handles integer values', () {
        final formula = Formula(
          name: 'Integer test',
          input: {'n': VariableSpec(magnitude: 'count')},
          output: {'result': VariableSpec(magnitude: 'count')},
          d4rtCode: 'main() { return n + 1; }',
        );

        final result = evaluator.evaluate(formula, {'n': 42});
        expect(result, 43);
      });

      test('handles double values', () {
        final formula = Formula(
          name: 'Double test',
          input: {'x': VariableSpec(magnitude: 'length')},
          output: {'result': VariableSpec(magnitude: 'area')},
          d4rtCode: 'main() { return x * x; }',
        );

        final result = evaluator.evaluate(formula, {'x': 3.14});
        expect(result, closeTo(9.8596, 0.0001));
      });
    });
  });
}
