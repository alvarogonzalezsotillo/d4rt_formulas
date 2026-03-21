
import 'package:d4rt/d4rt.dart';

import 'formula_models.dart';

abstract class SetUtils {
  static Object safeGet(Map<Object?, Object?> map, String key) {
    if (!map.containsKey(key)) {
      throw ArgumentError("Key not found: $key -- $map");
    }
    return map[key] ?? "Not possible!!!";
  }

  static String stringValue(Map<Object?, Object?> map, String key) {
    return safeGet(map, key).toString();
  }

  static List<Object?> listValue(Map<Object?, Object?> map, String key) {
    return safeGet(map, key) as List<Object?>;
  }

  static Number numberValue(Map<Object?, Object?> map, String key) {
    return double.parse(stringValue(map, key));
  }

  /// Parses a d4rt array literal (containing maps and arrays) to a List<Object?>
  /// using d4rt
  static List<Object?> parseD4rtLiteral(String arrayStringLiteral) {
    var d4rt = D4rt();
    final buffer = StringBuffer();
    buffer.write("main(){ return $arrayStringLiteral; }");
    final code = buffer.toString();

    final List<Object?> list = d4rt.execute(source: code);

    return list;
  }

  /// Escapes special characters in a string for use in D4RT literals
  static String escapeD4rtString(String input) {
    return input
        .replaceAll(r'\\', r'\\\\') // escape backslashes first
        .replaceAll('\n', r'\\n')
        .replaceAll('\r', r'\\r')
        .replaceAll('\t', r'\\t')
        .replaceAll('"', r'\"');
  }

  /// Parses corpus elements from an array string literal.
  /// Determines if each element is a formula or a unit and converts accordingly.
  static List<FormulaElement> parseCorpusElements(String arrayStringLiteral) {
    final List<Object?> elements = parseD4rtLiteral(arrayStringLiteral);

    final List<FormulaElement> result = [];
    for (final element in elements) {
      if (element is Map<Object?, Object?>) {
        if (element.containsKey('d4rtCode')) {
          result.add(Formula.fromSet(element));
        } else
        if (element.containsKey('name') && element.containsKey('symbol')) {
          result.add(UnitSpec.fromSet(element));
        } else {
          throw ArgumentError('Unknown element type: $element');
        }
      } else {
        throw ArgumentError('Element must be a Map: $element');
      }
    }

    return result;
  }

  /// Pretty prints a dynamic value (Set, Array, string or number) as a Dart literal.
  /// Uses JSON-like formatting but for Dart language, with proper indentation.
  static String prettyPrint(dynamic value, {int indent = 0}) {
    if (value   is String) {
      return _prettyPrintString(value);
    } else if (value is num) {
      return _prettyPrintNumber(value);
    } else if (value is Set) {
      return _prettyPrintSet(value, indent);
    } else if (value is List) {
      return _prettyPrintArray(value, indent);
    } else if (value is Map) {
      return _prettyPrintMap(value, indent);
    } else {
      return value.toString();
    }
  }

  /// Pretty prints a simple string, escaping special characters if needed.
  static String _prettyPrintString(String s) {
    // Check if the string needs raw string formatting (newlines, $, backslashes, quotes)
    final needsRawString = s.contains('\n') ||
        s.contains(r'$') ||
        s.contains(r'\\') ||
        s.contains('"');

    if (needsRawString && s != '"' ) {
      return _prettyPrintRawString(s);
    }

    // Simple string with escaped quotes
    return '"${s.replaceAll('"', r'\"')}"';
    //'
  }

  /// Pretty prints a number.
  static String _prettyPrintNumber(num n) {
    return n.toString();
  }

  /// Pretty prints a Set as a Dart set literal.
  static String _prettyPrintSet(Set s, int indent) {
    if (s.isEmpty) {
      return '{}';
    }

    final indentStr = '  ' * indent;
    final innerIndent = '  ' * (indent + 1);

    final elements = s.map((e) => '$innerIndent${prettyPrint(e, indent: indent + 1)}').join(',\n');
    return '{$elements\n$indentStr}';
  }

  /// Pretty prints an Array/List as a Dart list literal.
  static String _prettyPrintArray(List a, int indent) {
    if (a.isEmpty) {
      return '[]';
    }

    final indentStr = '  ' * indent;
    final innerIndent = '  ' * (indent + 1);

    final elements = a.map((e) => '$innerIndent${prettyPrint(e, indent: indent + 1)}').join(',\n');
    return '[\n$elements\n$indentStr]';
  }

  /// Pretty prints a Map as a Dart map literal.
  static String _prettyPrintMap(Map m, int indent) {
    if (m.isEmpty) {
      return '{}';
    }

    final indentStr = '  ' * indent;
    final innerIndent = '  ' * (indent + 1);

    final entries = m.entries.map((e) {
      final key = prettyPrint(e.key, indent: indent + 1);
      final value = prettyPrint(e.value, indent: indent + 1);
      return '$innerIndent$key: $value';
    }).join(',\n');

    return '{\n$entries\n$indentStr}';
  }

  /// Pretty prints a raw string (for strings containing newlines, $, backslashes, etc.)
  /// Uses Dart's raw string syntax r"""..."""
  static String _prettyPrintRawString(String s) {
    if( s == '"'){
      return "'\"";
    }
    if( s.contains('"""') && s.contains("'''") ){
      return escapeD4rtString(s);
    }
    if( s.contains('"""') ){
      return "r'''$s'''";
    }
    return 'r"""$s"""';
  }
}