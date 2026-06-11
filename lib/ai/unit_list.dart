import 'package:d4rt_formulas/ai/unit_editor.dart';
import 'package:d4rt_formulas/error_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:d4rt_formulas/formula_models.dart';
import 'package:get_it/get_it.dart';
import '../corpus.dart';
import '../set_utils.dart';
import 'formula_screen.dart';
import 'package:share_plus/share_plus.dart' as share_plus;
import 'formula_editor.dart';
import 'package:share_plus/share_plus.dart';
import 'import_preview_screen.dart';
import '../services/import_service.dart';

class UnitList extends StatefulWidget {
  final Corpus corpus;
  final VoidCallback? onImport;

  const UnitList({
    super.key,
    required this.corpus,
    this.onImport,
  });

  @override
  State<UnitList> createState() => _UnitListState();

  static String _unitToExportStringLiteral(UnitSpec unit) {
    final corpus = GetIt.instance.get<Corpus>();
    final dependencies = corpus.withDependencies(unit);
    final dependenciesAsMap = dependencies.map((f) => f.toMap()).toList();
    for( final f in dependenciesAsMap ){
      f.remove("uuid");
    }

    final map = unit.toMap();
    map.remove("uuid");

    return SetUtils.prettyPrint(map);
  }


  static void shareUnit(UnitSpec unit) async {
    try {
      final exportString = _unitToExportStringLiteral(unit);

      // Share the string
      await share_plus.SharePlus.instance.share(
        share_plus.ShareParams(
          text: exportString,
          subject: 'Sharing unit: ${unit.name}',
        ),
      );
    } catch (e, st) {
      errorHandler.notify(e, st);
    }
  }

  static void copyFormula(BuildContext context, UnitSpec unit) async {
    try {
      final exportString = _unitToExportStringLiteral(unit);

      // Copy to clipboard
      await Clipboard.setData(ClipboardData(text: exportString));

      // Show a snackbar to confirm
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unit and dependencies copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e, st) {
      errorHandler.notify(e, st);
    }
  }

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
    var allUnits = widget.corpus.getUnits();
    if (_searchQuery.isEmpty) return allUnits;

    return allUnits.where((unit){
      final nameMatch = unit.name.toLowerCase().contains(_searchQuery);
      final tagMatch = unit.symbol.toLowerCase().contains(_searchQuery);
      return nameMatch || tagMatch;
    }).toList(growable: false);
  }


  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Search untis',
              hintText: 'Search by name or symbol...',
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
                title: Text(unit.name + " " + unit.symbol ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // TOTHINK: Add buttons here, but I don't know which ones
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UnitEditor(
                        unit: unit,
                        corpus: widget.corpus,
                        onSave: (unit){
                          setState(() {
                            // Refresh the list when returning from the formula screen
                          });
                        },
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
