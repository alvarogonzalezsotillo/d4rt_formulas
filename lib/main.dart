import 'dart:convert';
import 'dart:io';

import 'package:d4rt_formulas/d4rt_formulas.dart';
import 'package:d4rt_formulas/database/formulas_database.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:url_launcher/link.dart' show FollowLink, Link;

import 'ai/calculator_tab.dart';
import 'ai/formula_list.dart';
import 'ai/import_from_text_screen.dart';
import 'ai/unit_list.dart';
import 'corpus.dart';
import 'database/database_service.dart';
import 'defaults/default_corpus.dart';
import 'error_handler.dart';
import 'formula_models.dart' as models;
import 'service_locator.dart';
import 'compile_constants.dart';
import 'variables.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup service locator and initialize the database
  setupLocator();

  await CompileConstants.init();
  print( "release: ${CompileConstants.release()}" );
  print( "build timestamp: ${CompileConstants.buildTimestamp()}" );
  print( "build host: ${CompileConstants.buildHost()}" );

  var corpusFuture = loadCorpusFromDatabaseOrAssets();

  await loadGlobalVariablesFromDatabase();

  runApp( MyApp(corpusFuture));
}

final GlobalKey<_CorpusLoaderState> corpusLoaderKey = GlobalKey<_CorpusLoaderState>();

class MyApp extends StatelessWidget {
  final Future<Corpus> corpusFuture;
  MyApp(this.corpusFuture, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.transparent,
            brightness: MediaQuery.platformBrightnessOf(context)
        ),
      ),
      home: CorpusLoader(corpusFuture),
    );
  }
}

class CorpusLoader extends StatefulWidget {
  final Future<Corpus> corpusFuture;
  CorpusLoader(this.corpusFuture, {Key? key}) : super(key: corpusLoaderKey);

  @override
  State<CorpusLoader> createState() => _CorpusLoaderState();
}

class _CorpusLoaderState extends State<CorpusLoader> {
  late Future<Corpus> _corpusFuture;

  @override
  void initState() {
    super.initState();
    _corpusFuture = widget.corpusFuture;
  }

  void _handleAbout() {
    final corpus = GetIt.instance.get<Corpus>();
    final aboutInfo = [
      ['Home page', CompileConstants.homePage()],
      ['Release', CompileConstants.release()],
      ['Build timestamp', CompileConstants.buildTimestamp()],
      ['Build host', CompileConstants.buildHost()],
      ['Corpus backend', CompileConstants.isDatabaseBackend() ? FormulasDatabase.underlyingStorage() : "Memory"],
      ['# of formulas', corpus.getFormulas().length ],
      ['# of units', corpus.getUnits().length ],
      
    ];

    final defaultFontSize = Theme.of(context) .textTheme .bodyMedium ?.fontSize ?? 14;
    final smallFontSize = defaultFontSize - 2;

    Widget toCell(int column, String s ){
      final text = Text(
            s,
            style: TextStyle(fontSize: (column == 0 ? defaultFontSize: smallFontSize) )
          );

      final uri = Uri.tryParse(s);
      if( uri != null && uri.hasScheme ){
        return Link(
          uri: uri,
          builder: (BuildContext context, FollowLink? followLink) => InkWell(
            onTap: followLink,
            child: text,
          ),
        );
      }
      return text;
    }
    
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('About'),
          content: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Table(
              border: TableBorder(
                top: BorderSide(color: Colors.grey.shade300),
                bottom: BorderSide(color: Colors.grey.shade300),
                horizontalInside: BorderSide(color: Colors.grey.shade300),
              ),
              columnWidths: {
                0: IntrinsicColumnWidth(),
                1: FlexColumnWidth(),
              },
              children: aboutInfo.map<TableRow>((row) {
                return TableRow(
                  children: row.indexed.map<Padding>( ((int, Object) entry) {
                    final (int index, Object cellO) = entry;
                    final cell = cellO.toString();
                    return Padding(
                      padding: const EdgeInsets.all(2),
                      child: toCell(index, cell),
                    );
                  }).toList(),
                );
              }).toList() 
           ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],

        );
      },
    );
  }

  void _handleCalculator(){
    final calculator =  MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('Calculator')),
        body: CalculatorTab(),
      )
    );

    Navigator.push(context, calculator);
  }
  
  void _handleImport() {
    _corpusFuture.then((corpus) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ImportFromTextScreen(
                corpus: corpus,
              ),
        ),
      ).then((result) {
        setState(() {
          // Refresh the list when returning from import
        });
      });
    });
  }

  static Widget _iconButton( IconData icon, String text, VoidCallback? cb ){
    return TextButton(
      onPressed: cb,
      child: Column(
        children: [SizedBox(height: 8), Icon(icon), Text(text, maxLines: null) ], 
      ),
    );
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
          _registerCorpusInstance(corpus);

          return DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: AppBar(
                title: const Text('D4rt Formulas'),
                bottom: const TabBar(
                  tabs: [
                    Tab(text: 'Formulas'),
                    Tab(text: 'Units'),
                  ],
                ),
                actions: [
                  _iconButton(Icons.calculate_outlined, "Calculator",_handleCalculator ),
                  _iconButton(Icons.library_add, "Import text", _handleImport ),
                  _iconButton(Icons.info_outlined, "About",_handleAbout ),
                ],
              ),
              body: TabBarView(
                children: [
                  FormulaList(
                    corpus: snapshot.data!,
                    onImport: _handleImport,
                  ),
                  UnitList(
                    corpus: snapshot.data!,
                    onImport: _handleImport,
                  ),
                ],
              ),
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  void _registerCorpusInstance(Corpus corpus) {
    var existingCorpus = GetIt.instance.isRegistered<Corpus>() ? GetIt.instance.get<Corpus>() : null;
    if (existingCorpus == null ) {
      print( "Registering corpus in GetIt for the first time." );
      GetIt.instance.registerSingleton<Corpus>(corpus);
    }
    else if( existingCorpus == corpus ){
      print( "The corpus was already registered and is the same instance, no need to re-register." );
    }
    else if( existingCorpus != corpus ){
      throw Exception( "The corpus was already registered but is a different instance. This should not happen." );
    }
  }
}

Future<Corpus> loadCorpusFromDatabaseOrAssets() async {
  final useDatabase = CompileConstants.isDatabaseBackend();
  if (!useDatabase) {
    return createDefaultCorpus();
  }

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
      final corpus = Corpus();
      corpus.loadFormulaElements(dbElements, true);
      return corpus;
    }
  } catch (e, st) {
    // If there's an error loading from database, fall back to default corpus
    errorHandler.notify(e,st);
    return createDefaultCorpus();
  }
}

Future<void> loadGlobalVariablesFromDatabase() async {
  if (!CompileConstants.isDatabaseBackend()) return;
  final database = getDatabase();
  try {
    final data = await database.loadGlobalVariables();
    final globals = GetIt.instance<GlobalVariables>();
    globals.loadFromMap(data);
    globals.enablePersistence((map) async {
      await database.saveAllGlobalVariables(map);
    });
  } catch (e, st) {
    errorHandler.notify(e, st);
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


