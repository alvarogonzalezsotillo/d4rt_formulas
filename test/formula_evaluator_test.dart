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
          input: [
            VariableSpec(name: 'm', unit: 'mass'),
            VariableSpec(name: 'a', unit: 'acceleration'),
          ],
          output: VariableSpec(name: 'F', unit: 'force'),
          d4rtCode: '''
              F = a * m;
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
          input: [
            VariableSpec(name: 'x', unit: 'scalar'),
            VariableSpec(name: 'y', unit: 'scalar'),
          ],
          output: VariableSpec(name: 'result', unit: 'scalar'),
          d4rtCode: '''
              result = x + y;
          ''',
        );

        final result = evaluator.evaluate(formula, {'x': 5, 'y': 3});

        expect(result, 8);
      });

      test('handles single input variable', () {
        final formula = Formula(
          name: 'Square function',
          input: [VariableSpec(name: 'n', unit: 'scalar')],
          output: VariableSpec(name: 'result', unit: 'scalar'),
          d4rtCode: '''
              result = n * n;
          ''',
        );

        final result = evaluator.evaluate(formula, {'n': 7});
        expect(result, 49);
      });

      test('handles complex mathematical operations', () {
        final formula = Formula(
          name: 'Quadratic formula discriminant',
          input: [
            VariableSpec(name: 'a', unit: 'scalar'),
            VariableSpec(name: 'b', unit: 'scalar'),
            VariableSpec(name: 'c', unit: 'scalar'),
          ],
          output: VariableSpec(name: 'discriminant', unit: 'scalar'),
          d4rtCode: '''
              discriminant = b * b - 4 * a * c;
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
          input: [
            VariableSpec(name: 'z', unit: 'scalar'),
            VariableSpec(name: 'a', unit: 'scalar'),
            VariableSpec(name: 'b', unit: 'scalar'),
          ],
          output: VariableSpec(name: 'result', unit: 'scalar'),
          d4rtCode: 'result = a + b + z;',
        );

        final order = evaluator.getInputVariableOrder(formula);
        expect(order, ['a', 'b', 'z']);
      });

      test('passes arguments in correct alphabetical order', () {
        final formula = Formula(
          name: 'Test argument order',
          input: [
            VariableSpec(name: 'z', unit: 'scalar'),
            VariableSpec(name: 'a', unit: 'scalar'),
            VariableSpec(name: 'y', unit: 'scalar'),
          ],
          output: VariableSpec(name: 'result', unit: 'scalar'),
          d4rtCode: '''
              // Variables: a=1, y=2, z=3
              result = a * 100 + y * 10 + z;
          ''',
        );

        final result = evaluator.evaluate(formula, {'z': 3, 'a': 1, 'y': 2});

        expect(result, 123); // 1*100 + 2*10 + 3 = 123
      });
    });

    group('Error handling', () {

      test('throws exception for missing input variables', () {
        final formula = Formula(
          name: 'Test formula',
          input: [
            VariableSpec(name: 'x', unit: 'scalar'),
            VariableSpec(name: 'y', unit: 'scalar'),
          ],
          output: VariableSpec(name: 'result', unit: 'scalar'),
          d4rtCode: 'result = x + y;',
        );

        expect(
          () => evaluator.evaluate(formula, {'x': 1}), // Missing 'y'
          throwsA(isA<FormulaEvaluationException>()),
        );
      });

    });

    group('Utility methods', () {
      test('getOutputVariableName returns the single output variable name', () {
        final formula = Formula(
          name: 'Test',
          input: [VariableSpec(name: 'x', unit: 'scalar')],
          output: VariableSpec(name: 'force', unit: 'Newton'),
          d4rtCode: 'force = x;',
        );

        expect(evaluator.getOutputVariableName(formula), 'force');
      });

      test(
        'getOutputVariableMagnitude returns the output variable magnitude',
        () {
          final formula = Formula(
            name: 'Test',
            input: [VariableSpec(name: 'x', unit: 'scalar')],
            output: VariableSpec(name: 'force', unit: 'Newton'),
            d4rtCode: 'force = x;',
          );

          expect(evaluator.getOutputVariableMagnitude(formula), 'Newton');
        },
      );

      test('utility methods work correctly with valid formulas', () {
        final validFormula = Formula(
          name: 'Valid Formula',
          input: [VariableSpec(name: 'x', unit: 'scalar')],
          output: VariableSpec(name: 'result', unit: 'Newton'),
          d4rtCode: 'result = x;',
        );

        expect(evaluator.getOutputVariableName(validFormula), 'result');
        expect(evaluator.getOutputVariableMagnitude(validFormula), 'Newton');
      });

    });

    group('Data types', () {
      test('handles integer values', () {
        final formula = Formula(
          name: 'Integer test',
          input: [VariableSpec(name: 'n', unit: 'count')],
          output: VariableSpec(name: 'result', unit: 'count'),
          d4rtCode: 'result = n + 1;',
        );

        final result = evaluator.evaluate(formula, {'n': 42});
        expect(result, 43);
      });

      test('handles double values', () {
        final formula = Formula(
          name: 'Double test',
          input: [VariableSpec(name: 'x', unit: 'length')],
          output: VariableSpec(name: 'result', unit: 'area'),
          d4rtCode: 'result = x * x;',
        );

        final result = evaluator.evaluate(formula, {'x': 3.14});
        expect(result, closeTo(9.8596, 0.0001));
      });
    });
  });
}
