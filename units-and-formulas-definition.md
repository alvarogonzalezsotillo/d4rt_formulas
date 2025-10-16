# Units and Formulas Definition Format

## Units Specification

Units are defined in `.d4rt.units` files using JSON arrays. Each unit can have:

```dart
{
  "name": "unit name",      // Full name (required)
  "symbol": "abbr",         // Symbol (required)
  "isBase": true,           // Mark as base unit (exclusive with baseUnit)
  "baseUnit": "parent",     // Reference unit for conversions
  "factor": 1.0,           // Conversion factor to base unit
  "toBase": "x * 1000",     // Conversion code to base (expression)
  "fromBase": "x / 1000"    // Conversion code from base (expression)
}
```

### Key Rules:
1. Use either `isBase` OR `baseUnit`+conversion (factor or code)
2. Factor-based units use simple multiplicative conversions
3. Code-based units require both `toBase` and `fromBase` Dart expressions
4. Code expressions:
   - Use `x` as input variable
   - Must return a numeric value
   - Can use math functions via `dart:math`

### Examples:
**Simple Factor-based:**
```json
{
  "name": "kilometer",
  "symbol": "km",
  "baseUnit": "meter",
  "factor": 1000
}
```

**Code-based Conversion:**
```json
{
  "name": "Fahrenheit",
  "symbol": "°F", 
  "baseUnit": "Kelvin",
  "toBase": "(x - 32) * 5/9 + 273.15",
  "fromBase": "(x - 273.15) * 9/5 + 32"
}
```

## Formulas Specification

Formulas are defined in `.d4rt` files using JSON arrays. Each formula has:

```dart
{
  "name": "Formula Name",       // Required
  "description": "Markdown",    // Optional
  "input": [                    // List of input variables
    {
      "name": "varName",        // Variable identifier
      "unit": "unitName"        // Base unit for calculations
    }
  ],
  "output": {                   // Single output variable
    "name": "resultVar",
    "unit": "outputUnit"  
  },
  "d4rtCode": "Dart code",      // Calculation logic
  "tags": ["physics", "energy"] // Categories
}
```

### Formula Code Rules:
1. Input variables are declared as `final`
2. Output variable must be assigned
3. Can use:
   - Basic math operators
   - `dart:math` functions
   - Custom functions from FormulaEvaluator
4. Example:
```dart
// Inputs: m (kg), v (m/s)
d4rtCode: "KE = 0.5 * m * pow(v, 2);"
```

### Conversion Code Examples

**Expression-style:**
```dart
// Simple factor conversion
final x = 5; // Value in source unit
main() => x * 1000; // Convert to base unit
```

**Statement-style:**
```dart 
// Complex conversion with multiple steps
final x = 212; // Fahrenheit
main() {
  var celsius = (x - 32) * 5/9;
  return celsius + 273.15; // Convert to Kelvin
}
```

## Validation Rules

1. Units must form a DAG (no circular dependencies)
2. Formulas must declare all input variables
3. Output variable must be assigned in d4rtCode
4. Unit conversion code must handle numeric inputs
5. Base units must exist before derived units
