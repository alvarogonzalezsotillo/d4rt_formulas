import 'dart:convert';

import 'package:d4rt/d4rt.dart';
import 'package:d4rt_formulas/formula_evaluator.dart';
import 'package:test/test.dart';
import 'package:d4rt_formulas/formula_models.dart';

void main() {

  test('Parses Newton\'s second law formula from set literal', () {
    final setLiteral = {
      "name": "Newton's second law",
      "input": [
        { "name": 'm', "magnitude": 'mass'},
        { "name": 'a', "magnitude": 'acceleration'}
      ],
      "output": { "name": 'F', "magnitude": 'force'},
      "d4rtCode": '''
              return a * m;
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
              return a * m;
          '''
    }    
    """;

    var d4rt = D4rt();
    final buffer = StringBuffer();
    buffer.write( "main(){ return $literal; }");
    final code = buffer.toString();

    final Map<Object?, Object?> setLiteral = d4rt.execute(source: code);

    final formula = Formula.fromSet(setLiteral);
    final evaluator = FormulaEvaluator();

    final result = evaluator.evaluate(formula, {
      'm': 10.0, // 10 kg
      'a': 9.8, // 9.8 m/s²
    });

    expect(result, 98.0); // F = m * a = 10 * 9.8 = 98 N

  });

}

