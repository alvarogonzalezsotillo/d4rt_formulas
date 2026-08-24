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
///
/// An optional [validator] can be provided, like [TextFormField.validator].
/// It is called with the current text whenever it changes (and on startup);
/// if it returns a non-null string, that message is shown below the field.
class DartCodeField extends StatefulWidget {
  final DartCodeController controller;
  final String? Function(String?)? validator;

  const DartCodeField({super.key, required this.controller, this.validator});

  @override
  State<DartCodeField> createState() => _DartCodeFieldState();
}

class _DartCodeFieldState extends State<DartCodeField> {
  static const _errorKey = ValueKey('DartCodeFieldError');
  String? _errorText;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_validate);
    _runValidator();
  }

  @override
  void didUpdateWidget(covariant DartCodeField oldWidget) {
    super.didUpdateWidget(oldWidget);
    var revalidate = false;
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_validate);
      widget.controller.addListener(_validate);
      revalidate = true;
    }
    if (oldWidget.validator != widget.validator) {
      revalidate = true;
    }
    if (revalidate) {
      _runValidator();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_validate);
    super.dispose();
  }

  void _validate() {
    setState(_runValidator);
  }

  void _runValidator() {
    final validator = widget.validator;
    _errorText = validator == null ? null : validator(widget.controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final codeField = CodeField(
      controller: widget.controller,
      textStyle: const TextStyle(
        fontFamily: 'monospace',
        fontFamilyFallback: ["monospace", "Liberation Mono", "Roboto mono", "Courier New", "Courier", "Consolas", "Menlo"]),
    );
    return CodeTheme(
      data: CodeThemeData(styles: isDark ? monokaiSublimeTheme : githubTheme),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(child: codeField),
          if (_errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                _errorText!,
                key: _errorKey,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
