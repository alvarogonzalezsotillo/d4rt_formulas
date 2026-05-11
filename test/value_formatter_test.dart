import 'package:d4rt_formulas/corpus.dart';
import 'package:d4rt_formulas/defaults/default_corpus.dart';
import 'package:d4rt_formulas/formula_evaluator.dart';
import 'package:d4rt_formulas/value_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Format', () {
    test('1 is 1', () {
      var s = formatOutput(1.0);
      expect(s, "1.0");
    });
  });
}

