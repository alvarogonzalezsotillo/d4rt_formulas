
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../formula_models.dart';
import '../formula_evaluator.dart';
import '../corpus.dart';
import 'unit_dropdown.dart';

class FormulaScreen extends StatefulWidget {
  final Formula formula;
  final Corpus corpus;

  const FormulaScreen({
    super.key,
    required this.formula,
    required this.corpus,
  });

  @override
  State<FormulaScreen> createState() => _FormulaScreenState();
}

class _FormulaScreenState extends State<FormulaScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _inputControllers = {};
  final Map<String, String?> _selectedUnits = {};
  String? _result;
  String? _selectedOutputUnit;

  @override
  void initState() {
    super.initState();
    // Initialize controllers and units with listeners
    for (final input in widget.formula.input) {
      _inputControllers[input.name] = TextEditingController();
      _selectedUnits[input.name] = input.unit;
      _inputControllers[input.name]!.addListener(_evaluateFormula);
    }
    _selectedOutputUnit = widget.formula.output.unit;
  }

  @override
  void dispose() {
    // Clean up controllers and listeners
    for (final controller in _inputControllers.values) {
      controller.removeListener(_evaluateFormula);
      controller.dispose();
    }
    super.dispose();
  }

  void _evaluateFormula() {
    if (!_formKey.currentState!.validate()) return;

    try {
      final inputValues = <String, dynamic>{};
      for (final input in widget.formula.input) {
        final text = _inputControllers[input.name]!.text;
        //final value = double.tryParse(text) ?? 0.0;
        final value = FormulaEvaluator.evaluateExpression(text);

        // Convert input to base unit if needed
        // Always convert from dropdown unit to variable's base unit
        inputValues[input.name] = widget.corpus.convert(
          value,
          _selectedUnits[input.name]!,
          input.unit,
        );
      }

      final evaluator = FormulaEvaluator();
      final result = evaluator.evaluate(widget.formula, inputValues);

      // Convert output to selected unit if needed
      if (_selectedOutputUnit != widget.formula.output.unit) {
        _result = widget.corpus.convert(
          result,
          widget.formula.output.unit,
          _selectedOutputUnit!,
        ).toStringAsFixed(2);
      } else {
        _result = result.toStringAsFixed(2);
      }

      setState(() {});
    } catch (e, stack) {
      debugPrint('Formula evaluation error: $e');
      debugPrint('Stack trace: $stack');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}\n${stack.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.formula.name),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              _buildDescriptionSection(),
              _buildInputSection(),
              const SizedBox(height: 24),
              _buildOutputSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionSection() {
    if (widget.formula.description == null || 
        widget.formula.description!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
          child: MarkdownBody(
            data: widget.formula.description!,
            shrinkWrap: true,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Input Variables',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...widget.formula.input.map((variable) => _buildVariableRow(variable)),
      ],
    );
  }

  Widget _buildOutputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Result',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(widget.formula.output.name),
            const Spacer(),
            SizedBox(
              width: 150,
              child: TextFormField(
                readOnly: true,
                enabled: false,
                controller: TextEditingController(text: _result),
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  filled: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            UnitDropdown(
              corpus: widget.corpus,
              variable: widget.formula.output,
              selectedUnit: _selectedOutputUnit,
              onUnitChanged: (unit) {
                setState(() {
                  _selectedOutputUnit = unit;
                });
                _evaluateFormula();
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVariableRow(VariableSpec variable) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(variable.name),
          const Spacer(),
          SizedBox(
            width: 100,
            child: TextFormField(
              controller: _inputControllers[variable.name],
              keyboardType: TextInputType.number,
              inputFormatters: [
                //FilteringTextInputFormatter.allow(RegExp(r'[0-9\.\-]')),
              ],
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Required';
                }
                return null;
              },
            ),
          ),
          const SizedBox(width: 8),
          UnitDropdown(
            corpus: widget.corpus,
            variable: variable,
            selectedUnit: _selectedUnits[variable.name],
            onUnitChanged: (unit) {
              setState(() {
                _selectedUnits[variable.name] = unit;
              });
              _evaluateFormula();
            },
          ),
        ],
      ),
    );
  }
}
