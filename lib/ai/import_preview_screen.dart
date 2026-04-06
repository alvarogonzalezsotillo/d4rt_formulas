import 'package:d4rt_formulas/d4rt_formulas.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:d4rt_formulas/formula_models.dart';
import 'package:d4rt_formulas/corpus.dart';
import 'package:d4rt_formulas/ai/formula_editor.dart';
import 'package:d4rt_formulas/services/import_service.dart';
import 'package:d4rt_formulas/service_locator.dart';

import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:highlight/languages/dart.dart';

/// Screen to preview and import formula elements
class ImportPreviewScreen extends StatefulWidget {
  final List<FormulaElement> elements;
  final Corpus corpus;

  const ImportPreviewScreen({super.key, required this.elements, required this.corpus});

  @override
  State<ImportPreviewScreen> createState() => _ImportPreviewScreenState();
}

class _ImportPreviewScreenState extends State<ImportPreviewScreen> {
  final Set<String> _selectedUuids = {};

  @override
  void initState() {
    super.initState();
    // Select all by default
    for (final element in widget.elements) {
      _selectedUuids.add(element.uuid);
    }
  }

  void _editFormulaElement(FormulaElement element) {
    if (element is Formula) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FormulaEditor(
            formula: element,
            corpus: widget.corpus,
            onSave: (updatedFormula) {
              // Update the element in the list
              setState(() {
                final index = widget.elements.indexWhere((e) => e is Formula && e.uuid == updatedFormula.uuid);
                if (index != -1) {
                  widget.elements[index] = updatedFormula;
                }
              });
            },
          ),
        ),
      );
    }
  }

  Future<void> _importSelected() async {
    final selectedElements = widget.elements.where((element) {
      return _selectedUuids.contains(element.uuid);
    }).toList();

    if (selectedElements.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No elements selected to import'), backgroundColor: Colors.orange));
      return;
    }

    try {
      widget.corpus.loadFormulaElements(selectedElements, true);

      // Save imported elements to the database
      final database = getDatabase();
      for (final element in selectedElements) {
        final existingElement = await database.getFormulaElementByUuid(element.uuid);
        if (existingElement != null) {
          // Update existing element
          await database.updateFormulaElement(element.uuid, element.toStringLiteral());
        } else {
          // Insert new element
          await database.insertFormulaElement(element.uuid, element.toStringLiteral());
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Imported ${selectedElements.length} element(s) successfully'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e,st) {
      errorHandler.notify('Error importing formula elements: $e', st);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error importing: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final formulas = widget.elements.whereType<Formula>().toList();
    final units = widget.elements.whereType<UnitSpec>().toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Preview'),
        actions: [IconButton(icon: const Icon(Icons.check), tooltip: 'Import Selected', onPressed: _importSelected)],
      ),
      body: Column(
        children: [
          if (formulas.isEmpty && units.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No formula elements found in the shared content', style: TextStyle(fontSize: 16)),
            )
          else
            Expanded(
              child: ListView(
                children: [
                  if (formulas.isNotEmpty) ...[
                    const ListTile(
                      title: Text('Formulas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    ...formulas.map((formula) => _buildFormulaTile(formula)),
                  ],
                  if (units.isNotEmpty) ...[
                    const ListTile(
                      title: Text('Units', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    ...units.map((unit) => _buildUnitTile(unit)),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFormulaTile(Formula formula) {
    final isSelected = _selectedUuids.contains(formula.uuid);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Checkbox(
          value: isSelected,
          onChanged: (value) {
            setState(() {
              if (value == true) {
                _selectedUuids.add(formula.uuid);
              } else {
                _selectedUuids.remove(formula.uuid);
              }
            });
          },
        ),
        title: Text(formula.name),
        subtitle: Text(
          formula.description?.isNotEmpty == true ? formula.description!.split('\n').first : 'No description',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (formula.tags.isNotEmpty)
              SingleChildScrollView(
                child: SizedBox(
                  width: 150,
                  child: Wrap(
                    spacing: 4,
                    children: formula.tags.take(10).map((tag) {
                      return Chip(
                        label: Text(tag, style: const TextStyle(fontSize: 10)),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
                  ),
                ),
              ),
            IconButton(icon: const Icon(Icons.edit), tooltip: 'Edit', onPressed: () => _editFormulaElement(formula)),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitTile(UnitSpec unit) {
    final isSelected = _selectedUuids.contains(unit.uuid);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Checkbox(
          value: isSelected,
          onChanged: (value) {
            setState(() {
              if (value == true) {
                _selectedUuids.add(unit.uuid);
              } else {
                _selectedUuids.remove(unit.uuid);
              }
            });
          },
        ),
        title: Text(unit.name),
        subtitle: Text('Base: ${unit.baseUnit} • Symbol: ${unit.symbol}'),
      ),
    );
  }
}

