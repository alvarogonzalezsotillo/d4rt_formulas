import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus_latex/flutter_markdown_plus_latex.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as markdown;
import '../formula_models.dart';
import '../corpus.dart';
import '../database/database_service.dart';
import '../service_locator.dart';
import 'formula_screen.dart';
import 'unit_dropdown.dart';

/// A screen for editing a Formula's properties including name, description,
/// input/output variables, and d4rt code.
class FormulaEditor extends StatefulWidget {
  final Formula formula;
  final Corpus corpus;
  final Function(Formula)? onSave; // Callback when formula is saved

  const FormulaEditor({
    super.key,
    required this.formula,
    required this.corpus,
    this.onSave,
  });

  @override
  State<FormulaEditor> createState() => _FormulaEditorState();
}

class _FormulaEditorState extends State<FormulaEditor> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _d4rtCodeController;
  
  // Track input variables
  final List<_InputVariableRowData> _inputVariables = [];
  
  // Output variable
  late _OutputVariableRowData _outputVariable;
  
  bool _isPreviewVisible = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.formula.name);
    _descriptionController = TextEditingController(text: widget.formula.description ?? '');
    _d4rtCodeController = TextEditingController(text: widget.formula.d4rtCode);
    
    // Initialize input variables
    for (final input in widget.formula.input) {
      _inputVariables.add(_InputVariableRowData(
        nameController: TextEditingController(text: input.name),
        unit: input.unit,
        values: input.values != null ? List.from(input.values!) : null,
      ));
    }
    
    // Initialize output variable
    _outputVariable = _OutputVariableRowData(
      nameController: TextEditingController(text: widget.formula.output.name),
      unit: widget.formula.output.unit,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _d4rtCodeController.dispose();
    for (final variable in _inputVariables) {
      variable.nameController.dispose();
    }
    _outputVariable.nameController.dispose();
    super.dispose();
  }

  void _addInputVariable() {
    setState(() {
      _inputVariables.add(_InputVariableRowData(
        nameController: TextEditingController(text: 'var${_inputVariables.length + 1}'),
        unit: null,
        values: null,
      ));
    });
  }

  void _removeInputVariable(int index) {
    setState(() {
      _inputVariables.removeAt(index);
    });
  }

  void _showPreview() {
    setState(() {
      _isPreviewVisible = true;
    });
  }

  void _hidePreview() {
    setState(() {
      _isPreviewVisible = false;
    });
  }

  void _testFormula() {
    // Validate the formula before testing
    if (!_validateFormula()) {
      return;
    }

    final formula = _buildFormula();
    if (formula == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormulaScreen(
          formula: formula,
          corpus: widget.corpus,
        ),
      ),
    );
  }

  bool _validateFormula() {
    // Validate name
    if (_nameController.text.trim().isEmpty) {
      _showErrorDialog('Formula name cannot be empty');
      return false;
    }

    // Validate output name
    if (_outputVariable.nameController.text.trim().isEmpty) {
      _showErrorDialog('Output variable name cannot be empty');
      return false;
    }

    // Validate input variable names
    for (final variable in _inputVariables) {
      if (variable.nameController.text.trim().isEmpty) {
        _showErrorDialog('Input variable names cannot be empty');
        return false;
      }
    }

    // Validate d4rt code
    if (_d4rtCodeController.text.trim().isEmpty) {
      _showErrorDialog('D4RT code cannot be empty');
      return false;
    }

    return true;
  }

  Formula? _buildFormula() {
    try {
      final input = <VariableSpec>[];
      for (final variable in _inputVariables) {
        input.add(VariableSpec(
          name: variable.nameController.text.trim(),
          unit: variable.unit,
          values: variable.values,
        ));
      }

      final output = VariableSpec(
        name: _outputVariable.nameController.text.trim(),
        unit: _outputVariable.unit,
      );

      return Formula(
        name: _nameController.text.trim(),
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        input: input,
        output: output,
        d4rtCode: _d4rtCodeController.text,
        tags: widget.formula.tags, // Preserve existing tags
      );
    } catch (e) {
      _showErrorDialog('Error building formula: $e');
      return null;
    }
  }

  Future<void> _saveFormula() async {
    if (!_validateFormula()) {
      return;
    }

    final formula = _buildFormula();
    if (formula == null) return;

    try {
      final database = getDatabase();
      
      // Update corpus in memory
      widget.corpus.updateFormula(formula);
      
      // Update database
      final updated = await database.updateFormula(formula);
      
      if (!updated) {
        // If formula wasn't found (e.g., name changed), add it as new
        await database.addFormula(formula);
      }
      
      // Call the onSave callback if provided
      widget.onSave?.call(formula);
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Formula "${formula.name}" saved successfully!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } catch (e, stack) {
      print('Error saving formula: $e\n$stack');
      _showErrorDialog('Error saving formula: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Formula'),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: _testFormula,
            tooltip: 'Test Formula',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveFormula,
            tooltip: 'Save',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              _buildNameSection(),
              const SizedBox(height: 16),
              _buildDescriptionSection(),
              const SizedBox(height: 16),
              _buildInputVariablesSection(),
              const SizedBox(height: 16),
              _buildOutputVariableSection(),
              const SizedBox(height: 16),
              _buildD4rtCodeSection(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameSection() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: 'Formula Name',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.title),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Name is required';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Description (Markdown)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isPreviewVisible)
                      TextButton.icon(
                        icon: const Icon(Icons.visibility_off),
                        label: const Text('Hide Preview'),
                        onPressed: _hidePreview,
                      )
                    else
                      TextButton.icon(
                        icon: const Icon(Icons.visibility),
                        label: const Text('Preview'),
                        onPressed: _showPreview,
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_isPreviewVisible) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Markdown(
                  data: _descriptionController.text,
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
              const SizedBox(height: 16),
            ],
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                hintText: 'Enter formula description (supports Markdown and LaTeX)',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputVariablesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Input Variables',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ..._inputVariables.asMap().entries.map((entry) {
              final index = entry.key;
              final variable = entry.value;
              return _buildInputVariableRow(index, variable);
            }).toList(),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Input Variable'),
              onPressed: _addInputVariable,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputVariableRow(int index, _InputVariableRowData variable) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: variable.nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Base Unit', style: TextStyle(fontSize: 12)),
                      DropdownButtonFormField<String?>(
                        value: _getBaseUnit(variable.unit),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                        ),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('None', style: TextStyle(fontSize: 14)),
                          ),
                          ..._getAllBaseUnits().map((baseUnit) {
                            return DropdownMenuItem<String?>(
                              value: baseUnit,
                              child: Text(baseUnit, style: const TextStyle(fontSize: 14)),
                            );
                          }).toList(),
                        ],
                        onChanged: (baseUnit) {
                          setState(() {
                            variable.unit = baseUnit;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Derived Unit', style: TextStyle(fontSize: 12)),
                      DropdownButtonFormField<String?>(
                        value: variable.unit,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                        ),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('None', style: TextStyle(fontSize: 14)),
                          ),
                          ..._getDerivedUnits(variable.unit).map((unit) {
                            final unitSpec = widget.corpus.getUnit(unit);
                            return DropdownMenuItem<String?>(
                              value: unit,
                              child: Text('${unitSpec.symbol} - ${unit}', 
                                style: const TextStyle(fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                        ],
                        onChanged: (unit) {
                          setState(() {
                            variable.unit = unit;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeInputVariable(index),
                  tooltip: 'Delete variable',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutputVariableSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Output Variable',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _outputVariable.nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Base Unit', style: TextStyle(fontSize: 12)),
                      DropdownButtonFormField<String?>(
                        value: _getBaseUnit(_outputVariable.unit),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                        ),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('None', style: TextStyle(fontSize: 14)),
                          ),
                          ..._getAllBaseUnits().map((baseUnit) {
                            return DropdownMenuItem<String?>(
                              value: baseUnit,
                              child: Text(baseUnit, style: const TextStyle(fontSize: 14)),
                            );
                          }).toList(),
                        ],
                        onChanged: (baseUnit) {
                          setState(() {
                            _outputVariable.unit = baseUnit;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Derived Unit', style: TextStyle(fontSize: 12)),
                      DropdownButtonFormField<String?>(
                        value: _outputVariable.unit,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                        ),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('None', style: TextStyle(fontSize: 14)),
                          ),
                          ..._getDerivedUnits(_outputVariable.unit).map((unit) {
                            final unitSpec = widget.corpus.getUnit(unit);
                            return DropdownMenuItem<String?>(
                              value: unit,
                              child: Text('${unitSpec.symbol} - ${unit}', 
                                style: const TextStyle(fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                        ],
                        onChanged: (unit) {
                          setState(() {
                            _outputVariable.unit = unit;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildD4rtCodeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'D4RT Code',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.code, size: 16, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Dart Syntax',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextFormField(
                    controller: _d4rtCodeController,
                    decoration: const InputDecoration(
                      hintText: 'Enter D4RT/Dart code here',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(12),
                    ),
                    maxLines: 10,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods for unit management
  String? _getBaseUnit(String? unit) {
    if (unit == null) return null;
    try {
      return widget.corpus.getUnit(unit).baseUnit;
    } catch (e) {
      return null;
    }
  }

  List<String> _getAllBaseUnits() {
    final baseUnits = <String>{};
    for (final unit in widget.corpus.allUnits()) {
      baseUnits.add(unit.baseUnit);
    }
    return baseUnits.toList()..sort();
  }

  List<String> _getDerivedUnits(String? baseUnit) {
    if (baseUnit == null) return [];
    return widget.corpus.unitsOfSameMagnitude(baseUnit)..sort();
  }
}

// Data classes to track variable state
class _InputVariableRowData {
  final TextEditingController nameController;
  String? unit;
  List<dynamic>? values;

  _InputVariableRowData({
    required this.nameController,
    this.unit,
    this.values,
  });
}

class _OutputVariableRowData {
  final TextEditingController nameController;
  String? unit;

  _OutputVariableRowData({
    required this.nameController,
    this.unit,
  });
}
