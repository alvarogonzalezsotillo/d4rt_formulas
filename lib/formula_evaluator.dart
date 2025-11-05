import 'dart:math' as Math;

import 'package:d4rt/d4rt.dart';
import 'formula_models.dart';






/// Exception thrown when formula evaluation fails
class FormulaEvaluationException implements Exception {
  final String message;
  final Object? cause;

  const FormulaEvaluationException(this.message, [this.cause]);

  @override
  String toString() => 'FormulaEvaluationException: $message'
      '${cause != null ? ' (caused by: $cause)' : ''}';
}

class MyMath{
  static Number myLog(Number x) => Math.log(x);
  static Number myPow(Number b, Number e) => Math.pow(b,e) as Number;
}

class FormulaResult{
  const FormulaResult();
}

class StringResult extends FormulaResult{
  final String value;
  const StringResult(this.value);
}

class NumberResult extends FormulaResult{
  final Number value;
  const NumberResult(this.value);
}

class FormulaEvaluator {
  final D4rt _interpreter;

  static D4rt createDefaultInterpreter() => D4rt();

  FormulaEvaluator([D4rt? interpreter]) : _interpreter = interpreter ?? createDefaultInterpreter(){
    prepareInterpreter(_interpreter);
  }

  static Number _getNumberValueOf(String s){
    return double.parse(s);
  }

  static void prepareInterpreter(D4rt interpreter){
    final myMathDefinition = BridgedClass(
      nativeType: MyMath,
      name: 'MyMath',
      staticMethods: {
        'myPow': (visitor, positionalArgs, namedArgs) {
          final Number base = _getNumberValueOf( positionalArgs[0].toString() );
          final Number exp = _getNumberValueOf( positionalArgs[1].toString() );
          return MyMath.myPow(base,exp);
        },
        'myLog': (visitor, positionalArgs, namedArgs) {
          final Number x = _getNumberValueOf( positionalArgs[0].toString() );
          return MyMath.myLog(x);
        },
      }
    );
    
    interpreter.registerBridgedClass(myMathDefinition, "package:d4rt_formulas.dart");
  }

  static FormulaResult evaluateExpression(String code, [D4rt? interpreter]) {
    final d4rtInterpreter = interpreter ?? createDefaultInterpreter();
    prepareInterpreter(d4rtInterpreter);
    final d4rtCode = """
      ${d4rtImports}
      main()
      {
        late var result;
        result = $code;
        return result;
      }""";
    //print("evaluateExpression:\n$d4rtCode");
    final result = d4rtInterpreter.execute(source: d4rtCode);
    switch ( result ){
      case int value:
        return NumberResult(value.toDouble());
      case Number value:
        return NumberResult(value);
      case String value:
        return StringResult(value);
      default:
        throw FormulaEvaluationException( "Unexpected result type: ${result.runtimeType} -- $result" );
    }
  }
  
  dynamic evaluate(Formula formula, Map<String, dynamic> inputValues) {
    _validateInputValues(formula, inputValues);
    final completeSource = _buildCompleteSource(formula, inputValues);
    final result = _interpreter.execute(source: completeSource);
    return result;
  }

  void _validateInputValues(Formula formula, Map<String, dynamic> inputValues) {
    final missingVars = <String>[];
    
    for (final inputVar in formula.inputVarNames()) {
      if (!inputValues.containsKey(inputVar)) {
        missingVars.add(inputVar);
      }
    }
    
    if (missingVars.isNotEmpty) {
      throw FormulaEvaluationException(
        'Missing required input variables for formula "${formula.name}": '
        '${missingVars.join(', ')}',
      );
    }
  }

  String getOutputVariableName(Formula formula) {
    return formula.output.name;
  }

  String getOutputVariableMagnitude(Formula formula) {
    return formula.output.unit;
  }

  List<String> getInputVariableOrder(Formula formula) {
    return formula.inputVarNames()..sort();
  }

  static final String d4rtImports = """
      import 'dart:math';
      import "package:d4rt_formulas.dart";
  """;

  String _buildCompleteSource(Formula formula, Map<String, dynamic> inputValues) {
    final buffer = StringBuffer();

    buffer.writeln("""
      $d4rtImports
      
      main()
      {
      """
    );


    for (final entry in inputValues.entries) {
      final varName = entry.key;
      final value = entry.value;
      
      if (value is String) {
        final escapedValue = value.replaceAll('"', '\\"');
        buffer.writeln("""
          final $varName = "$escapedValue";
        """);
      } else {
        buffer.writeln("""
          final $varName = $value;
        """);
      }
    }
    buffer.writeln("""
      late var ${getOutputVariableName(formula)};
      ${formula.d4rtCode}
      return ${getOutputVariableName(formula)};
      }
      """
    );
    
    return buffer.toString();
  }
}
