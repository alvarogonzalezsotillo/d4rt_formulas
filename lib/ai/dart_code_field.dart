import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:highlight/highlight.dart';
import 'package:highlight/languages/dart.dart';

class DartCodeController extends CodeController {
  static final aditionalKeywords = [
    "acos",
    "asin",
    "atan",
    "atan2",
    "cos",
    "e",
    "exp",
    "log",
    "max",
    "min",
    "pi",
    "pow",
    "sin",
    "sqrt",
    "sqrt2",
    "tan",
  ];
  DartCodeController({super.text}) : super(language: dart) {
    autocompleter.setCustomWords(aditionalKeywords);
  }
}

/// A [CodeField] with a monospace font whose syntax highlighting theme
/// follows the system brightness: dark theme in dark mode, light theme in
/// light mode.
class DartCodeField extends StatelessWidget {
  final DartCodeController controller;

  const DartCodeField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final codeField = CodeField(
      controller: controller,
      textStyle: const TextStyle(fontFamily: 'monospace', fontFamilyFallback: ["monospace", "Liberation Mono", "Roboto mono", "Courier New", "Courier", "Consolas", "Menlo"]),
    );
    return CodeTheme(
      data: CodeThemeData(styles: isDark ? monokaiSublimeTheme : githubTheme),
      child: SingleChildScrollView(child: codeField),
    );
  }
}
