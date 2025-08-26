
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
  /// The [formula] must have exactly one output variable (validated during construction).
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
  /// - Required input variables are missing
  /// - The d4rt code execution fails
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

  /// Validates that all required input variables are provided
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

  /// Gets the name of the single output variable from the formula
  String getOutputVariableName(Formula formula) {
    return formula.output.name;
  }

  /// Gets the magnitude of the single output variable from the formula
  String getOutputVariableMagnitude(Formula formula) {
    // Formula construction already ensures exactly one output variable
    return formula.output.magnitude;
  }

  /// Gets the ordered list of input variable names (alphabetically sorted)
  List<String> getInputVariableOrder(Formula formula) {
    return formula.inputVarNames()..sort();
  }

  /// Builds the complete d4rt source code by injecting variable declarations
  /// before the formula's d4rt code
  String _buildCompleteSource(Formula formula, Map<String, dynamic> inputValues) {
    final buffer = StringBuffer();

    buffer.writeln("main(){");

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
    buffer.writeln("late var ${getOutputVariableName(formula)};");
    
    // Add the formula's d4rt code
    buffer.writeln(formula.d4rtCode);
    buffer.writeln("return ${getOutputVariableName(formula)};");
    buffer.writeln("}");
    
    return buffer.toString();
  }
}
