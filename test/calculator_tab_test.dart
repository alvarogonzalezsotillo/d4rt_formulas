import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:d4rt_formulas/ai/calculator_tab.dart';

void main() {
  group('CalculatorTab', () {
    testWidgets('shows initial empty input with label input1',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CalculatorTab(),
          ),
        ),
      );

      expect(find.text('input1'), findsOneWidget);
      expect(find.text('ans1'), findsNothing);
    });

    testWidgets('shows output and next input when user types expression',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CalculatorTab(),
          ),
        ),
      );

      await tester.enterText(find.byKey(const Key('input1')), '1 + 2');
      await tester.pumpAndSettle();

      expect(find.text('ans1'), findsOneWidget);
      expect(find.text('input2'), findsOneWidget);
    });

    testWidgets('removes output when input becomes empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CalculatorTab(),
          ),
        ),
      );

      await tester.enterText(find.byKey(const Key('input1')), '1 + 2');
      await tester.pumpAndSettle();
      expect(find.text('ans1'), findsOneWidget);

      await tester.enterText(find.byKey(const Key('input1')), '');
      await tester.pumpAndSettle();
      expect(find.text('ans1'), findsNothing);
    });

    testWidgets('supports multiple inputs and outputs',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CalculatorTab(),
          ),
        ),
      );

      await tester.enterText(find.byKey(const Key('input1')), '10');
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('input2')), findsOneWidget);

      await tester.enterText(find.byKey(const Key('input2')), '20');
      await tester.pumpAndSettle();
      expect(find.text('ans2'), findsOneWidget);
      expect(find.byKey(const Key('input3')), findsOneWidget);
    });

    testWidgets('always keeps an empty input at the end',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CalculatorTab(),
          ),
        ),
      );

      await tester.enterText(find.byKey(const Key('input1')), '1');
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('input2')), findsOneWidget);

      await tester.enterText(find.byKey(const Key('input2')), '2');
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('input3')), findsOneWidget);

      await tester.enterText(find.byKey(const Key('input3')), '');
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('input4')), findsNothing);
    });
  });
}
