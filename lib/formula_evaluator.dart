/// Formula evaluator that executes d4rt code with input variables and
/// returns the value of the single output variable.
///
/// The evaluator assumes that:
/// - A formula has exactly one output variable
/// - The d4rt code defines a main function with parameters matching input variables
/// - The d4rt code when executed returns the value of that output variable
/// - Input variables are provided as a Map<String, dynamic>

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

/// Evaluates formulas using the d4rt interpreter
class FormulaEvaluator {
  final D4rt _interpreter;

  /// Creates a new formula evaluator with an optional d4rt interpreter instance.
  /// If no interpreter is provided, a new one will be created.
  FormulaEvaluator([D4rt? interpreter]) : _interpreter = interpreter ?? D4rt();

  /// Evaluates a formula with the given input values.
  /// 
  /// The [formula] must have exactly one output variable.
  /// The [inputValues] map must contain values for all input variables defined
  /// in the formula.
  /// 
  /// The formula's d4rt_code should define a main function that uses the input
  /// variable names directly. The evaluator will inject variable declarations
  /// before the formula code. For example:
  /// ```
  /// main() {
  ///   return m * a;  // Returns Force = mass * acceleration
  /// }
  /// ```
  /// 
  /// Returns the computed value of the single output variable.
  /// 
  /// Throws [FormulaEvaluationException] if:
  /// - The formula has zero or more than one output variable
  /// - Required input variables are missing
  /// - The d4rt code execution fails
  dynamic evaluate(Formula formula, Map<String, dynamic> inputValues) {
    _validateFormula(formula);
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

  /// Validates that the formula has exactly one output variable
  void _validateFormula(Formula formula) {
    if (formula.output.length != 1) {
      throw FormulaEvaluationException(
        'Formula "${formula.name}" must have exactly one output variable, '
        'but has ${formula.output.length}',
      );
    }
  }

  /// Validates that all required input variables are provided
  void _validateInputValues(Formula formula, Map<String, dynamic> inputValues) {
    final missingVars = <String>[];
    
    for (final inputVar in formula.input.keys) {
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

  /// Gets the name of the single output variable from the formula
  String getOutputVariableName(Formula formula) {
    _validateFormula(formula);
    return formula.output.keys.first;
  }

  /// Gets the magnitude of the single output variable from the formula
  String getOutputVariableMagnitude(Formula formula) {
    _validateFormula(formula);
    return formula.output.values.first.magnitude;
  }

  /// Gets the ordered list of input variable names (alphabetically sorted)
  List<String> getInputVariableOrder(Formula formula) {
    return formula.input.keys.toList()..sort();
  }

  /// Builds the complete d4rt source code by injecting variable declarations
  /// before the formula's d4rt code
  String _buildCompleteSource(Formula formula, Map<String, dynamic> inputValues) {
    final buffer = StringBuffer();
    
    // Add variable declarations for all input variables
    for (final entry in inputValues.entries) {
      final varName = entry.key;
      final value = entry.value;
      
      // Handle different value types appropriately for d4rt
      if (value is String) {
        // Escape quotes in string values
        final escapedValue = value.replaceAll('"', '\\"');
        buffer.writeln('var $varName = "$escapedValue";');
      } else {
        // For numbers and other types, use direct representation
        buffer.writeln('var $varName = $value;');
      }
    }
    
    // Add a blank line for readability
    buffer.writeln();
    
    // Add the formula's d4rt code
    buffer.write(formula.d4rtCode);
    
    return buffer.toString();
  }
}
