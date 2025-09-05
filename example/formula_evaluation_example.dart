/// Example demonstrating formula evaluation using the d4rt interpreter.
/// 
/// This example shows how to:
/// 1. Create formulas with input/output specifications
/// 2. Evaluate formulas with different input values
/// 3. Handle evaluation errors
library;

import 'package:d4rt_formulas/d4rt_formulas.dart';

void main() {
  print('=== Formula Evaluation Example ===\n');
  
  // Create a formula evaluator
  final evaluator = FormulaEvaluator();
  
  // Example 1: Newton's Second Law (F = m * a)
  print('1. Newton\'s Second Law of Motion');
  final newtonFormula = Formula(
    name: "Newton's Second Law",
    input: [
      VariableSpec(name: 'm', magnitude: 'mass'),
      VariableSpec(name: 'a', magnitude: 'acceleration'),
    ],
    output:  VariableSpec(name: 'F', magnitude: 'force'),
    d4rtCode: '''
        return m * a;
    ''',
  );
  
  try {
    final force = evaluator.evaluate(newtonFormula, {
      'm': 10.0,  // 10 kg
      'a': 9.8,   // 9.8 m/s²
    });
    
    print('   Mass: 10.0 kg');
    print('   Acceleration: 9.8 m/s²');
    print('   Calculated Force: $force N');
    print('   Output variable: ${evaluator.getOutputVariableName(newtonFormula)}');
    print('   Output magnitude: ${evaluator.getOutputVariableMagnitude(newtonFormula)}');
  } catch (e) {
    print('   Error: $e');
  }
  
  print('');
  
  // Example 2: Quadratic Formula Discriminant
  print('2. Quadratic Formula Discriminant (Δ = b² - 4ac)');
  final discriminantFormula = Formula(
    name: 'Quadratic Discriminant',
    input: [
      VariableSpec(name: 'a', magnitude: 'coefficient'),
      VariableSpec(name: 'b', magnitude: 'coefficient'),
      VariableSpec(name: 'c', magnitude: 'coefficient'),
    ],
    output : VariableSpec(name: 'discriminant', magnitude: 'scalar'),
    d4rtCode: '''
        return b * b - 4 * a * c;
    ''',
  );
  
  try {
    final discriminant = evaluator.evaluate(discriminantFormula, {
      'a': 1,
      'b': 5,
      'c': 6,
    });
    
    print('   Equation: 1x² + 5x + 6 = 0');
    print('   a = 1, b = 5, c = 6');
    print('   Discriminant: $discriminant');
    
    if (discriminant > 0) {
      print('   → Two real solutions');
    } else if (discriminant == 0) {
      print('   → One real solution');
    } else {
      print('   → No real solutions');
    }
  } catch (e) {
    print('   Error: $e');
  }
  
  print('');
  
  // Example 3: Circle Area
  print('3. Circle Area (A = π * r²)');
  final circleAreaFormula = Formula(
    name: 'Circle Area',
    input: [
      VariableSpec(name: 'r', magnitude: 'length'),
    ],
    output: VariableSpec(name: 'A', magnitude: 'area'),

    d4rtCode: '''
        var pi = 3.14159265359;
        return pi * r * r;
    ''',
  );
  
  try {
    final area = evaluator.evaluate(circleAreaFormula, {
      'r': 5.0,  // radius = 5 units
    });
    
    print('   Radius: 5.0 units');
    print('   Calculated Area: $area square units');
  } catch (e) {
    print('   Error: $e');
  }
  
  print('');
  
  // Example 4: Error handling
  print('4. Error Handling Example');
  try {
    // Try to evaluate with missing input variable
    evaluator.evaluate(newtonFormula, {
      'm': 10.0,
      // Missing 'a' variable
    });
  } catch (e) {
    print('   Expected error when missing input variable:');
    print('   $e');
  }
  
  print('');
  
  // Example 5: Complex calculation
  print('5. Compound Interest Formula');
  final compoundInterestFormula = Formula(
    name: 'Compound Interest',
    input: [
      VariableSpec(name: 'P', magnitude: 'currency'),      // Principal
      VariableSpec(name: 'r', magnitude: 'rate'),          // Annual interest rate
      VariableSpec(name: 'n', magnitude: 'count'),         // Times compounded per year
      VariableSpec(name: 't', magnitude: 'time'),          // Time in years
    ],
    output: VariableSpec(name: 'A', magnitude: 'currency'),      // Final amount
    d4rtCode: '''
        // A = P * (1 + r/n)^(n*t)
        var rate_per_period = r / n;
        var base = 1 + rate_per_period;
        var exponent = n * t;
        
        // Calculate base^exponent using repeated multiplication
        // (d4rt may not have built-in pow function)
        var result = P;
        for (var i = 0; i < exponent; i++) {
          result = result * base;
        }
        
        return result;
    ''',
  );
  
  try {
    final finalAmount = evaluator.evaluate(compoundInterestFormula, {
      'P': 1000.0,    // \$1000 principal
      'r': 0.05,      // 5% annual interest rate
      'n': 12,        // Compounded monthly
      't': 2,         // 2 years
    });
    
    print('   Principal: \$1000');
    print('   Annual interest rate: 5%');
    print('   Compounded: 12 times per year (monthly)');
    print('   Time: 2 years');
    print('   Final amount: \$$finalAmount');
  } catch (e) {
    print('   Error: $e');
  }
  
  print('\n=== Example Complete ===');
}
