import 'package:flutter/material.dart';
import '../corpus.dart';
import '../formula_models.dart';

class UnitList extends StatefulWidget {
  final UnitCorpus corpus;

  const UnitList({super.key, required this.corpus});

  @override
  State<UnitList> createState() => _UnitListState();
}

class _UnitListState extends State<UnitList> {
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

  List<UnitSpec> get _filteredUnits {
    bool filter(UnitSpec unit) => unit.name.toLowerCase().contains(_searchQuery);
    return widget.corpus.allUnits().where(filter).toList();
  }

  // Add unit conversion to base unit to the unit widget AI!
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Units List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search units',
                hintText: 'Start typing unit name...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredUnits.length,
              itemBuilder: (context, index) {
                final unit = _filteredUnits[index];
                return ListTile(
                  title: Text(unit.name),
                  subtitle: Text('Symbol: ${unit.symbol} • Base unit: ${unit.baseUnit}'),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  tileColor: index.isEven
                      ? Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3)
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
