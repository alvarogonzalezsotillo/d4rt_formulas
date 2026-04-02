import 'dart:async';

import 'package:d4rt_formulas/defaults/default_corpus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:d4rt_formulas/main.dart';
import 'package:d4rt_formulas/corpus.dart';
import 'package:d4rt_formulas/formula_models.dart';
import 'package:d4rt_formulas/database/database_service.dart';
import 'package:d4rt_formulas/service_locator.dart';
import 'package:get_it/get_it.dart';

void main() {

  testWidgets('selects first formula and opens editor from AppBar', (WidgetTester tester) async {
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
}
