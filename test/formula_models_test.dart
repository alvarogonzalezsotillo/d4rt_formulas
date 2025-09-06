
import 'package:d4rt_formulas/formula_evaluator.dart';
import 'package:test/test.dart';
import 'package:d4rt_formulas/formula_models.dart';

void main() {

  Future<UnitCorpus> createTestCorpus() async {
    final resource = Resource("lib/units/distance.d4rt.units");
    final literal = await resource.readAsString(encoding: utf8);
    final units = UnitSpec.fromArrayStringLiteral(literal);
    final corpus = UnitCorpus();
    corpus.loadUnits(units);
    return corpus;
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


  test('Parses Newton\'s second law formula from set literal', () {
    final setLiteral = {
      "name": "Newton's second law",
      "input": [
        { "name": 'm', "magnitude": 'mass'},
        { "name": 'a', "magnitude": 'acceleration'}
      ],
      "output": { "name": 'F', "magnitude": 'force'},
      "d4rtCode": '''
              F = a * m;
          '''
    };

    final formula = Formula.fromSet(setLiteral);
    final evaluator = FormulaEvaluator();

    final result = evaluator.evaluate(formula, {
      'm': 10.0, // 10 kg
      'a': 9.8, // 9.8 m/s²
    });

    expect(result, 98.0); // F = m * a = 10 * 9.8 = 98 N
  });

  test( 'd4rt parses formula from literal', (){
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


  test( 'd4rt parses formula from list literal', (){
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

