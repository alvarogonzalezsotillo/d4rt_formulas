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
    return _escapePrettyPrintString(input);
  }

  /// Escapes a string for use inside a regular double-quoted Dart literal.
  static String _escapePrettyPrintString(String s) {
    return s.replaceAll(r'\', r'\\').replaceAll(r'$', r'\$').replaceAll('"', r'\"').replaceAll('\n', r'\n').replaceAll('\r', r'\r').replaceAll('\t', r'\t');
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
        } else if (element.containsKey('name') && element.containsKey('symbol')) {
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
    if (value is String) {
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
    final needsRawString = s.contains('\n') || s.contains('\r') || s.contains(r'$') || s.contains(r'\') || s.contains('"');

    if (needsRawString) {
      final raw = _prettyPrintRawString(s);
      if (raw != null) {
        return raw;
      }
    }

    // Simple string with escapes
    return '"${_escapePrettyPrintString(s)}"';
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

    final entries = m.entries
        .map((e) {
          final key = prettyPrint(e.key, indent: indent + 1);
          final value = prettyPrint(e.value, indent: indent + 1);
          return '$innerIndent$key: $value';
        })
        .join(',\n');

    return '{\n$entries\n$indentStr}';
  }

  /// Pretty prints a raw string (for strings containing newlines, $, backslashes, etc.)
  /// Uses Dart's raw string syntax r"""...""" or r'''...''' when the content can be
  /// represented losslessly. Returns null when it cannot, so the caller falls back
  /// to an escaped string literal.
  static String? _prettyPrintRawString(String s) {
    // d4rt normalizes raw string line endings, so \r must be escaped instead.
    if (s.contains('\r')) {
      return null;
    }
    // A trailing backslash right before the closing delimiter is ambiguous.
    if (s.endsWith(r'\')) {
      return null;
    }
    if (_rawCompatible(s, '"""')) {
      return 'r"""$s"""';
    }
    if (_rawCompatible(s, "'''")) {
      return "r'''$s'''";
    }
    return null;
  }

  /// Whether [s] can be used verbatim inside the raw triple-quoted literal
  /// delimited by [delimiter]: the delimiter must not occur in the content and
  /// no [delimiter[0]] quote may abut the delimiter at the edges.
  static bool _rawCompatible(String s, String delimiter) {
    final quote = delimiter[0];
    return !s.contains(delimiter) && !s.startsWith(quote) && !s.endsWith(quote);
  }
}
