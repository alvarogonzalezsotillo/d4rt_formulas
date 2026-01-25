https://github.com/Shahxad-Akram/flutter_tex/blob/master/example/lib/tex_view_markdown_example.dart

# Math Formulae Manager

A comprehensive command-line application for managing and computing mathematical formulas across various disciplines including mathematics, physics, medicine, and engineering.

This project uses dart language, and flutter framework. It leverages d4rt library to execute formulas.


# Development guidelines
If you are a contributor or an agent, please follow [CLAUDE.md](./CLAUDE.md) for development guidelines.

# Formula file description

The file is a dart array of formulas. Each formula is a dart set literal

```dart
[
    {
        "name": "Newton's second law (scalar)",
        "input": {
            "m" : {
               "magnitude": "mass"
            },
            "a" : {
               "magnitude": "acceleration"
            }
        },
        "output": {
            "F" : {
                "magnitude" : "Force"
            }
        },
        "d4rt_code": "F = m*a;"
        
    },
    {
        "name": 'Triangle rectangle',
        "input": [
          'b':{ "magnitude": 'meter'},
          'c':{ "magnitude": 'meter'},
        ],
        "output": { 'a': { "magnitude": 'meter' } },
        "d4rtCode": '''
              a = Math.sqrt(b*b + c*c);
          ''',
    }
]
```

# Unit file description

```dart
[
  {
    "name": 'meter',
    "symbol": 'm',
    "isBase": true
  },
  {
    "name": 'inch',
    "symbol" 'in',
    "baseUnit": 'meter',
    "factor": 0.0254
  },
  {
    "name": 'nautical mile',
    "symbol": 'Nm',
    "baseUnit": 'meter',
    "factor": 1852
  },
  {
    "name": 'Kelvin',
    "symbol": "Kº",
    "isBase": true,
  },
  {
    "name": 'Celsius',
    "symbol": "Cº",
    "baseUnit" : "Kelvin",
    "toBase": "x + 273.15",
    "fromBase": "x - 273.15"
  },
  {
    "name": 'Fahrenheit',
    "symbol": "Fº",
    "baseUnit" : "Kelvin",
    "toBase": "(x - 32) × 5/9 + 273.15",
    "fromBase": "x - 273.15) * 9/5 + 32"
  }
]
```

## Features

### Formula Search and Computation
- Search through a vast collection of formulas from multiple domains:
  - Mathematics
  - Physics
  - Medical sciences
  - Engineering
  - And more!
- Input values for formula variables
- Get computed results with proper units

### Unit Management
- Each data value includes its magnitude and unit
- Convert between different units seamlessly
- Automatic unit validation and conversion

### Formula Editor
- Built-in formula editor using the d4rt interpreter
- Create and modify formulas with ease
- Syntax highlighting and validation

### Formula Sharing
- Share formulas with other users
- Import formulas from the community
- Collaborative formula database

### Rich Formula Documentation
Each formula includes:
- **The formula itself** - Mathematical expression
- **Explanation** - Detailed description in Markdown format
- **Images** - Visual diagrams, graphs, or illustrations
- **Examples** - Sample calculations and use cases

## Getting Started

This project uses `flutter`, so a valid installation is needed in order to build it.

For convenience, a containerized build is provided. It is based on `podman` and `podman-compose`. See [Makefile](Makefile) for details.

## Contributing

[Contribution guidelines to be added]
