import 'dart:math' as Math;

import 'package:d4rt/d4rt.dart';
import 'formula_models.dart';
import 'error_handler.dart';






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
      $d4rtImports
      main()
      {
        late var result;
        result = $code;
        return result;
      }""";
    print("evaluateExpression:\n$d4rtCode");
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
    try {
      final result = _interpreter.execute(source: completeSource);
      return result;
    }
    catch (e, stack) {
      // SPECIAL CASE: If the error message starts with signalMagicString, treat it as a signal message and return it instead of throwing an exception
      // SEE signal() function in the generated d4rt code above for how this is used
      print( "#######################");
      if(e.toString().contains(signalMagicString)){
        print( "***********************");
        final signalMessage = e.toString().split(signalMagicString).last.trim();
        return signalMessage;
      }

      errorHandler.notify("$e\n$completeSource", stack);
      throw FormulaEvaluationException(
        'Error evaluating formula "${formula.name}": $e',
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

    // Validate that input values are in the allowed values list if specified
    for (final vs in formula.input) {
      final values = vs.values;
      if (values != null && values.isNotEmpty) {
        final inputValue = inputValues[vs.name];
        if (inputValue != null) {
          // Convert input value to string for comparison since allowed values are stored as strings
          final inputValueAsString = inputValue.toString();
          final containsValue = values.any((allowedValue) => allowedValue.toString() == inputValueAsString);
          
          if (!containsValue) {
            throw FormulaEvaluationException(
              'Invalid value for variable "${vs.name}" in formula "${formula.name}". '
              'Expected one of: [${values.join(', ')}], but got: $inputValue',
            );
          }
        }
      }
    }
  }



  List<String> getInputVariableOrder(Formula formula) {
    return formula.inputVarNames()..sort();
  }

  static final String d4rtImports = """
      import 'dart:math';
      import "package:d4rt_formulas.dart";
  """;

  static final String signalMagicString = "###";

  static final String signal = """
      void signal( String msg ) => throw Exception("$signalMagicString\$msg");       
  """;

  static const reservedVariableNames = { "variableValues", "indexOf", "variableAllowedValues"} ;

  String _buildCompleteSource(Formula formula, Map<String, dynamic> inputValues) {
    final buffer = StringBuffer();

    buffer.writeln("""
      $d4rtImports
      $signal
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
          final variableValues = <String, dynamic>{
    """);
    for (final entry in inputValues.entries) {
      final varName = entry.key;
      final value = entry.value;

      if (value is String) {
        final escapedValue = value.replaceAll('"', '\\"');
        buffer.writeln("""
          "$varName": "$escapedValue",
        """);
      } else {
        buffer.writeln("""
          "$varName": "$value",
        """);
      }
    }
    buffer.writeln("""
          };
    """);

    // Build a Map<String, List<String>> named `variableValues` that exposes allowed values
    // for each VariableSpec (inputs and output) to the interpreted code. Values are
    // converted to strings and quoted in the produced d4rt source.
    final variableValuesMap = <String, List<String>>{};

    // Include input VariableSpecs when they have allowed values
    for (final vs in formula.input) {
      final values = vs.values;
      if (values != null && values.isNotEmpty) {
        variableValuesMap[vs.name] = values.map((v) => v.toString()).toList(growable: false);
      }
    }
    // Explicitly include the output VariableSpec if it has allowed values
    final outValues = formula.output.values;
    if (outValues != null && outValues.isNotEmpty) {
      variableValuesMap[formula.output.name] = outValues.map((v) => v.toString()).toList(growable: false);
    }

    // Write the variableValues map into the generated source without escaping names/values
    buffer.writeln("final variableAllowedValues = {");
    variableValuesMap.forEach((name, list) {
      final listLiteral = list.map((s) => '"' + s + '"').join(', ');
      buffer.writeln('  "' + name + '": [' + listLiteral + '],');
    });
    buffer.writeln('};');

    // Some functions to deal with string values
    buffer.writeln("""
      // If return type is int, there is an error converting double to int 🤷‍
      dynamic indexOf(String inputName) {
        String value = variableValues[inputName];
        String allowedValues = variableAllowedValues[inputName];
        dynamic ret = allowedValues.indexOf(value) as int;
        return ret as int;
      }
      """);

    buffer.writeln("""
      late var ${formula.output.name};
      ${formula.d4rtCode}
      return ${formula.output.name};
      }
      """);

     return buffer.toString();
   }
 }
