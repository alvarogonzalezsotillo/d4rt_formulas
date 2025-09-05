import 'package:flutter/material.dart';

import '../formula_models.dart';


class FormulaWidget extends StatelessWidget {
  final Formula formula;
  final double fontSize;
  final Color? textColor;
  final Color? backgroundColor;
  final EdgeInsets padding;
  final bool showMagnitudes;
  final bool showCode;

  const FormulaWidget({
    super.key,
    required this.formula,
    this.fontSize = 16.0,
    this.textColor,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(16.0),
    this.showMagnitudes = true,
    this.showCode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor,
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Formula name
            Text(
              formula.name,
              style: TextStyle(
                fontSize: fontSize * 1.2,
                fontWeight: FontWeight.bold,
                color: textColor ?? Theme.of(context).textTheme.headlineSmall?.color,
              ),
            ),
            const SizedBox(height: 12),

            // Formula equation
            _buildFormulaEquation(context),

            if (showMagnitudes) ...[
              const SizedBox(height: 16),
              _buildMagnitudesSection(context),
            ],

            if (showCode) ...[
              const SizedBox(height: 16),
              _buildCodeSection(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFormulaEquation(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Output variable
          _buildVariableChip(formula.output, isOutput: true, context: context),

          const SizedBox(width: 12),

          // Equals sign
          Text(
            '=',
            style: TextStyle(
              fontSize: fontSize * 1.5,
              fontWeight: FontWeight.bold,
              color: textColor ?? Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),

          const SizedBox(width: 12),

          // Function notation
          Text(
            '${formula.name}(',
            style: TextStyle(
              fontSize: fontSize,
              fontStyle: FontStyle.italic,
              color: textColor ?? Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),

          // Input variables
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (int i = 0; i < formula.input.length; i++) ...[
                  _buildVariableChip(formula.input[i], context: context),
                  if (i < formula.input.length - 1)
                    Text(
                      ',',
                      style: TextStyle(
                        fontSize: fontSize,
                        color: textColor ?? Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                ],
              ],
            ),
          ),

          Text(
            ')',
            style: TextStyle(
              fontSize: fontSize,
              fontStyle: FontStyle.italic,
              color: textColor ?? Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVariableChip(VariableSpec variable, {bool isOutput = false, required BuildContext context}) {
    final bool hasMagnitude = variable.magnitude != VariableSpec.MAGNITUDELESS;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isOutput
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : Theme.of(context).colorScheme.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isOutput
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.secondary,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            variable.name,
            style: TextStyle(
              fontSize: fontSize * 0.9,
              fontWeight: FontWeight.w600,
              color: isOutput
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.secondary,
            ),
          ),
          if (hasMagnitude && showMagnitudes) ...[
            const SizedBox(width: 4),
            Text(
              '[${variable.magnitude}]',
              style: TextStyle(
                fontSize: fontSize * 0.8,
                fontStyle: FontStyle.italic,
                color: (isOutput
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.secondary).withOpacity(0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMagnitudesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Variables:',
          style: TextStyle(
            fontSize: fontSize * 0.9,
            fontWeight: FontWeight.w600,
            color: textColor ?? Theme.of(context).textTheme.titleSmall?.color,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: [
            ...formula.input.map((variable) => _buildVariableInfo(variable, context)),
            _buildVariableInfo(formula.output, context, isOutput: true),
          ],
        ),
      ],
    );
  }

  Widget _buildVariableInfo(VariableSpec variable, BuildContext context, {bool isOutput = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isOutput ? Icons.arrow_forward : Icons.input,
          size: fontSize * 0.8,
          color: isOutput
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.secondary,
        ),
        const SizedBox(width: 4),
        Text(
          '${variable.name}: ',
          style: TextStyle(
            fontSize: fontSize * 0.85,
            fontWeight: FontWeight.w500,
            color: textColor ?? Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        Text(
          variable.magnitude == VariableSpec.MAGNITUDELESS ? 'dimensionless' : variable.magnitude,
          style: TextStyle(
            fontSize: fontSize * 0.85,
            fontStyle: FontStyle.italic,
            color: (textColor ?? Theme.of(context).textTheme.bodyMedium?.color)?.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildCodeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Implementation:',
          style: TextStyle(
            fontSize: fontSize * 0.9,
            fontWeight: FontWeight.w600,
            color: textColor ?? Theme.of(context).textTheme.titleSmall?.color,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            formula.d4rtCode,
            style: TextStyle(
              fontSize: fontSize * 0.8,
              fontFamily: 'monospace',
              color: textColor ?? Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ),
      ],
    );
  }
}

// Example usage and demo
class FormulaDisplayDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Create sample formulas
    final sampleFormulas = [
      Formula(
        name: 'calculateArea',
        input: [
          VariableSpec(name: 'length', magnitude: 'meters'),
          VariableSpec(name: 'width', magnitude: 'meters'),
        ],
        output: VariableSpec(name: 'area', magnitude: 'square_meters'),
        d4rtCode: 'return length * width;',
      ),
      Formula(
        name: 'pythagoras',
        input: [
          VariableSpec(name: 'a', magnitude: 'meters'),
          VariableSpec(name: 'b', magnitude: 'meters'),
        ],
        output: VariableSpec(name: 'c', magnitude: 'meters'),
        d4rtCode: 'return sqrt(a * a + b * b);',
      ),
      Formula(
        name: 'normalize',
        input: [
          VariableSpec(name: 'value', magnitude: VariableSpec.MAGNITUDELESS),
          VariableSpec(name: 'max', magnitude: VariableSpec.MAGNITUDELESS),
        ],
        output: VariableSpec(name: 'normalized', magnitude: VariableSpec.MAGNITUDELESS),
        d4rtCode: 'return value / max;',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Formula Display Demo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            for (final formula in sampleFormulas) ...[
              FormulaWidget(
                formula: formula,
                showCode: true,
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}