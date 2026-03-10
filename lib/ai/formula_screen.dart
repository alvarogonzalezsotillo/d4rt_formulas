// dart
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus_latex/flutter_markdown_plus_latex.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as markdown;
import '../formula_models.dart';
import '../formula_evaluator.dart';
import '../corpus.dart';
import '../error_handler.dart';
import 'd4rt_editing_controller.dart';
import 'unit_dropdown.dart';
import 'formula_editor.dart';

class FormulaScreen extends StatefulWidget {
  final FormulaInterface initialFormula;
  final Corpus corpus;
  final Function(Formula)? onSave; // Callback when formula is saved

  FormulaScreen({super.key, required formula, required this.corpus, this.onSave}) : initialFormula = formula;

  @override
  State<FormulaScreen> createState() => _FormulaScreenState();
}


class _FormulaScreenState extends State<FormulaScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, D4rtEditingController> _inputControllers = {};
  final Map<String, String?> _selectedUnits = {};
  final Map<String, String?> _selectedValues = {}; // for string dropdowns
  String? _result;
  String? _selectedOutputUnit;
  bool _isDescriptionExpanded = false; // Track description expansion state
  late FormulaInterface _formula;

  FormulaInterface get formula => _formula;
  String? _errorMessage; // Track error message for expansion tile
  bool _isErrorExpanded = false; // Track error expansion state

  set formula(FormulaInterface newFormula) {
    _formula = newFormula;

    // Initialize controllers and units with listeners
    for (final input in formula.input) {
      _selectedUnits[input.name] = input.unit;
      if (input.values != null && input.values!.isNotEmpty) {
        // string/categorical variable -> use dropdown
        _selectedValues[input.name] = input.values!.first;
      } else {
        // numeric variable -> use D4rtEditingController
        _inputControllers[input.name] = D4rtEditingController(isString: input.unit == "string");
        _inputControllers[input.name]!.addListener(_evaluateFormula);
      }
    }
    _selectedOutputUnit = formula.output.unit;
  }

  @override
  void initState() {
    super.initState();
    formula = widget.initialFormula;
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
    try {
      final inputValues = <String, dynamic>{};
      for (final input in formula.input) {
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

      late final dynamic result;
      if( formula is DerivedFormula) {
        result = formulaSolver(formula, formula.output.name, inputValues,);
      }
      else {
        print( "TODO: MAYBE ONLY FORMULASOLVER IS NECCESSARY");
        final evaluator = FormulaEvaluator();
        result = evaluator.evaluate(formula as Formula, inputValues);
      }

      // Convert output to selected unit if needed
      String? unit = formula.output.unit;
      if (unit != null && result is Number) {
        final converted = widget.corpus.convert(result, unit, _selectedOutputUnit!);
        _result = converted.toStringAsFixed(2);
      } else {
        _result = result?.toString();
      }

      setState(() {
        _errorMessage = null; // Clear error on successful evaluation
      });
    } catch (e, stack) {
      errorHandler.notify(e, stack);
      setState(() {
        _errorMessage = e.toString();
        _result = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(formula.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: formula is DerivedFormula
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            FormulaEditor(
                              formula: formula as Formula,
                              corpus: widget.corpus,
                              onSave: (updatedFormula) {
                                widget.onSave?.call(updatedFormula);
                                setState(() {
                                  formula = updatedFormula;
                                });
                              },
                            ),
                      ),
                    );
                  },
            tooltip: formula is DerivedFormula
                ? 'Cannot edit derived formula'
                : 'Edit Formula',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              _buildDescriptionSection(),
              _buildErrorSection(),
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
    if (formula.description == null ||
        formula.description!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(
          'Description',
          style: Theme
              .of(context)
              .textTheme
              .titleMedium
              ?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        initiallyExpanded: _isDescriptionExpanded,
        onExpansionChanged: (bool expanded) {
          setState(() {
            _isDescriptionExpanded = expanded;
          });
        },
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme
                    .of(context)
                    .colorScheme
                    .surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Markdown(
                data: formula.description!,
                shrinkWrap: true,
                builders: {
                  'latex': LatexElementBuilder(),
                },
                extensionSet: markdown.ExtensionSet(
                  [LatexBlockSyntax()],
                  [LatexInlineSyntax()],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorSection() {
    if (_errorMessage == null) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Theme.of(context).colorScheme.errorContainer,
      child: ExpansionTile(
        title: Text(
          '⚠️ There was an error. Show details...',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
        ),
        initiallyExpanded: _isErrorExpanded,
        onExpansionChanged: (bool expanded) {
          setState(() {
            _isErrorExpanded = expanded;
          });
        },
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                _errorMessage!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Input Variables',
          style: Theme
              .of(
            context,
          )
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...formula.input.map((variable) => _buildVariableRow(variable)),
      ],
    );
  }

  Widget _buildOutputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Result',
          style: Theme
              .of(
            context,
          )
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // Fixed width for field name
            SizedBox(
              width: 150,
              child: Text(
                formula.output.name,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8), // Add some spacing
            // Flexible space for result field
            Expanded(
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
              variable: formula.output,
              selectedUnit: _selectedOutputUnit,
              onUnitChanged: (unit) {
                _selectedOutputUnit = unit;
                _evaluateFormula();
                print("En output unit changed to $unit: $_result");
                setState(() {});
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
          // Fixed width for field name
          SizedBox(
            width: 150,
            child: Text(
              variable.name,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8), // Add some spacing
          // Flexible space for input field
          Expanded(
            child: isCategorical
                ? DropdownButtonFormField<String>(
              value: _selectedValues[variable.name],
              items: variable.values!
                  .map((v) => DropdownMenuItem<String>(value: v, child: Text(v)))
                  .toList(),
              onChanged: (v) {
                _selectedValues[variable.name] = v;
                _evaluateFormula();
                setState(() {});
              },
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Required';
                return null;
              },
            )
                : TextFormField(
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
          if (variable.unit != null && !isCategorical)
            IconButton(
              icon: const Icon(Icons.swap_horiz),
              tooltip: 'Solve for ${variable.name}',
              onPressed: () {
                _solveForVariable(variable);
              },
            ),
          if (variable.unit != null && !isCategorical)
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

  void _solveForVariable(VariableSpec variable) {
    // Check if the formula is already a DerivedFormula
    if (formula is DerivedFormula) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot create derived formula from another derived formula'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      // Create a DerivedFormula with this input variable as output
      final derivedFormula = DerivedFormula(
        outputName: variable.name,
        originalFormula: formula,
      );

      // Navigate to the new DerivedFormula screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FormulaScreen(
            formula: derivedFormula,
            corpus: widget.corpus,
            onSave: widget.onSave,
          ),
        ),
      );
    } catch (e, st) {
      errorHandler.notify(e,st);
    }
  }
}
