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
            child: _filteredUnits.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 40, color: Theme.of(context).colorScheme.outline),
                        const SizedBox(height: 16),
                        Text('No matching units found', 
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
              itemCount: _filteredUnits.length,
              itemBuilder: (context, index) {
                final unit = _filteredUnits[index];
                return ListTile(
                  title: Text(unit.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Symbol: ${unit.symbol}'),
                      Text('Base: ${unit.baseUnit}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant
                        ),
                      ),
                      if (unit.factorFromUnitToBase != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text('1 ${unit.name} = ${unit.factorFromUnitToBase} ${unit.baseUnit}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontFeatures: [const FontFeature.tabularFigures()],
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  tileColor: index.isEven
                      ? Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.2)
                      : null,
                  visualDensity: VisualDensity.compact,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
