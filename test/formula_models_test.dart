import 'package:d4rt_formulas/corpus.dart';
import 'package:d4rt_formulas/defaults/default_corpus.dart';
import 'package:d4rt_formulas/formula_evaluator.dart';
import 'package:test/test.dart';
import 'package:d4rt_formulas/formula_models.dart';
import 'dart:convert' show utf8;

import 'package:resource_portable/resource.dart' show Resource;

void main() {

  Future<Corpus> createTestCorpus() async {
    return createDefaultCorpus();
  }

  test("Parses unit", () {
    final setLiteral = {"name": "kilometer", "symbol": "km", "baseUnit": "meter", "factor": 1000};
    final unit = UnitSpec.fromSet(setLiteral);
    expect(unit.name, "kilometer");
    expect(unit.symbol, "km");
    expect(unit.baseUnit, "meter");
    expect(unit.factorFromUnitToBase, 1000);
    expect(unit.codeFromUnitToBase, null);
    expect(unit.codeFromBaseToUnit, null);
  });

  test("From km to in", () async {
    final corpus = await createTestCorpus();
    final inches = corpus.convert(1, "kilometer", "inch");
    expect( inches, closeTo(39370.078,0.001) );
  });

  test("From furlong to base", () async {
    final corpus = await createTestCorpus();
    final m = corpus.convert(1, "furlong", "meter");
    expect(m,closeTo(201.168,0.001));
  });

  test("From base to furlong", () async {
    final corpus = await createTestCorpus();
    final m = corpus.convert(201.168, "meter", "furlong");
    expect(m,closeTo(1,0.001));
  });

  test("From C to F", () async {
    final corpus = await createTestCorpus();
    final m = corpus.convert(37, "Celsius", "Fahrenheit");
    expect(m,closeTo(98.6,0.001));
  });

  test("From K to F", () async {
    final corpus = await createTestCorpus();
    final m = corpus.convert(37, "Kelvin", "Fahrenheit");
    expect(m,closeTo(-393.07,0.001));
  });

  test("From C to K", () async {
    final corpus = await createTestCorpus();
    final m = corpus.convert(100, "Celsius", "Kelvin");
    expect(m,closeTo(373.15,0.001));
  });

  test('Parses Newton\'s second law formula from set literal', () {
    final setLiteral = {
      "name": "Newton's second law",
      "input": [
        {"name": 'm', "magnitude": 'mass'},
        {"name": 'a', "magnitude": 'acceleration'},
      ],
      "output": {"name": 'F', "magnitude": 'force'},
      "d4rtCode": '''
              F = a * m;
          ''',
    };

    final formula = Formula.fromSet(setLiteral);
    final evaluator = FormulaEvaluator();

    final result = evaluator.evaluate(formula, {
      'm': 10.0, // 10 kg
      'a': 9.8, // 9.8 m/s²
    });

    expect(result, 98.0); // F = m * a = 10 * 9.8 = 98 N
  });

  test('d4rt parses formula from literal', () {
    final literal = """
    {
      "name": "Newton's second law",
      "input": [
        { "name": 'm', "magnitude": 'mass'},
        { "name": 'a', "magnitude": 'acceleration'}
      ],
      "output": { "name": 'F', "magnitude": 'force'},
      "d4rtCode": '''
              F = a * m;
          '''
    }    
    """;

    final formula = Formula.fromStringLiteral(literal);
    final evaluator = FormulaEvaluator();

    final result = evaluator.evaluate(formula, {
      'm': 10.0, // 10 kg
      'a': 9.8, // 9.8 m/s²
    });

    expect(result, 98.0); // F = m * a = 10 * 9.8 = 98 N
  });

  test('d4rt parses formula from list literal', () {
    final literal = """
    [
    {
      "name": "Newton's second law",
      "input": [
        { "name": 'm', "magnitude": 'mass'},
        { "name": 'a', "magnitude": 'acceleration'}
      ],
      "output": { "name": 'F', "magnitude": 'force'},
      "d4rtCode": '''
              F = a * m;
          '''
    },
    {
      "name": "Newton's second law, again",
      "input": [
        { "name": 'mass', "magnitude": 'mass'},
        { "name": 'acc', "magnitude": 'acceleration'}
      ],
      "output": { "name": 'force', "magnitude": 'force'},
      "d4rtCode": '''
              force = mass * acc;
          '''
    }
    ]   
    """;

    final formulas = Formula.fromArrayStringLiteral(literal);
    final evaluator = FormulaEvaluator();

    final formula = formulas[0];

    final result = evaluator.evaluate(formula, {
      'm': 10.0, // 10 kg
      'a': 9.8, // 9.8 m/s²
    });

    expect(result, 98.0); // F = m * a = 10 * 9.8 = 98 N
  });
}
