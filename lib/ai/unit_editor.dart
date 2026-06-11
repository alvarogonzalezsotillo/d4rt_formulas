import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus_latex/flutter_markdown_plus_latex.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as markdown;
import '../formula_models.dart';
import '../corpus.dart';
import '../database/database_service.dart';
import '../service_locator.dart';
import 'unit_dropdown.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:highlight/languages/dart.dart';

/// Editor for UnitSpec similar in style to FormulaEditor.
class UnitEditor extends StatefulWidget {
  final UnitSpec unit;
  final Corpus corpus;
  final Function(UnitSpec)? onSave;

  const UnitEditor({super.key, required this.unit, required this.corpus, this.onSave});

  @override
  State<UnitEditor> createState() => _UnitEditorState();
}

class _UnitEditorState extends State<UnitEditor> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _symbolController;
  String? _baseUnit;
  bool _isBase = false;

  // Either factor mode or code mode
  bool _useFactor = true;
  late TextEditingController _factorController;
  late CodeController _toBaseCodeController;
  late CodeController _fromBaseCodeController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.unit.name);
    _symbolController = TextEditingController(text: widget.unit.symbol);
    _baseUnit = widget.unit.baseUnit;
    _isBase = (widget.unit.baseUnit == widget.unit.name && (widget.unit.factorFromUnitToBase == 1));

    if (widget.unit.factorFromUnitToBase != null) {
      _useFactor = true;
      _factorController = TextEditingController(text: widget.unit.factorFromUnitToBase!.toString());
    } else {
      _useFactor = false;
      _factorController = TextEditingController(text: '');
    }

    _toBaseCodeController = CodeController(language: dart, text: widget.unit.codeFromUnitToBase ?? '');
    _fromBaseCodeController = CodeController(language: dart, text: widget.unit.codeFromBaseToUnit ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _symbolController.dispose();
    _factorController.dispose();
    _toBaseCodeController.dispose();
    _fromBaseCodeController.dispose();
    super.dispose();
  }

  List<String> _allBaseUnits() {
    final baseSet = <String>{};
    for (final u in widget.corpus.allUnits()) {
      baseSet.add(u.baseUnit);
    }
    // Ensure "scalar" present
    baseSet.add('scalar');
    final list = baseSet.toList();
    list.sort();
    return list;
  }

  Future<void> _saveUnit() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final symbol = _symbolController.text.trim();

    try {
      UnitSpec newUnit;
      if (_isBase) {
        newUnit = UnitSpec(name: name, baseUnit: name, symbol: symbol, factorFromUnitToBase: 1);
      } else if (_useFactor) {
        final factor = double.tryParse(_factorController.text.trim());
        if (factor == null) {
          _showErrorDialog('Invalid numeric factor');
          return;
        }
        newUnit = UnitSpec(name: name, baseUnit: _baseUnit ?? 'scalar', symbol: symbol, factorFromUnitToBase: factor);
      } else {
        final toBase = _toBaseCodeController.fullText.trim();
        final fromBase = _fromBaseCodeController.fullText.trim();
        if (toBase.isEmpty || fromBase.isEmpty) {
          _showErrorDialog('Both conversion code snippets are required');
          return;
        }
        newUnit = UnitSpec(name: name, baseUnit: _baseUnit ?? 'scalar', symbol: symbol, codeFromUnitToBase: toBase, codeFromBaseToUnit: fromBase);
      }

      final database = getDatabase();

      // Update corpus
      widget.corpus.updateUnit(newUnit);

      // Persist to DB
      final existing = await database.getFormulaElementByUuid(newUnit.uuid);
      if (existing != null) {
        await database.updateFormulaElement(newUnit.uuid, newUnit.toStringLiteral());
      } else {
        await database.insertFormulaElement(newUnit.uuid, newUnit.toStringLiteral());
      }

      widget.onSave?.call(newUnit);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unit "${newUnit.name}" saved'), backgroundColor: Theme.of(context).colorScheme.primary),
      );

      Navigator.of(context).pop(newUnit);
    } catch (e, st) {
      print('Error saving unit: $e\n$st');
      _showErrorDialog('Error saving unit: $e');
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
        title: const Text('Edit Unit'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveUnit, tooltip: 'Save'),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Unit Name', border: OutlineInputBorder(), prefixIcon: Icon(Icons.title)),
                validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _symbolController,
                decoration: const InputDecoration(labelText: 'Symbol', border: OutlineInputBorder(), prefixIcon: Icon(Icons.label)),
                validator: (v) => v == null || v.trim().isEmpty ? 'Symbol is required' : null,
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Base unit', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _isBase ? widget.unit.name : _baseUnit,
                              decoration: const InputDecoration(border: OutlineInputBorder()),
                              items: _allBaseUnits().map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                              onChanged: _isBase
                                  ? null
                                  : (val) {
                                      setState(() {
                                        _baseUnit = val;
                                      });
                                    },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            children: [
                              const Text('Is base unit?'),
                              Checkbox(
                                value: _isBase,
                                onChanged: (v) {
                                  setState(() {
                                    _isBase = v ?? false;
                                    if (_isBase) {
                                      _baseUnit = widget.unit.name;
                                    }
                                  });
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Conversion to base', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ChoiceChip(
                            label: const Text('Factor'),
                            selected: _useFactor,
                            onSelected: (s) => setState(() => _useFactor = true),
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('Code'),
                            selected: !_useFactor,
                            onSelected: (s) => setState(() => _useFactor = false),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_useFactor) ...[
                        TextFormField(
                          controller: _factorController,
                          decoration: const InputDecoration(labelText: 'Factor (unit -> base)', border: OutlineInputBorder()),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (v) {
                            if (_isBase) return null;
                            if (v == null || v.trim().isEmpty) return 'Factor is required for numeric conversion';
                            if (double.tryParse(v.trim()) == null) return 'Invalid number';
                            return null;
                          },
                        ),
                      ] else ...[
                        const Text('To convert using code, provide Dart expression or statements that compute x.'),
                        const SizedBox(height: 8),
                        const Text('Code (unit -> base):', style: TextStyle(fontWeight: FontWeight.bold)),
                        ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 120),
                          child: CodeTheme(
                            data: CodeThemeData(styles: monokaiSublimeTheme),
                            child: SingleChildScrollView(child: CodeField(controller: _toBaseCodeController)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text('Code (base -> unit):', style: TextStyle(fontWeight: FontWeight.bold)),
                        ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 120),
                          child: CodeTheme(
                            data: CodeThemeData(styles: monokaiSublimeTheme),
                            child: SingleChildScrollView(child: CodeField(controller: _fromBaseCodeController)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
