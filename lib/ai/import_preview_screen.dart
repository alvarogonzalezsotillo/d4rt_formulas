import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:d4rt_formulas/formula_models.dart';
import 'package:d4rt_formulas/corpus.dart';
import 'package:d4rt_formulas/ai/formula_editor.dart';
import 'package:d4rt_formulas/services/import_service.dart';


import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:highlight/languages/java.dart';

/// Screen to preview and import formula elements
class ImportPreviewScreen extends StatefulWidget {
  final List<FormulaElement> elements;
  final Corpus corpus;

  const ImportPreviewScreen({
    super.key,
    required this.elements,
    required this.corpus,
  });

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
      if (element is Formula) {
        _selectedUuids.add(element.uuid);
      } else if (element is UnitSpec) {
        _selectedUuids.add(element.name);
      }
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
                final index = widget.elements.indexWhere(
                  (e) => e is Formula && e.uuid == updatedFormula.uuid,
                );
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

  void _importSelected() {
    final selectedElements = widget.elements.where((element) {
      if (element is Formula) {
        return _selectedUuids.contains(element.uuid);
      } else if (element is UnitSpec) {
        return _selectedUuids.contains(element.name);
      }
      return false;
    }).toList();

    if (selectedElements.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No elements selected to import'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      widget.corpus.loadFormulaElements(selectedElements);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Imported ${selectedElements.length} element(s) successfully'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error importing: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formulas = widget.elements.whereType<Formula>().toList();
    final units = widget.elements.whereType<UnitSpec>().toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Preview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Import Selected',
            onPressed: _importSelected,
          ),
        ],
      ),
      body: Column(
        children: [
          if (formulas.isEmpty && units.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'No formula elements found in the shared content',
                style: TextStyle(fontSize: 16),
              ),
            )
          else
            Expanded(
              child: ListView(
                children: [
                  if (formulas.isNotEmpty) ...[
                    const ListTile(
                      title: Text(
                        'Formulas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ...formulas.map((formula) => _buildFormulaTile(formula)),
                  ],
                  if (units.isNotEmpty) ...[
                    const ListTile(
                      title: Text(
                        'Units',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
          formula.description?.isNotEmpty == true
              ? formula.description!.split('\n').first
              : 'No description',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (formula.tags.isNotEmpty)
              Wrap(
                spacing: 4,
                children: formula.tags.take(3).map((tag) {
                  return Chip(
                    label: Text(tag, style: const TextStyle(fontSize: 10)),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }).toList(),
              ),
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit',
              onPressed: () => _editFormulaElement(formula),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitTile(UnitSpec unit) {
    final isSelected = _selectedUuids.contains(unit.name);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Checkbox(
          value: isSelected,
          onChanged: (value) {
            setState(() {
              if (value == true) {
                _selectedUuids.add(unit.name);
              } else {
                _selectedUuids.remove(unit.name);
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

/// Screen to import formula elements from text
class ImportFromTextScreen extends StatefulWidget {
  final Corpus corpus;

  const ImportFromTextScreen({
    super.key,
    required this.corpus,
  });

  @override
  State<ImportFromTextScreen> createState() => _ImportFromTextScreenState();
}

class _ImportFromTextScreenState extends State<ImportFromTextScreen> {
  final CodeController _codeController = CodeController(
    language: dart,
    text: "// Insert code here...",
  );
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    setState(() => _isLoading = true);
    
    try {
      final clipboardData = await Clipboard.getData('text/plain');
      if (clipboardData?.text != null) {
        _codeController.text = clipboardData!.text!;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Clipboard is empty'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error pasting from clipboard: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _import() async {
    final text = _codeController.fullText;
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter or paste formula text'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final importService = ImportService();
      final elements = importService.parseSharedText(text);
      
      if (!mounted) return;
      
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImportPreviewScreen(
            elements: elements,
            corpus: widget.corpus,
          ),
        ),
      );
      
      if (result == true) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error parsing text: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import from Text'),
      ),
      body: Column(
        children: [
          Expanded(
            child: CodeTheme(
              data: CodeThemeData(styles: monokaiSublimeTheme),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: CodeField(
                    controller: _codeController,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _pasteFromClipboard,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.content_paste),
                    label: const Text('Paste'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _import,
                    icon: const Icon(Icons.import_export),
                    label: const Text('Import'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
