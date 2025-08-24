# Math Formulae Manager

A comprehensive command-line application for managing and computing mathematical formulas across various disciplines including mathematics, physics, medicine, and engineering.

This project uses dart language, and flutter framework. It leverages d4rt library to execute formulas.


# Development guidelines
If you are a contributor or an agent, please follow [CLAUDE.md](./CLAUDE.md) for development guidelines.

# Formula file description

The file is a json array of formulas.

```json
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
        "d4rt_code": "return m*a;"
        
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

## Project Structure

- `bin/` - Main executable and entry point
- `lib/` - Core library code and formula engine
- `test/` - Unit tests and formula validation tests

## Getting Started

[Installation and usage instructions to be added]

## Contributing

[Contribution guidelines to be added]
