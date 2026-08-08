import 'package:d4rt_formulas/compile_constants.dart';
import 'package:d4rt_formulas/corpus.dart';
import 'package:d4rt_formulas/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    await CompileConstants.init();
  });

  testWidgets('About button shows CompileConstants information', (tester) async {
    await tester.pumpWidget(MyApp(Future.value(Corpus())));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.info_outline));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(
      find.text('Release: ${CompileConstants.release()}'),
      findsOneWidget,
    );
    expect(
      find.text('Build timestamp: ${CompileConstants.buildTimestamp()}'),
      findsOneWidget,
    );
    expect(
      find.text('Build host: ${CompileConstants.buildHost()}'),
      findsOneWidget,
    );
  });
}
