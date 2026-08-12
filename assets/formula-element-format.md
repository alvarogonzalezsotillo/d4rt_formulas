# Formula and Unit File Format Guide

This document describes the format for contributing formulas and units to the d4rt_formulas project. It is intended for formula contributors and developers.

---

## Table of Contents

1. [Overview](#overview)
2. [File Types and Naming](#file-types-and-naming)
3. [Formula Files](#formula-files)
4. [Variable Objects](#variable-objects)
5. [The `d4rtCode` Field](#the-d4rtcode-field)
6. [Unit Files](#unit-files)
7. [Descriptions](#descriptions)
8. [Loading and Dependencies](#loading-and-dependencies)
9. [Formatting Conventions](#formatting-conventions)
10. [Examples](#examples)
11. [Best Practices](#best-practices)

---

## Overview

The project stores its corpus as **Dart array literals** (JSON-like, but with Dart
syntax) in text assets. Each element of the array is either a *formula* or a *unit*
object, represented as a map literal.

The files are parsed at runtime with the d4rt interpreter, so any construct that is
valid in a Dart map/list literal is valid here, including `//` comments, raw strings
(`r"""..."""`) and unquoted keys. Every field value is a Dart literal: strings are
double-quoted (or raw strings when they contain newlines, `$`, backslashes or quotes),
numbers are plain numerals, booleans are `true`/`false`, and collections are `[...]`.

## File Types and Naming

| File type  | Location            | Extension       | Contents                        |
|------------|---------------------|-----------------|---------------------------------|
| Formulas   | `assets/formulas/`  | `.d4rt.formulas`| Array of formula objects        |
| Units      | `assets/units/`     | `.d4rt.units`   | Array of unit objects           |
| Shared/imported | anywhere     | `.d4rtf`        | Array of formulas and/or units  |

`.d4rtf` files and shared text use the **same literal format** as the assets. They are
parsed with `SetUtils.parseCorpusElements()` / `ImportService`, which decides for each
element whether it is a formula (it contains a `d4rtCode` key) or a unit (it contains
`name` and `symbol` keys). They are added to the in-memory corpus and stored in the
database when imported.

All files under `assets/formulas/` and `assets/units/` are loaded automatically when
the default corpus is created (see [Loading and Dependencies](#loading-and-dependencies)).

## Formula Files

A formula file is an array of formula objects. Each formula object has the following
fields:

| Field         | Type      | Required | Description                                                                |
|---------------|-----------|----------|----------------------------------------------------------------------------|
| `name`        | String    | Yes      | Human readable formula name. It must not be empty.                         |
| `description` | String    | No       | Markdown description with LaTeX math (see [Descriptions](#descriptions)).  |
| `input`       | Array     | Yes      | List of input [variable objects](#variable-objects).                       |
| `output`      | Object    | Yes      | The output [variable object](#variable-objects).                           |
| `d4rtCode`    | String    | Yes      | Dart code that computes the output (see [d4rtCode](#the-d4rtcode-field)).  |
| `tags`        | Array     | No       | List of `String` tags used for search/filtering.                           |
| `uuid`        | String    | No       | Optional unique identifier. A UUID v4 is generated if omitted.             |

Example:

```dart
{
  "name": "Newton's Second Law",
  "description": r"""
Force equals mass times acceleration

$$F = m \cdot a$$
""",
  "input": [
    {"name": "m", "unit": "kilogram"},
    {"name": "a", "unit": "meters per square second"}
  ],
  "output": {"name": "F", "unit": "newton"},
  "d4rtCode": "F = m * a;",
  "tags": ["physics", "mechanics", "newton"]
}
```

### The `uuid` field

Formulas (and units) are identified by an internal UUID, **not** by their name. Names
are not unique: two formulas may share a name as long as their UUIDs differ. When a
`uuid` key is present it is honored; otherwise a random UUID v4 is generated at load
time. The UUID is what the database and the corpus use to look up an element.

## Variable Objects

Variables describe the inputs and the output of a formula. They share the same shape:

| Field    | Type   | Required | Description                                                                                  |
|----------|--------|----------|----------------------------------------------------------------------------------------------|
| `name`   | String | Yes      | Variable name used in `d4rtCode`. It must not be a reserved name (see below).                |
| `unit`   | String | No       | Name of a unit that exists in the corpus, or the special units `scalar` / `string`.          |
| `values` | Array  | No       | Allowed values for the variable: all `String` or all `Number` literals.                      |

At least one of `unit` or `values` must be present.

```dart
{"name": "mass", "unit": "kilogram"}              // a numeric input with a unit
{"name": "conversion", "values": ["A", "B", "C"]} // a string input with allowed values
{"name": "result", "unit": "string"}              // a string output
{"name": "ratio", "unit": "scalar"}               // a unitless number
```

### Allowed values (`values`)

- The values must be **all strings or all numbers**; mixing types is rejected.
- When present, the value the user enters is validated against this list before the
  formula runs.
- Inside `d4rtCode`, `indexOf("VarName")` returns the zero-based index of the current
  value of `VarName` within its allowed-values list. This is the idiomatic way to turn
  a categorical choice into a number (see the Apgar Score example below).

### Reserved variable names

The following names are reserved by the evaluator and cannot be used as variable
names: `variableValues`, `indexOf`, `variableAllowedValues`.

### The special units `scalar` and `string`

- `scalar` is the base unit for unitless quantities.
- `string` is the base unit for text values. Formulas with string inputs/outputs are
  **not** derivable (the solver cannot solve for a string variable).

## The `d4rtCode` Field

`d4rtCode` is plain Dart code executed by the d4rt interpreter. The generated harness
is roughly:

```dart
final inputVar1 = <value>;   // one final per input variable
final inputVar2 = <value>;
// ...
late var <outputName>;
<d4rtCode>
return <outputName>;
```

Rules and available helpers:

- **Input variables** are available by their name, already converted to their *base
  unit* (or the raw string/number for `string`/`scalar` variables).
- **The output variable** must be assigned by the code; it is declared as `late var`
  just before your code runs, so assigning it anywhere in the code is enough.
- The code must be a valid statement list (semicolons included). Expressions can be
  wrapped as `Output = expr;`.
- `signal("message")` aborts evaluation and surfaces `message` as a user-facing error.
  Use it for input validation:

  ```dart
  if (a + b <= c) {
    signal('Invalid triangle: sides do not satisfy the triangle inequality');
  }
  ```

- `indexOf("VarName")` returns the index of the current value of a variable within its
  `values` list (see [Variable Objects](#variable-objects)).
- `fn("Other Formula Name", {"input1": v1, ...})` evaluates another formula from the
  corpus and returns its output. The formula must exist in the loaded corpus.
- `dart:math` is imported: `sin`, `cos`, `tan`, `asin`, `acos`, `atan`, `sqrt`, `pow`,
  `log`, `log10`, `exp`, `abs`, `pi`, `e`, `min`, `max`, ... plus `DateTime`,
  `int.tryParse`, string methods, `List` operations, etc. are all available.
- The generated harness also defines `variableValues` (a map of the current input
  values) and `variableAllowedValues` (a map of variable name to its `values` list).

```dart
"d4rtCode": "F = m * a;"

"d4rtCode": """
  var angleRad = angle * (pi / 180);
  result = sin(angleRad);
"""

"d4rtCode": r"""
  var total = indexOf("HeartRate") + indexOf("Breathing") +
              indexOf("MuscleTone") + indexOf("Reflexes") +
              indexOf("SkinColor");
  if (total < 4) {
    Result = 'Critical condition';
  } else if (total < 7) {
    Result = 'Needs assistance';
  } else {
    Result = 'Normal';
  }
"""
```

### Units and evaluation

When a formula is evaluated through the UI, each input value is converted from the
unit selected by the user to the **base unit** of that variable's unit before `d4rtCode`
runs, and the numeric result is converted back to the chosen output unit for display.
Write your `d4rtCode` assuming input values are in base units and that the result you
assign to the output variable is in the output variable's base unit.

## Unit Files

A unit file is an array of unit objects. Units define measurement categories and how
each unit converts to its base unit.

| Field      | Type    | Required    | Description                                                              |
|------------|---------|-------------|--------------------------------------------------------------------------|
| `name`     | String  | Yes         | Full unit name (lowercase by convention).                                |
| `symbol`   | String  | Yes         | Symbol shown in the UI.                                                  |
| `isBase`   | Boolean | Conditional | `true` for a base unit (no conversion needed).                           |
| `baseUnit` | String  | Conditional | Name of the base unit this unit converts to.                             |
| `factor`   | Number  | Conditional | Multiplication factor from this unit to the base unit.                   |
| `toBase`   | String  | Conditional | Code that converts a value `x` in this unit to the base unit.            |
| `fromBase` | String  | Conditional | Code that converts a value `x` in the base unit back to this unit.       |
| `uuid`     | String  | No         | Optional unique identifier; a UUID v4 is generated if omitted.           |

### Base units

A base unit anchors a category. It sets `isBase: true` and must **not** define
`baseUnit`, `factor`, `toBase` or `fromBase`.

```dart
{"name": "meter", "symbol": "m", "isBase": true}
{"name": "Kelvin", "symbol": "K", "isBase": true}
```

### Derived units

A derived unit must specify its `baseUnit` and exactly one conversion mechanism:

**Simple linear conversion (`factor`)** — the value multiplied by `factor` gives the
value in the base unit:

```dart
{"name": "kilometer", "symbol": "km", "baseUnit": "meter", "factor": 1000}
{"name": "inch", "symbol": "in", "baseUnit": "meter", "factor": 0.0254}
```

**Code conversion (`toBase`/`fromBase`)** — for non-linear conversions such as
temperature scales. Both are Dart code where `x` is the value to convert. `toBase`
converts this unit to the base unit; `fromBase` converts back. They may be simple
expressions or multi-line code with statements (including `return`).

```dart
{
  "name": "Celsius",
  "symbol": "°C",
  "baseUnit": "Kelvin",
  "toBase": "x + 273.15",
  "fromBase": "x - 273.15",
}

{
  "name": "Fahrenheit",
  "symbol": "°F",
  "baseUnit": "Kelvin",
  "toBase": "(x - 32) * 5/9 + 273.15",
  "fromBase": "(x - 273.15) * 9/5 + 32",
}
```

Multi-line conversion code is stored as a raw string (or a normal multiline string)
and is evaluated either as an expression or as a statement that mutates `x`; both
forms are supported:

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

### Special units

The file `assets/units/scalar.d4rt.units` defines the two special base units used by
formulas:

```dart
{"name": "scalar", "symbol": "㊷", "isBase": true}
{"name": "string", "symbol": "🔤", "isBase": true}
```

They are referenced from variable objects as `"unit": "scalar"` and
`"unit": "string"`.

## Descriptions

The `description` field is optional and rendered with Markdown (via
flutter-markdown-plus), including LaTeX math and images. It should be written as a
**raw Dart string** (`r"""..."""`) so that backslashes, `$` and newlines survive
verbatim.

```dart
"description": r"""
Calculates horizontal distance of projectile motion

$$R = \frac{v^2 \sin(2\theta)}{g}$$

Where:
- $v$: Initial velocity
- $\theta$: Launch angle

![Projectile Motion](https://upload.wikimedia.org/wikipedia/commons/thumb/5/52/Projectile_motion_diagram.png/800px-Projectile_motion_diagram.png)""",
```

- Inline math uses `$...$`, display math uses `$$...$$`.
- Fractions: `\frac{a}{b}`; sub/superscripts: `x_i`, `x^2`; Greek letters:
  `\alpha`, `\theta`; units in math: `\mathrm{m/s^2}`.
- Images use standard Markdown `![alt](url)` and may point to Wikipedia.
- A good description has an opening sentence, the LaTeX formula, a variable
  definition list and (optionally) notes/images.

## Loading and Dependencies

- When the default corpus is built, **all** files matching `assets/units/*.d4rt.units`
  are loaded first, then **all** files matching `assets/formulas/*.d4rt.formulas`
  (order handled by `Corpus.loadFormulaElements()`).
- **Units must be loaded before formulas** so that every unit referenced by a formula
  exists. A formula whose input/output references a unit that is not loaded raises an
  `ArgumentError` (`Unit not found`).
- Unit names are unique within the corpus; loading a duplicate unit raises an error
  unless duplicates are allowed to replace existing entries.
- Formula UUIDs are unique; sharing a UUID with an existing formula replaces it.

## Formatting Conventions

Assets are pretty printed as Dart literals and should follow the existing conventions
so the files stay diff-friendly and tooling-friendly:

- One formula/unit object per entry, separated by a blank line; a `//` comment may
  precede each formula.
- Key order in formula objects: `name`, `description`, `input`, `output`, `d4rtCode`,
  `tags` (optionally `uuid` first). Key order in unit objects: `name`, `symbol`, then
  the conversion keys.
- Single-line objects when they fit; multi-line objects otherwise, indented with two
  spaces per level.
- Descriptions and multi-line `d4rtCode` use raw strings `r"""..."""`.
- `d4rtCode` is written as a statement list that assigns the output variable; the
  output variable must be assigned on every path.

Every asset file ends with a file-local variables block that enables `dart-mode` and
the imenu indexer in Emacs:

```dart
// Local Variables:
// mode: dart
// d4rt-formulas-imenu-mode: t
// End:
```

## Examples

### Complete formula (numeric)

```dart
// Gravitational Potential Energy
{
  "name": "Gravitational Potential Energy",
  "description": r"""
Energy possessed by an object due to its position in a gravitational field

$$PE = mgh$$

Where:
- $m$: Mass of object (kilograms)
- $g$: Gravitational acceleration ($9.81\ \mathrm{m/s^2}$ on Earth)
- $h$: Height above reference point (meters)
""",
  "input": [
    {"name": "m", "unit": "kilogram"},
    {"name": "h", "unit": "meter"},
    {"name": "g", "unit": "meters per square second"}
  ],
  "output": {"name": "PE", "unit": "joule"},
  "d4rtCode": "PE = m * g * h;",
  "tags": ["physics", "energy", "mechanics", "gravity"]
}
```

### Complete formula (categorical input with allowed values)

```dart
{
  "name": "Apgar Score",
  "input": [
    {"name": "HeartRate", "values": ["Absent", "< 100 bpm", "> 100 bpm"]},
    {"name": "Breathing", "values": ["Absent", "Weak, irregular", "Strong, robust cry"]},
    {"name": "MuscleTone", "values": ["None", "Some", "Flexed arms/leg, resists extension"]},
    {"name": "Reflexes", "values": ["No response", "Grimace on aggressive stimulation", "Cry on stimulation"]},
    {"name": "SkinColor", "values": ["Blue or pale", "Blue extremities, pink body", "Pink"]}
  ],
  "output": {"name": "Result", "unit": "string"},
  "d4rtCode": r"""
    var total = indexOf("HeartRate") + indexOf("Breathing") +
                indexOf("MuscleTone") + indexOf("Reflexes") +
                indexOf("SkinColor");
    late var interpretation;
    if (total < 4) {
      interpretation = 'Critical condition';
    } else if (total < 7) {
      interpretation = 'Needs assistance';
    } else {
      interpretation = 'Normal';
    }
    Result = 'Score: $total - $interpretation';
  """,
  "tags": ["medical", "pediatrics", "assessment"]
}
```

### Complete formula (string input with validation)

```dart
{
  "name": "Network Address from Host IP",
  "input": [
    {"name": "hostIP", "unit": "string"}
  ],
  "output": {"name": "network", "unit": "string"},
  "d4rtCode": r"""
    var parts = hostIP.split('/');
    if (parts.length != 2) {
      signal('Invalid input format. Expected format: IP/MASK');
    }
    var mask = int.tryParse(parts[1]);
    if (mask == null || mask < 0 || mask > 32) {
      signal('Invalid subnet mask. Must be an integer between 0 and 32.');
    }
    var octets = parts[0].split('.').map((e) => int.tryParse(e)).toList();
    if (octets.length != 4) {
      signal('Invalid IP address format. Expected 4 octets separated by dots.');
    }
    var networkValue = 0;
    for (var i = 0; i < 4; i++) {
      if (octets[i] == null || octets[i] < 0 || octets[i] > 255) {
        signal('Invalid IP address. Each octet must be between 0 and 255.');
      }
      networkValue = (networkValue << 8) | octets[i];
    }
    networkValue = (networkValue >> (32 - mask)) << (32 - mask);
    var networkOctets = [];
    for (var i = 0; i < 4; i++) {
      networkOctets.insert(0, networkValue & 0xFF);
      networkValue = networkValue >> 8;
    }
    network = networkOctets.join('.') + '/' + mask.toString();
  """,
  "tags": ["networking", "ip", "subnetting", "cidr", "network"]
}
```

### Complete unit file

```dart
[
  {"name": "meter", "symbol": "m", "isBase": true},
  {"name": "centimeter", "symbol": "cm", "baseUnit": "meter", "factor": 0.01},
  {"name": "foot", "symbol": "ft", "baseUnit": "meter", "factor": 0.3048},
  {"name": "inch", "symbol": "in", "baseUnit": "meter", "factor": 0.0254},
  {"name": "kilometer", "symbol": "km", "baseUnit": "meter", "factor": 1000},
  {
    "name": "light-year",
    "symbol": "ly",
    "baseUnit": "meter",
    "factor": 9.461e15,
  }
]
```

## Best Practices

- **Choose the right file**: add formulas to the topic file that already covers the
  subject (`assets/formulas/*.d4rt.formulas`), units to the matching category file
  (`assets/units/*.d4rt.units`). Create a new file if no existing topic fits.
- **Reuse units**: prefer referencing existing unit names over inventing new ones.
  Add a unit to its category only if it is genuinely missing.
- **Write `d4rtCode` in base units** and validate inputs with `signal(...)`.
- **Use `values` + `indexOf(...)`** for categorical inputs instead of parsing strings
  by hand.
- **Always include a `description`** with the LaTeX formula, even though it is
  optional, and add a Wikipedia image when helpful.
- **Tag generously**: formulas are searchable by tag (`Corpus.getTagFormulas`).
- **Keep the key order and pretty printing** conventions described above.
- **Test the file**: after editing, run the test suite and the app; formulas are
  validated at load time (unknown units, empty names, reserved variable names and
  invalid `values` lists are rejected with an error).

For questions or clarifications, look at the existing files in `assets/formulas/` and
`assets/units/` as examples.
