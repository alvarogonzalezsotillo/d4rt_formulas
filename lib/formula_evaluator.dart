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
  static Number log(Number x) => Math.log(x);
  static Number pow(Number b, Number e) => Math.pow(b,e) as Number;
}

class FormulaEvaluator {
  final D4rt _interpreter;

  FormulaEvaluator([D4rt? interpreter]) : _interpreter = interpreter ?? D4rt(){
    prepareInterpreter(_interpreter);
  }

  Number getNumberValueOf(String s){
    return double.parse(s);
  }

  void prepareInterpreter(D4rt interpreter){
    final myMathDefinition = BridgedClass(
      nativeType: MyMath,
      name: 'Math',
      staticMethods: {
        'pow': (visitor, positionalArgs, namedArgs) {
          final Number base = getNumberValueOf( positionalArgs[0].toString() );
          final Number exp = getNumberValueOf( positionalArgs[1].toString() );
          return MyMath.pow(base,exp);
        },
      }
    );
    
    interpreter.registerBridgedClass(myMathDefinition, 'package:myapp/my_math.dart');
  }

  
  dynamic evaluate(Formula formula, Map<String, dynamic> inputValues) {
    _validateInputValues(formula, inputValues);

    try {
      // Build the complete d4rt source code with variable declarations
      final completeSource = _buildCompleteSource(formula, inputValues);

      // Execute the code using d4rt (no args needed since variables are in source)
      final result = _interpreter.execute(source: completeSource);
      
      return result;
    } catch (e) {
      throw FormulaEvaluationException(
        'Failed to execute formula "${formula.name}"',
        e,
      );
    }
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

  String _buildCompleteSource(Formula formula, Map<String, dynamic> inputValues) {
    final buffer = StringBuffer();

    buffer.writeln("import 'package:myapp/my_math.dart';");
    buffer.writeln("main(){");

    for (final entry in inputValues.entries) {
      final varName = entry.key;
      final value = entry.value;
      
      if (value is String) {
        final escapedValue = value.replaceAll('"', '\\"');
        buffer.writeln('var $varName = "$escapedValue";');
      } else {
        buffer.writeln('var $varName = $value;');
      }
    }
    buffer.writeln("late var ${getOutputVariableName(formula)};");
    
    buffer.writeln(formula.d4rtCode);
    buffer.writeln("return ${getOutputVariableName(formula)};");
    buffer.writeln("}");
    
    return buffer.toString();
  }
}
