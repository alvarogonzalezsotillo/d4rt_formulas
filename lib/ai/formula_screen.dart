// dart
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../formula_models.dart';
import '../formula_evaluator.dart';
import '../corpus.dart';
import 'unit_dropdown.dart';

class FormulaScreen extends StatefulWidget {
  final Formula formula;
  final Corpus corpus;

  const FormulaScreen({super.key, required this.formula, required this.corpus});

  @override
  State<FormulaScreen> createState() => _FormulaScreenState();
}

//// Start of D4rtEditingController class ////
class D4rtEditingController extends TextEditingController {
  String? _lastError;
  String? get lastError => _lastError;
  FormulaResult? _lastValue;

  D4rtEditingController({super.text});

  bool validate() {
    try {
      _lastValue = null;
      if( text.trim().isEmpty ){
        return true;
      }
      _lastValue = FormulaEvaluator.evaluateExpression(text);
      _lastError = null;
      return true;
    } catch (e, s) {
      _lastError = e.toString();
      print("validate: $text: $e");
      print("stack: $s");
      return false;
    }
  }

  FormulaResult? get d4rtValue => _lastValue;

  set text(String newText) {
    super.text = newText;
    validate();
  }

  @override
  void notifyListeners() {
    validate();
    super.notifyListeners();
  }
}
//// End of D4rtEditingController class ////

class _FormulaScreenState extends State<FormulaScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, D4rtEditingController> _inputControllers = {};
  final Map<String, String?> _selectedUnits = {};
  final Map<String, String?> _selectedValues = {}; // for string dropdowns
  String? _result;
  String? _selectedOutputUnit;

  @override
  void initState() {
    super.initState();
    // Initialize controllers and units with listeners
    for (final input in widget.formula.input) {
      _selectedUnits[input.name] = input.unit;
      if (input.values != null && input.values!.isNotEmpty) {
        // string/categorical variable -> use dropdown
        _selectedValues[input.name] = input.values!.first;
      } else {
        // numeric variable -> use D4rtEditingController
        _inputControllers[input.name] = D4rtEditingController();
        _inputControllers[input.name]!.addListener(_evaluateFormula);
      }
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
    print( "EVALUATE FORMULA");
    if (!_formKey.currentState!.validate()) return;

    try {
      final inputValues = <String, dynamic>{};
      for (final input in widget.formula.input) {
        // string/categorical variable
        if (input.values != null && input.values!.isNotEmpty) {
          final selected = _selectedValues[input.name];
          if (selected == null) {
            _result = "";
            return;
          }
          inputValues[input.name] = selected;
          continue;
        }

        // numeric variable - must have controller
        final controller = _inputControllers[input.name]!;
        final val = controller.d4rtValue;
        if (val == null) {
          _result = "";
          return;
        }

        dynamic convertedValue;
        if (val is NumberResult) {
          if (input.unit != null) {
            convertedValue = widget.corpus.convert(
              val.value,
              _selectedUnits[input.name]!,
              input.unit as String,
            );
          } else {
            convertedValue = val.value;
          }
        } else if (val is StringResult) {
          convertedValue = val.value;
        } else {
          throw FormulaEvaluationException(
            "Field ${input.name} has unsupported type ${val.runtimeType}",
          );
        }

        inputValues[input.name] = convertedValue;
      }

      final evaluator = FormulaEvaluator();
      final result = evaluator.evaluate(widget.formula, inputValues);

      // Convert output to selected unit if needed
      String? unit = widget.formula.output.unit;
      if (unit != null && unit is Number) {
        final converted = widget.corpus.convert(result, unit, _selectedOutputUnit!);
        if (converted is num) {
          _result = converted.toStringAsFixed(2);
        } else {
          _result = converted.toString();
        }
      } else {
        _result = result?.toString();
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
      appBar: AppBar(title: Text(widget.formula.name)),
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
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
                _selectedOutputUnit = unit;
                _evaluateFormula();
                setState(() {
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVariableRow(VariableSpec variable) {
    final isCategorical = variable.values != null && variable.values!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(variable.name),
          const Spacer(),
          if (isCategorical) ...[
            SizedBox(
              width: 150,
              child: DropdownButtonFormField<String>(
                value: _selectedValues[variable.name],
                items: variable.values!
                    .map((v) => DropdownMenuItem<String>(value: v, child: Text(v)))
                    .toList(),
                onChanged: (v) {
                  _selectedValues[variable.name] = v;
                  _evaluateFormula();
                  setState(() {
                  });
                },
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 8),
            if (variable.unit != null)
              UnitDropdown(
                corpus: widget.corpus,
                variable: variable,
                selectedUnit: _selectedUnits[variable.name],
                onUnitChanged: (unit) {
                  _selectedUnits[variable.name] = unit;
                  _evaluateFormula();
                  setState(() {
                  });
                },
              ),
          ] else ...[
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
                autovalidateMode: AutovalidateMode.always,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  return _inputControllers[variable.name]!.lastError;
                },
              ),
            ),
            const SizedBox(width: 8),
            if (variable.unit != null)
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
        ],
      ),
    );
  }
}
