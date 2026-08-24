import 'package:d4rt_formulas/ai/dart_code_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// CodeController schedules a code analysis debounce timer (500ms) on every
/// text change. Advancing fake time past it keeps the test binding invariant
/// about pending timers happy.
Future<void> settle(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.pump(const Duration(seconds: 1));
  await tester.pumpAndSettle();
}

void main() {
  Widget buildField(DartCodeController controller,
      {String? Function(String?)? validator}) {
    return MaterialApp(
      home: Scaffold(
        body: DartCodeField(controller: controller, validator: validator),
      ),
    );
  }

final errorFinder = find.byKey(const ValueKey('DartCodeFieldError'));

  group('DartCodeField validator', () {
    testWidgets('shows no message when no validator is provided',
        (tester) async {
      final controller = DartCodeController(text: '1 + 1');
      await tester.pumpWidget(buildField(controller));
      await settle(tester);

      expect(errorFinder, findsNothing);
    });

    testWidgets('shows no message when validator returns null',
        (tester) async {
      final controller = DartCodeController(text: '1 + 1');
      await tester.pumpWidget(buildField(controller,
          validator: (text) => text == null || text.isEmpty ? 'empty' : null));
      await settle(tester);

      expect(errorFinder, findsNothing);
    });

    testWidgets('shows message when initial text is invalid', (tester) async {
      final controller = DartCodeController(text: '');
      await tester.pumpWidget(buildField(controller,
          validator: (text) => text == null || text.isEmpty ? 'empty' : null));
      await settle(tester);

      expect(errorFinder, findsOneWidget);
      expect(tester.widget<Text>(errorFinder).data, 'empty');
    });

    testWidgets('shows message when text becomes invalid and hides it when '
        'valid again', (tester) async {
      final controller = DartCodeController(text: '1 + 1');
      await tester.pumpWidget(buildField(controller,
          validator: (text) => text == null || text.isEmpty ? 'empty' : null));
      await settle(tester);
      expect(errorFinder, findsNothing);

      controller.text = '';
      await settle(tester);
      expect(errorFinder, findsOneWidget);
      expect(tester.widget<Text>(errorFinder).data, 'empty');

      controller.text = '2 + 2';
      await settle(tester);
      expect(errorFinder, findsNothing);
    });

    testWidgets('message updates when the error changes', (tester) async {
      final controller = DartCodeController(text: '');
      await tester.pumpWidget(buildField(controller,
          validator: (text) => text == null || text.isEmpty ? 'empty' : 'bad'));
      await settle(tester);
      expect(tester.widget<Text>(errorFinder).data, 'empty');

      controller.text = 'not empty but bad';
      await settle(tester);
      expect(tester.widget<Text>(errorFinder).data, 'bad');
    });

    testWidgets('revalidates with the new validator on widget update',
        (tester) async {
      final controller = DartCodeController(text: 'abc');
      await tester.pumpWidget(buildField(controller,
          validator: (text) => text!.contains('z') ? 'no z allowed' : null));
      await settle(tester);
      expect(errorFinder, findsNothing);

      await tester.pumpWidget(buildField(controller,
          validator: (text) =>
              text != null && RegExp(r'^[0-9+ ]+$').hasMatch(text)
                  ? null
                  : 'not a number'));
      await settle(tester);
      expect(errorFinder, findsOneWidget);
      expect(tester.widget<Text>(errorFinder).data, 'not a number');
    });

    testWidgets('validator receives the current controller text',
        (tester) async {
      var received = 'sentinel';
      final controller = DartCodeController(text: 'hello');
      await tester.pumpWidget(buildField(controller, validator: (text) {
        received = text!;
        return null;
      }));
      await settle(tester);

      expect(received, 'hello');
    });
  });
}
