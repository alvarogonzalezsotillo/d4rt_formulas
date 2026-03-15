import 'package:d4rt_formulas/d4rt_formulas.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'database/database_service.dart';
import 'service_locator.dart';

import 'ai/formula_list.dart';
import 'corpus.dart';
import 'defaults/default_corpus.dart';
import 'formula_models.dart' as models;
import 'ai/import_preview_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup service locator and initialize the database
  setupLocator();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CorpusLoader(),
    );
  }
}

class CorpusLoader extends StatefulWidget {
  @override
  _CorpusLoaderState createState() => _CorpusLoaderState();
}

class _CorpusLoaderState extends State<CorpusLoader> {
  late Future<Corpus> _corpusFuture;

  @override
  void initState() {
    super.initState();
    _corpusFuture = loadCorpusFromDatabaseOrAssets();
  }

  void _handleImport() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImportFromTextScreen(
          corpus: _corpusFuture.then((c) => c).value as Corpus? ?? Corpus(),
        ),
      ),
    ).then((result) {
      if( result ) {
        setState(() {
          // Refresh the list when returning from import
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Corpus>(
      future: _corpusFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Center(child: Text('Error loading corpus: ${snapshot.error}'));
          }

          var corpus = snapshot.data!;
          GetIt.instance.registerSingleton<Corpus>(corpus);

          // If the corpus is empty (user chose not to load default), we could handle that here
          // For now, just display the formula list
          return Scaffold(
            appBar: AppBar(
              title: const Text('Formulas'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.import_export),
                  tooltip: 'Import formulas',
                  onPressed: _handleImport,
                ),
              ],
            ),
            body: FormulaList(
              corpus: snapshot.data!,
              onImport: _handleImport,
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

/// Attempts to load corpus from database first, falls back to default corpus if database is empty
Future<Corpus> loadCorpusFromDatabaseOrAssets() async {
  final database = getDatabase();
  
  try {
    // Try to load from database first
    final dbElements = await database.loadCorpusElements();
    
    if (dbElements.isEmpty) {
      // Database is empty, load default corpus and save to database
      final defaultCorpus = await createDefaultCorpus();
      
      // Convert corpus to elements and save to database
      final elements = <models.FormulaElement>[];
      elements.addAll(defaultCorpus.allUnits().cast<models.FormulaElement>());
      elements.addAll(defaultCorpus.getFormulas().cast<models.FormulaElement>());
      
      await database.saveCorpusElements(elements);
      
      return defaultCorpus;
    } else {
      // Load corpus from database elements
      return await Corpus.fromDatabaseElements(dbElements);
    }
  } catch (e, st) {
    // If there's an error loading from database, fall back to default corpus
    errorHandler.notify(e,st);
    return await createDefaultCorpus();
  }
}

/// Shows a dialog to ask user if they want to use the default corpus
Future<bool> showUseDefaultCorpusDialog(BuildContext context) async {
  return await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Empty Database'),
        content: const Text('The database is empty. Would you like to load the default corpus?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Don't use default corpus
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // Use default corpus
            child: const Text('Yes'),
          ),
        ],
      );
    },
  ) ?? false; // Default to false if dialog is dismissed
}


