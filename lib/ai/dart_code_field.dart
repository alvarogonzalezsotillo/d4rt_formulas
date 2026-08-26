import 'package:d4rt_formulas/ai/d4rt_editing_controller.dart';
import 'package:d4rt_formulas/d4rt_formulas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:highlight/highlight.dart';
import 'package:highlight/languages/dart.dart';


// older option: D4rtEditingController
class DartCodeController extends CodeController {
  static final defaultAditionalKeywords = ["acos(", "asin(", "atan(", "atan2(", "cos(", "e", "exp(", "log(", "max(", "min(", "pi", "pow(", "sin(", "sqrt(", "sqrt2(", "tan("];
  DartCodeController({super.text, this.isString = false, List<String> aditionalKeywords = const []}) : super(language: dart) {
    autocompleter.setCustomWords(defaultAditionalKeywords + aditionalKeywords);
  }

  String? _lastError;
  String? get lastError => _lastError;
  FormulaResult? _lastValue;
  FormulaResult? get d4rtValue => _lastError == null ? _lastValue : null;

  final bool isString;

  bool validate() {
    if (!isString) {
      final (value, error) = D4rtEditingValidator.validateAsD4rtExpression(text);
      _setValue(value, error);
      return value != null;
    } else {
      final (value, error) = D4rtEditingValidator.validateAsStringExpression(text);
      _setValue(value, error);
      return value != null;
    }
  }

  void _setValue(FormulaResult? value, Object? error) {
    _lastValue = value;
    _lastError = error?.toString();
  }

  @override
  set text(String newText) {
    super.text = newText;
    validate();
  }

  @override
  void notifyListeners() {
    validate();
    super.notifyListeners();
  }
}

// older option: D4rtEditingTextField
class DartCodeField extends StatefulWidget {

  final DartCodeController controller;

  final bool showLineNumbers;

  final String? Function(String?)? validator;

  const DartCodeField({super.key, required this.controller, this.validator, this.showLineNumbers = false});

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
    if (widget.validator != null) {
      print("DART validate");
      setState(_runValidator);
    }
  }

  void _runValidator() {
    final validator = widget.validator;
    _errorText = validator == null ? null : validator(widget.controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gutterStyle = widget.showLineNumbers ? GutterStyle(showLineNumbers: true) : GutterStyle.none;
    final codeField = CodeField(
      controller: widget.controller,
      decoration: BoxDecoration(border: Border.all()),
      gutterStyle: gutterStyle,
      textStyle: const TextStyle(fontFamily: 'RobotoMono', fontFamilyFallback: ["monospace", "Liberation Mono", "Roboto mono", "Courier New", "Courier", "Consolas", "Menlo"]),
    );
    return CodeTheme(
      data: CodeThemeData(styles: isDark ? monokaiSublimeTheme : githubTheme),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(child: codeField),
          //Divider(),
          if (_errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                _errorText!,
                key: _errorKey,
                style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}
