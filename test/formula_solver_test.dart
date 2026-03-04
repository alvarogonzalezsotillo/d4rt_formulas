import 'package:d4rt_formulas/formula_evaluator.dart';
import 'package:d4rt_formulas/formula_models.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  test("Solve x^2", () {
    Number f(Number x) => x*x;
    var root = functionSolver(f, hint: 10, step: 1);
    expect(root, closeTo(0, 0.1));
  });

  test("Solve x^2 + 1", () {
    Number f(Number x) => x*x+1;

    expect(()=> functionSolver(f, hint: 10, step: 1), throwsA(isA<NoSolutionException>()));
  });

  test("Solve (x-2)(x-10", () {
    Number f(Number x) => (x-2)*(x-10);

    expect( functionSolver(f, hint: 10, step: 1), closeTo(10, 0.1));
  });


}
