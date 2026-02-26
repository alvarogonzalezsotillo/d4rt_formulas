import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:d4rt_formulas/formula_models.dart';
import '../corpus.dart';
import 'formula_screen.dart';
import 'formula_editor.dart';
import 'package:share_plus/share_plus.dart';

class FormulaList extends StatefulWidget {
  final Corpus corpus;
  final List<Formula> formulas;

  const FormulaList({
    super.key,
    required this.corpus,
    required this.formulas,
  });

  @override
  State<FormulaList> createState() => _FormulaListState();
}

class _FormulaListState extends State<FormulaList> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Formula> get _filteredFormulas {
    if (_searchQuery.isEmpty) return widget.formulas;

    return widget.formulas.where((formula) {
      final nameMatch = formula.name.toLowerCase().contains(_searchQuery);
      final tagMatch = formula.tags.any((tag) => tag.toLowerCase().contains(_searchQuery));
      return nameMatch || tagMatch;
    }).toList();
  }

  void _shareFormula(Formula formula) async {
    try {
      // Get the formula and its dependencies
      final dependencies = widget.corpus.withDependencies(formula);

      // Convert each dependency to its string literal representation
      final literals = dependencies.map((element) => element.toStringLiteral()).toList();

      // Create an array string literal containing all the elements
      final exportString = '[${literals.join(', ')}]';

      // Share the string
      await Share.share(
        exportString,
        subject: 'Sharing formula: ${formula.name}',
      );
    } catch (e) {
      _showErrorDialog('Error sharing formula: $e');
    }
  }

  void _editFormula(Formula formula) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormulaEditor(
          formula: formula,
          corpus: widget.corpus,
          onSave: (updatedFormula) {
            // Refresh the formula list after saving
            setState(() {
              // The corpus has been updated, so we just need to rebuild
            });
          },
        ),
      ),
    );
  }

  void _copyFormula(Formula formula) async {
    try {
      // Get the formula and its dependencies
      final dependencies = widget.corpus.withDependencies(formula);
      
      // Convert each dependency to its string literal representation
      final literals = dependencies.map((element) => element.toStringLiteral()).toList();
      
      // Create an array string literal containing all the elements
      final exportString = '[${literals.join(', ')}]';
      
      // Copy to clipboard
      await Clipboard.setData(ClipboardData(text: exportString));
      
      // Show a snackbar to confirm
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Formula and dependencies copied to clipboard!'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      _showErrorDialog('Error copying formula: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Search formulas',
              hintText: 'Search by name or tag...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _filteredFormulas.length,
            itemBuilder: (context, index) {
              final formula = _filteredFormulas[index];
              return ListTile(
                title: Text(formula.name),
                subtitle: formula.tags.isNotEmpty
                    ? Text('Tags: ${formula.tags.join(', ')}')
                    : null,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editFormula(formula),
                      tooltip: 'Edit Formula',
                    ),
                    PopupMenuButton(
                      icon: const Icon(Icons.share),
                      onSelected: (value) {
                        if (value == 'share') {
                          _shareFormula(formula);
                        } else if (value == 'copy') {
                          _copyFormula(formula);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'share',
                          child: Row(
                            children: [
                              Icon(Icons.share),
                              SizedBox(width: 8),
                              Text('Share'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'copy',
                          child: Row(
                            children: [
                              Icon(Icons.copy),
                              SizedBox(width: 8),
                              Text('Copy to clipboard'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FormulaScreen(
                        formula: formula,
                        corpus: widget.corpus,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
