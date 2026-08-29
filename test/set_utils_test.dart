import 'package:d4rt/d4rt.dart';
import 'package:d4rt_formulas/set_utils.dart';
import 'package:flutter_test/flutter_test.dart';

/// Evaluates [literal] as a d4rt expression and returns the produced value,
/// verifying that [literal] is a valid standalone Dart/d4rt string literal.
Object? evalLiteral(String literal) {
  return D4rt().execute(source: 'main(){ return $literal; }');
}

void main() {
  group('SetUtils.prettyPrint strings', () {
    /// Every case must produce a valid Dart literal whose evaluation
    /// yields exactly the original string.
    const roundTripCases = <String, String>{
      'simple word': 'hello',
      'sentence': 'hello world, this is a sentence',
      'empty': '',
      'padded spaces': '  padded  ',
      'single quotes': "it's",
      'double quotes': 'say "hi"',
      'lone double quote': '"',
      'leading double quotes': '"quoted"',
      'trailing double quote': 'end"',
      'multiline': 'line1\nline2',
      'crlf': 'line1\r\nline2',
      'carriage return': 'a\rb',
      'tab': 'a\tb',
      'dollar sign': 'cost is \$100',
      'interpolation-like': '\${x} + \$y',
      'windows path': r'C:\Users\test',
      'trailing backslash': r'trailing\',
      'double backslashes': r'a\\b',
      'backslash before quote': r'weird \" case',
      'triple double quotes': 'has """ inside',
      'one double quote': '"',
      'triple single quotes': "has ''' inside",
      'only triple single quotes': "it'''s",
      'both triple quotes': 'has """ and \'\'\' inside',
      'mixed everything': 'mix "q" \\ \n \$ tab\t end',
      'unicode': 'héllo wörld ★ 你好',
      'quote plus newline': 'a"\nb',
    };

    roundTripCases.forEach((name, input) {
      test("round trip: $name", () {
        final printed = SetUtils.prettyPrint(input);
        final result = evalLiteral(printed);
        expect(
          result,
          equals(input),
          reason:
              'prettyPrint($input) => $printed is not a valid '
              'Dart literal reproducing the original string',
        );
      });
    });

    test('simple string uses plain double quotes', () {
      expect(SetUtils.prettyPrint('hello'), '"hello"');
    });

    test('empty string', () {
      expect(SetUtils.prettyPrint(''), '""');
    });

    test('single quotes need no escaping inside double quotes', () {
      expect(SetUtils.prettyPrint("it's"), '"it\'s"');
    });

    test('dollar sign uses raw string', () {
      expect(SetUtils.prettyPrint(r'$100'), startsWith('r"""'));
    });

    test('newline uses raw string', () {
      expect(SetUtils.prettyPrint('a\nb'), startsWith('r"""'));
    });

    test('backslash uses raw string', () {
      expect(SetUtils.prettyPrint(r'a\b'), startsWith('r"""'));
    });

    test('triple double quotes switch to single-quote raw delimiter', () {
      expect(SetUtils.prettyPrint('has """ inside'), startsWith("r'''"));
    });

    test('unrepresentable raw content falls back to escaped string', () {
      final printed = SetUtils.prettyPrint('has """ and \'\'\' inside');
      expect(printed, startsWith('"'));
    });
  });

  group('SetUtils.prettyPrint other types', () {
    test('numbers', () {
      expect(SetUtils.prettyPrint(42), '42');
      expect(SetUtils.prettyPrint(1.5), '1.5');
    });

    test('empty list and set', () {
      expect(SetUtils.prettyPrint(<Object?>[]), '[]');
      expect(SetUtils.prettyPrint(<Object?>{}), '{}');
    });

    test('nested structures round trip', () {
      const tricky = 'a "b" \\ c\n\$d';
      final value = <Object?>[
        tricky,
        2,
        <String, Object?>{'key': tricky},
        <Object?>{1, 2},
      ];
      final printed = SetUtils.prettyPrint(value);
      final result = evalLiteral(printed);
      expect(
        result,
        equals(value),
        reason:
            'prettyPrint($value) => $printed is not a valid '
            'Dart literal reproducing the original value',
      );
    });
  });
}
