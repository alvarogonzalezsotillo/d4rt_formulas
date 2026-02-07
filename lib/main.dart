import 'package:flutter/material.dart';
import 'database/database_service.dart';

import 'ai/formula_list.dart';
import 'corpus.dart';
import 'defaults/default_corpus.dart';

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
      home: FutureBuilder<Corpus>(
        future: createDefaultCorpus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(child: Text('Error loading units: ${snapshot.error}'));
            }
            return Scaffold(
              appBar: AppBar(title: const Text('Formulas')),
              body: FormulaList(
                corpus: snapshot.data!,
                formulas: snapshot.data!.getFormulas(),
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}


