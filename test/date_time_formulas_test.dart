import 'package:d4rt_formulas/corpus.dart';
import 'package:d4rt_formulas/defaults/default_corpus.dart';
import 'package:d4rt_formulas/formula_evaluator.dart';
import 'package:flutter_test/flutter_test.dart';

String formatDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String expectedElapsed(DateTime from) {
  final to = DateTime.now();
  var years = to.year - from.year;
  var months = to.month - from.month;
  var days = to.day - from.day;
  if (days < 0) {
    months -= 1;
    days += DateTime(to.year, to.month, 0).day;
  }
  if (months < 0) {
    years -= 1;
    months += 12;
  }
  final parts = <String>[];
  if (years > 0) parts.add(years == 1 ? '1 year' : '$years years');
  if (months > 0) parts.add(months == 1 ? '1 month' : '$months months');
  if (days > 0) parts.add(days == 1 ? '1 day' : '$days days');
  if (parts.isEmpty) parts.add('0 days');
  return parts.join(', ');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<Corpus> testCorpus = createDefaultCorpus();

  group('Time elapsed since a date', () {
    test('evaluates elapsed years, months and days since a date', () async {
      final corpus = await testCorpus;
      final formula = corpus.getFormula("Time elapsed since a date")!;
      final evaluator = FormulaEvaluator();

      final from = DateTime(2000, 1, 15);
      final result = evaluator.evaluate(formula, {'date': formatDate(from)});

      expect(result, expectedElapsed(from));
    });

    test('returns a single unit without trailing comma', () async {
      final corpus = await testCorpus;
      final formula = corpus.getFormula("Time elapsed since a date")!;
      final evaluator = FormulaEvaluator();

      final now = DateTime.now();
      final from = DateTime(now.year - 3, now.month, 15);
      final result = evaluator.evaluate(formula, {'date': formatDate(from)});

      expect(result, expectedElapsed(from));
    });

    test('signals when the date is in the future', () async {
      final corpus = await testCorpus;
      final formula = corpus.getFormula("Time elapsed since a date")!;
      final evaluator = FormulaEvaluator();

      final futureDate = DateTime(DateTime.now().year + 1, 1, 1);
      final result = evaluator.evaluate(formula, {'date': formatDate(futureDate)});

      expect(result, 'The date must not be in the future');
    });

    test('signals on invalid date format', () async {
      final corpus = await testCorpus;
      final formula = corpus.getFormula("Time elapsed since a date")!;
      final evaluator = FormulaEvaluator();

      final result = evaluator.evaluate(formula, {'date': 'not-a-date'});

      expect(result, 'Invalid date format. Expected: YYYY-MM-DD');
    });
  });

  group('Age at end of current year', () {
    test('evaluates age at the end of the current year', () async {
      final corpus = await testCorpus;
      final formula = corpus.getFormula("Age at end of current year")!;
      final evaluator = FormulaEvaluator();

      final result = evaluator.evaluate(formula, {'birthdate': '1990-05-10'});

      expect(result, DateTime.now().year - 1990);
    });

    test('signals when birth date is in the future', () async {
      final corpus = await testCorpus;
      final formula = corpus.getFormula("Age at end of current year")!;
      final evaluator = FormulaEvaluator();

      final futureBirth = DateTime(DateTime.now().year + 1, 1, 1);
      final result = evaluator.evaluate(formula, {'birthdate': formatDate(futureBirth)});

      expect(result, 'Birth date must not be in the future');
    });

    test('signals on invalid birth date format', () async {
      final corpus = await testCorpus;
      final formula = corpus.getFormula("Age at end of current year")!;
      final evaluator = FormulaEvaluator();

      final result = evaluator.evaluate(formula, {'birthdate': 'invalid'});

      expect(result, 'Invalid birth date format. Expected: YYYY-MM-DD');
    });
  });
}
