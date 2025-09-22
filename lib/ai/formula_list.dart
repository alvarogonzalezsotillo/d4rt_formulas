import 'package:flutter/material.dart';
import 'package:d4rt_formulas/formula_models.dart';
import '../corpus.dart';
import 'formula_screen.dart';

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
