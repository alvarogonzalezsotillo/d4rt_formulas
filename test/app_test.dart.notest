import 'dart:async';
import 'dart:math';

import 'package:d4rt_formulas/defaults/default_corpus.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:d4rt_formulas/main.dart';
import 'package:d4rt_formulas/corpus.dart';
import 'package:d4rt_formulas/formula_models.dart';
import 'package:d4rt_formulas/database/database_service.dart';
import 'package:d4rt_formulas/service_locator.dart';
import 'package:get_it/get_it.dart';
import 'package:d4rt_formulas/set_utils.dart';
import 'package:d4rt_formulas/database/formulas_database.dart';
import 'package:d4rt_formulas/ai/import_from_text_screen.dart';
import 'package:d4rt_formulas/ai/import_preview_screen.dart';

void main() {

  setUpAll(() {
    // Ensure the database is initialized once for all tests
    setupLocator();
  });

  testWidgets('selects first formula and opens editor from AppBar', (WidgetTester tester) async {
    // Reset GetIt to allow fresh corpus registration
    if (GetIt.instance.isRegistered<Corpus>()) {
      GetIt.instance.unregister<Corpus>();
    }
    GetIt.instance.unregister<FormulasDatabase>();
    setupLocator();
    
    // Build the app
    var corpus = await createDefaultCorpus();
    var corpusCompleter = Completer<Corpus>();
    corpusCompleter.complete(corpus);
    var app = MyApp(corpusCompleter.future);
    await tester.pumpWidget(app);
    await tester.pump();
    await tester.pumpAndSettle(const Duration(seconds: 10));

    // Verify FormulaList is shown
    expect(find.byType(ListView), findsOneWidget);

    // Find and tap the first formula in the list
    final formulaTile = find.byType(ListTile).first;
    expect(formulaTile, findsOneWidget);
    await tester.tap(formulaTile);
    await tester.pumpAndSettle();


    // Find and tap the edit icon in the AppBar
    final editIcon = find.byIcon(Icons.edit);
    expect(editIcon, findsOneWidget);
    await tester.tap(editIcon);
    await tester.pumpAndSettle();

    // Verify FormulaEditor is shown
    expect(find.text('Edit Formula'), findsOneWidget);
  });

  testWidgets('share first formula to clipboard and import it', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;

    try {
      // Reset GetIt to allow fresh corpus registration
      if (GetIt.instance.isRegistered<Corpus>()) {
        GetIt.instance.unregister<Corpus>();
      }
      GetIt.instance.unregister<FormulasDatabase>();
      setupLocator();
      
      print('DEBUG: Building app...');
      var corpus = await createDefaultCorpus();
      var corpusCompleter = Completer<Corpus>();
      corpusCompleter.complete(corpus);
      var app = MyApp(corpusCompleter.future);
      await tester.pumpWidget(app);
      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 10));
      print('DEBUG: App built and settled');

      final firstFormulaTile = find.byType(ListTile).first;
      expect(firstFormulaTile, findsOneWidget);

      await tester.tap(firstFormulaTile);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      final shareButton = find.byIcon(Icons.share);

      await tester.tap(shareButton);
      await tester.pumpAndSettle();
      print('DEBUG: Tapped share button');

      await tester.tap(find.text('Copy to clipboard'));
      await tester.pump(const Duration(seconds: 1));
      print('DEBUG: Tapped copy to clipboard');

    } finally {
      tester.view.resetPhysicalSize();
    }
  });
}
