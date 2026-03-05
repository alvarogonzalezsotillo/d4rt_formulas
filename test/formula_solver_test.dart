import 'package:d4rt_formulas/formula_evaluator.dart';
import 'package:d4rt_formulas/formula_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:math' as Math;


void main() {

  group("Formulas", (){

    test("Solve x^2 formula", () {
      final formula = Formula(
        name: 'Test x^2',
        input: [
          VariableSpec(name: 'x', unit: 'scalar'),
        ],
        output: VariableSpec(name: 'y', unit: 'scalar'),
        d4rtCode: 'y = x*x;',
      );

      var solution = formulaSolver(formula, "x", {"y": 25}, maxDelta: 1e-10);
      expect( solution, closeTo(5, 1e-10));
    });

  });

  group('Native functions', () {
    test("Solve x^2", () {
      Number f(Number x) => x * x;
      var root = functionSolver(f, hint: 10, step: 1);
      expect(root, closeTo(0, 0.1));
    });


    test("Solve (x-1000)^2", () {
      Number f(Number x) => (x - 1000) * (x - 1000);
      var root = functionSolver(f, hint: 10, step: 1, maxTries: 1000);
      expect(root, closeTo(1000, 0.1));
    });

    test("Solve x^2 + 1", () {
      Number f(Number x) => x * x + 1;

      expect(() => functionSolver(f, hint: 10, step: 1),
          throwsA(isA<NoSolutionException>()));
    });

    test("Solve (x-2)(x-10", () {
      Number f(Number x) => (x - 2) * (x - 10);

      expect(functionSolver(f, hint: 10, step: 1), closeTo(10, 0.1));
    });

    test('Solve sqrt(x) = 2  => x = 4', () {
      Number f(Number x) => Math.sqrt(x) - 2;
      var root = functionSolver(f, hint: 5, step: 1);
      expect(root, closeTo(4, 0.1));
    });

    test('Solve sin(x) = 0 near pi (hint 3)', () {
      Number f(Number x) => Math.sin(x);
      var root = functionSolver(f, hint: 3, step: 1);
      expect(root, closeTo(Math.pi, 0.01));
    });

    test('Solve tan(x) = 1 => x = pi/4', () {
      Number f(Number x) => Math.tan(x) - 1;
      var root = functionSolver(f, hint: 0, step: 1);
      expect(root, closeTo(Math.pi / 4, 0.01));
    });

    test('Solve exp(x) = 2 => x = ln(2)', () {
      Number f(Number x) => Math.exp(x) - 2;
      var root = functionSolver(f, hint: 1, step: 1);
      expect(root, closeTo(Math.log(2), 0.01));
    });
  });

}
