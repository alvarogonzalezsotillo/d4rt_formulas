# Formula and Unit File Format Guide

This document describes the format for contributing formulas and units to the d4rt_formulas project. It is intended for formula contributors and developers.

---

## Table of Contents

1. [Overview](#overview)
2. [Formula Files](#formula-files)
3. [Unit Files](#unit-files)
4. [Writing Descriptions](#writing-descriptions)
5. [Best Practices](#best-practices)
6. [Examples](#examples)

---

## Overview

The project uses two types of asset files:

| File Type    | Location           | Extension     | Format                          |
|--------------|--------------------|---------------|---------------------------------|
| **Formulas** | `assets/formulas/` | `.d4rt`       | Dart array literals (JSON-like) |
| **Units**    | `assets/units/`    | `.d4rt.units` | Dart array literals (JSON-like) |

Both formats use Dart set/array literals with map entries. Files are parsed at runtime to populate the formula calculator.

---

## Formula Files

### File Structure

Formula files are organized by topic (e.g., `geometry.d4rt`, `electromagnetism.d4rt`). Each file contains a Dart array literal with formula objects:

```dart
[
  {
    "name": "Formula Name",
    "description": r"""Markdown description with LaTeX""",
    "input": [
      {"name": "variable1", "unit": "unit_name"},
      {"name": "variable2", "unit": "unit_name"}
    ],
    "output": {"name": "result", "unit": "unit_name"},
    "d4rtCode": "result = expression;",
    "tags": ["tag1", "tag2"]
  },
  // More formulas...
]
```

### Formula Object Fields

| Field         | Type   | Required | Description                                                                              |
|---------------|--------|----------|------------------------------------------------------------------------------------------|
| `name`        | String | Yes      | Human-readable formula name                                                              |
| `description` | String | Yes      | Markdown description with LaTeX math (see [Writing Descriptions](#writing-descriptions)) |
| `input`       | Array  | Yes      | List of input variables with their units                                                 |
| `output`      | Object | Yes      | Output variable name and unit                                                            |
| `d4rtCode`    | String | Yes      | Dart code that computes the result                                                       |
| `tags`        | Array  | Yes      | Categorization tags for search/filter                                                    |

### Input/Output Format

**Input variables:**
```dart
"input": [
  {"name": "m", "unit": "kilogram"},
  {"name": "a", "unit": "meters per square second"}
]
```

**Output variable:**
```dart
"output": {"name": "F", "unit": "newton"}
```

### Unit Names

Unit names must match entries in the `assets/units/` directory. Use the full unit name (lowercase), not the symbol:

| Correct               | Incorrect |
|-----------------------|-----------|
| `"meter"`             | `"m"`     |
| `"kilogram"`          | `"kg"`    |
| `"meters per second"` | `"m/s"`   |
| `"square meter"`      | `"m²"`    |

### Dart Code (`d4rtCode`)

The `d4rtCode` field contains valid Dart code that:
- Uses input variable names directly
- Assigns the result to the output variable name
- Can use Dart's `math` library functions (`sin`, `cos`, `sqrt`, `pow`, `pi`, etc.)

**Simple formula:**
```dart
"d4rtCode": "F = m * a;"
```

**Multi-line formula:**
```dart
"d4rtCode": """
   var radians = angle * (pi / 180);
   result = sin(radians);
"""
```

**With validation:**
```dart
"d4rtCode": """
   if (a + b < c) {
      signal("Invalid triangle: sides do not satisfy triangle inequality");
   }
   var s = (a + b + c) / 2;
   A = sqrt(s * (s - a) * (s - b) * (s - c));
"""
```

---

## Unit Files

### File Structure

Unit files define units of measurement organized by category (e.g., `distance.d4rt.units`, `force.d4rt.units`). Each file contains a Dart array literal with unit objects:

```dart
[
  {"name": "meter", "symbol": "m", "isBase": true},
  {"name": "kilometer", "symbol": "km", "baseUnit": "meter", "factor": 1000},
  // More units...
]
```

### Unit Object Fields

| Field      | Type    | Required    | Description                                                         |
|------------|---------|-------------|---------------------------------------------------------------------|
| `name`     | String  | Yes         | Full unit name (lowercase)                                          |
| `symbol`   | String  | Yes         | Unit symbol for display                                             |
| `isBase`   | Boolean | Conditional | `true` if this is a base unit (no conversion needed)                |
| `baseUnit` | String  | Conditional | Name of the base unit for conversion                                |
| `factor`   | Number  | Conditional | Multiplication factor to convert to base unit                       |
| `toBase`   | String  | Conditional | Expression/code to convert to base unit (for complex conversions)   |
| `fromBase` | String  | Conditional | Expression/code to convert from base unit (for complex conversions) |

### Base Units vs Derived Units

**Base units** define the reference for a category:
```dart
{"name": "meter", "symbol": "m", "isBase": true}
{"name": "newton", "symbol": "N", "isBase": true}
{"name": "joule", "symbol": "J", "isBase": true}
{"name": "Kelvin", "symbol": "K", "isBase": true}
```

**Derived units** specify conversion to their base unit. There are two types:

#### Simple Linear Conversions (using `factor`)

For units where conversion is a simple multiplication:

```dart
{"name": "kilometer", "symbol": "km", "baseUnit": "meter", "factor": 1000}
{"name": "inch", "symbol": "in", "baseUnit": "meter", "factor": 0.0254}
{"name": "pound-force", "baseUnit": "newton", "factor": 4.44822}
```

The `factor` converts **from** the defined unit **to** the base unit:

```dart
// 1 kilometer = 1000 meters
{"name": "kilometer", "baseUnit": "meter", "factor": 1000}

// 1 inch = 0.0254 meters
{"name": "inch", "baseUnit": "meter", "factor": 0.0254}
```

#### Complex Conversions (using `toBase` and `fromBase`)

For units requiring non-linear conversions (e.g., temperature scales), use `toBase` and `fromBase` expressions. The variable `x` represents the value to convert.

**Example: Celsius to Kelvin**
```dart
{
  "name": "Celsius",
  "symbol": "°C",
  "baseUnit": "Kelvin",
  "toBase": "x + 273.15",      // °C → K
  "fromBase": "x - 273.15",    // K → °C
}
```

**Example: Fahrenheit to Kelvin**
```dart
{
  "name": "Fahrenheit",
  "symbol": "°F",
  "baseUnit": "Kelvin",
  "toBase": "(x - 32) * 5/9 + 273.15",   // °F → K
  "fromBase": "(x - 273.15) * 9/5 + 32", // K → °F
}
```

**Example: Multi-line conversion (Gas Mark to Kelvin)**
```dart
{
  "name": "Gas Mark",
  "symbol": "GM",
  "baseUnit": "Kelvin",
  "toBase": r"""
    if (x < 1) {
      double celsius = (243 - 25 * (log(1 / x) / log(2))) / 1.8;
      return celsius + 273.15;
    } else {
      double celsius = x * 14 + 121;
      return celsius + 273.15;
    }
  """,
  "fromBase": """
    double celsius = x - 273.15;
    if (celsius < 135) {
      return pow(2, (1.8 * celsius - 243) / 25);
    } else {
      return (celsius - 121) / 14;
    }
  """
}
```

### Common Temperature Conversions

| Unit       | toBase (→ K)                 | fromBase (← K)               |
|------------|------------------------------|------------------------------|
| Celsius    | `x + 273.15`                 | `x - 273.15`                 |
| Fahrenheit | `(x - 32) * 5/9 + 273.15`    | `(x - 273.15) * 9/5 + 32`    |
| Rankine    | `x * 5/9`                    | `x * 9/5`                    |
| Réaumur    | `x * 5/4 + 273.15`           | `(x - 273.15) * 4/5`         |
| Delisle    | `373.15 - x * 2/3`           | `(373.15 - x) * 3/2`         |
| Rømer      | `(x - 7.5) * 40/21 + 273.15` | `(x - 273.15) * 21/40 + 7.5` |

---

## Writing Descriptions

The `description` field uses **raw Dart string literals** (`r"""..."""`) with **Markdown** and **LaTeX** math.

### Format

```dart
"description": r"""
Short description of the formula.

$$F = m \cdot a$$

Where:
- $F$: Force (Newtons)
- $m$: Mass (kilograms)
- $a$: Acceleration (m/s²)

Additional context or notes.""",
```

### LaTeX Math

Use **MathJax/KaTeX** syntax for mathematical expressions:

| Type                | Syntax                      | Example                  |
|---------------------|-----------------------------|--------------------------|
| Inline math         | `$...$`                     | `$F = ma$`               |
| Display math        | `$$...$$`                   | `$$E = mc^2$$`           |
| Fractions           | `\frac{a}{b}`               | `$$\frac{1}{2}mv^2$$`    |
| Subscripts          | `x_i`                       | `$v_0$`                  |
| Superscripts        | `x^2`                       | `$a^2 + b^2$`            |
| Greek letters       | `\alpha`, `\beta`, `\theta` | `$$\sin(\theta)$$`       |
| Special symbols     | `\cdot`, `\times`, `\pm`    | `$m \cdot a$`            |
| Units in math       | `\mathrm{m/s^2}`            | `$9.81\ \mathrm{m/s^2}$` |
| Scientific notation | `\times 10^{-11}`           | `$6.674\times 10^{-11}$` |

### Including Images

Add Wikipedia or other educational images using Markdown:

```markdown
![Description](https://upload.wikimedia.org/wikipedia/commons/...)
```

**Example:**
```dart
"description": r"""
Newton's law of universal gravitation.

$$F = G\frac{m_1m_2}{r^2}$$

![Gravitation Diagram](https://upload.wikimedia.org/wikipedia/commons/thumb/3/33/NewtonsLawOfUniversalGravitation.svg/1200px-NewtonsLawOfUniversalGravitation.svg.png)""",
```

### Description Structure

A well-structured description includes:

1. **Opening sentence** - Brief statement of what the formula calculates
2. **LaTeX formula** - The mathematical expression in display mode
3. **Variable definitions** - List of all variables with units
4. **Additional context** - Notes, assumptions, or applications
5. **Image** (optional) - Diagram or illustration

---

## Best Practices

### For Formulas

1. **Use clear variable names** - Single letters for physics conventions (`F`, `m`, `a`), descriptive names when clarity matters
2. **Match units precisely** - Ensure input/output units match what the formula expects
3. **Add validation** - Use `signal()` for invalid inputs (e.g., triangle inequality)
4. **Include tags** - Add relevant tags for discoverability
5. **Use LaTeX for all math** - Even simple formulas should have LaTeX representation
6. **Add images** - Include diagrams from Wikipedia when helpful
7. **Comment your code** - Use `//` comments before each formula object

### For Units

1. **Use lowercase names** - `"meter"` not `"Meter"`
2. **Include common conversions** - Add both metric and imperial units when relevant
3. **Use standard symbols** - Follow SI conventions where applicable
4. **Document the factor** - Ensure conversion factors are accurate

### For Descriptions

1. **Be concise but complete** - Explain what the formula does and what each variable means
2. **Use consistent formatting** - Follow the established pattern in existing files
3. **Include units in variable definitions** - Always specify units for each variable
4. **Add context** - Explain when/why the formula is used
5. **Note assumptions** - Mention any constraints or special conditions

---

## Examples

### Complete Formula Example

```dart
// Newton's Second Law
{
  "name": "Newton's Second Law",
  "description": r"""
Force equals mass times acceleration.

$$F = m \cdot a$$

Where:
- $m$: Mass of object ($\mathrm{kg}$)
- $a$: Acceleration ($\mathrm{m/s^2}$)

![Newton's Second Law](https://upload.wikimedia.org/wikipedia/commons/thumb/7/73/Newtonslawsofmotion.jpg/800px-Newtonslawsofmotion.jpg)""",
  "input": [
    {"name": "m", "unit": "kilogram"},
    {"name": "a", "unit": "meters per square second"}
  ],
  "output": {"name": "F", "unit": "newton"},
  "d4rtCode": "F = m * a;",
  "tags": ["physics", "mechanics", "newton"]
}
```

### Complete Unit Example

```dart
[
  {
    "name": "newton",
    "symbol": "N",
    "isBase": true
  },
  {
    "name": "kilonewton",
    "symbol": "kN",
    "baseUnit": "newton",
    "factor": 1000
  },
  {
    "name": "pound-force",
    "symbol": "lbf",
    "baseUnit": "newton",
    "factor": 4.44822
  }
]
```

### Multi-line Dart Code Example

```dart
// Cosine Rule
{
  "name": "Cosine Rule",
  "description": r"""
Generalization of the Pythagorean theorem for any triangle.

$$c^2 = a^2 + b^2 - 2ab\cos(C)$$

Where:
- $a$, $b$, $c$: Sides of the triangle
- $C$: Angle opposite to side $c$""",
  "input": [
    {"name": "a", "unit": "meter"},
    {"name": "b", "unit": "meter"},
    {"name": "C", "unit": "degree"}
  ],
  "output": {"name": "c", "unit": "meter"},
  "d4rtCode": """
     var angleCRad = C * (pi / 180);
     c = sqrt(pow(a, 2) + pow(b, 2) - 2*a*b*cos(angleCRad));
  """,
  "tags": ["trigonometry", "triangle", "cosine"]
}
```

---

## File Organization

### Formula Categories

| File                             | Topic                          |
|----------------------------------|--------------------------------|
| `formulas.d4rt`                  | General physics formulas       |
| `geometry.d4rt`                  | Geometric calculations         |
| `electromagnetism.d4rt`          | Electric and magnetic formulas |
| `energy_and_power.d4rt`          | Energy, work, and power        |
| `thermodynamics.d4rt`            | Heat and thermodynamics        |
| `fluids_and_pressure.d4rt`       | Fluid mechanics                |
| `optics.d4rt`                    | Light and optics               |
| `trigonometry.d4rt`              | Trigonometric relations        |
| `materials_elasticity.d4rt`      | Material properties            |
| `medical_and_bio.d4rt`           | Medical/biological formulas    |
| `networking.d4rt`                | Network calculations           |
| `conversions_and_constants.d4rt` | Physical constants             |
| `misc_math.d4rt`                 | Miscellaneous mathematics      |

### Unit Categories

| File                     | Unit Type              |
|--------------------------|------------------------|
| `distance.d4rt.units`    | Length/distance        |
| `mass.d4rt.units`        | Mass                   |
| `time.d4rt.units`        | Time                   |
| `force.d4rt.units`       | Force                  |
| `energy.d4rt.units`      | Energy                 |
| `power.d4rt.units`       | Power                  |
| `pressure.d4rt.units`    | Pressure               |
| `velocity.d4rt.units`    | Speed/velocity         |
| `area.d4rt.units`        | Area                   |
| `volume.d4rt.units`      | Volume                 |
| `temperature.d4rt.units` | Temperature            |
| `angle.d4rt.units`       | Angles                 |
| `frequency.d4rt.units`   | Frequency              |
| `electricity.d4rt.units` | Electrical units       |
| `derived.d4rt.units`     | Derived/compound units |

---

## Quick Reference

### Common LaTeX Symbols

| Symbol | LaTeX     | Symbol | LaTeX    |
|--------|-----------|--------|----------|
| ×      | `\times`  | ·      | `\cdot`  |
| ±      | `\pm`     | ÷      | `\div`   |
| ≤      | `\leq`    | ≥      | `\geq`   |
| √      | `\sqrt{}` | ∞      | `\infty` |
| π      | `\pi`     | θ      | `\theta` |
| α      | `\alpha`  | β      | `\beta`  |
| Δ      | `\Delta`  | δ      | `\delta` |
| Σ      | `\Sigma`  | σ      | `\sigma` |
| Ω      | `\Omega`  | ω      | `\omega` |

### Common Dart Math Functions

| Function                        | Description                       |
|---------------------------------|-----------------------------------|
| `sin(x)`, `cos(x)`, `tan(x)`    | Trigonometric functions (radians) |
| `asin(x)`, `acos(x)`, `atan(x)` | Inverse trig functions            |
| `sqrt(x)`                       | Square root                       |
| `pow(x, y)`                     | x raised to power y               |
| `log(x)`                        | Natural logarithm                 |
| `log10(x)`                      | Base-10 logarithm                 |
| `abs(x)`                        | Absolute value                    |
| `exp(x)`                        | e raised to power x               |
| `pi`                            | π constant                        |

---

## Contributing

1. **Choose the right file** - Add formulas to the appropriate category file
2. **Follow the format** - Match the structure of existing entries
3. **Test your code** - Ensure `d4rtCode` is valid Dart syntax
4. **Add description** - Include complete LaTeX documentation
5. **Tag appropriately** - Add relevant tags for searchability
6. **Review** - Check existing formulas for consistency

For questions or clarifications, refer to existing formulas in the `assets/formulas/` directory as examples.
