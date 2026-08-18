import 'package:test/test.dart';
import 'package:get_it/get_it.dart';
import 'package:d4rt_formulas/calculator_state.dart';

void main() {
  group('CalculatorState', () {
    late CalculatorState state;

    setUp(() {
      // Reset GetIt for each test
      if (GetIt.instance.isRegistered<CalculatorState>()) {
        GetIt.instance.unregister<CalculatorState>();
      }
      state = CalculatorState();
      GetIt.instance.registerSingleton<CalculatorState>(state);
    });

    tearDown(() {
      GetIt.instance.unregister<CalculatorState>();
    });

    test('initially empty', () {
      expect(state.inputs, isEmpty);
      expect(state.answers, isEmpty);
      expect(state.maxIndex, 0);
    });

    test('setInput and getInput', () {
      state.setInput(1, '1 + 2');
      expect(state.inputs[1], '1 + 2');
      expect(state.inputs.length, 1);
    });

    test('setAnswer and getAnswer', () {
      state.setAnswer(1, 3.0);
      expect(state.answers[1], 3.0);
      expect(state.answers.length, 1);
    });

    test('removeInput', () {
      state.setInput(1, '1 + 2');
      state.removeInput(1);
      expect(state.inputs, isEmpty);
    });

    test('removeAnswer', () {
      state.setAnswer(1, 3.0);
      state.removeAnswer(1);
      expect(state.answers, isEmpty);
    });

    test('maxIndex returns highest index', () {
      state.setInput(1, '1');
      state.setInput(5, '5');
      state.setInput(3, '3');
      expect(state.maxIndex, 5);
    });

    test('clear removes all data', () {
      state.setInput(1, '1 + 2');
      state.setAnswer(1, 3.0);
      state.setInput(2, '4 + 5');
      state.setAnswer(2, 9.0);
      state.clear();
      expect(state.inputs, isEmpty);
      expect(state.answers, isEmpty);
    });

    test('generateAnsDeclarations returns null when empty', () {
      expect(state.generateAnsDeclarations(), isNull);
    });

    test('generateAnsDeclarations generates correct code', () {
      state.setAnswer(1, 3.0);
      state.setAnswer(2, 9.0);
      final declarations = state.generateAnsDeclarations();
      expect(declarations, isNotNull);
      expect(declarations, contains('final ans1 = 3.0;'));
      expect(declarations, contains('final ans2 = 9.0;'));
      expect(declarations, contains('final ans = <dynamic>[3.0, 9.0];'));
    });

    test('generateAnsDeclarations sorts by index', () {
      state.setAnswer(3, 30.0);
      state.setAnswer(1, 10.0);
      state.setAnswer(2, 20.0);
      final declarations = state.generateAnsDeclarations();
      expect(declarations, contains('final ans1 = 10.0;'));
      expect(declarations, contains('final ans2 = 20.0;'));
      expect(declarations, contains('final ans3 = 30.0;'));
      expect(declarations, contains('final ans = <dynamic>[10.0, 20.0, 30.0];'));
    });

    test('registers in GetIt', () {
      final retrieved = GetIt.instance<CalculatorState>();
      expect(identical(retrieved, state), isTrue);
    });
  });
}
