import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../formula_evaluator.dart';

class D4rtEditingValidator {
  static (FormulaResult?, Object?) validateAsD4rtExpression(String text) {
    try {
      if (text.trim().isEmpty) {
        return (null, null);
      }
      return (FormulaEvaluator.evaluateExpression(text), null);
    } catch (e, s) {
      return (null, e);
    }
  }

  static (FormulaResult?, Object?) validateAsStringExpression(String text) {
    try {
      return (FormulaEvaluator.evaluateExpression('"$text"'), null);
    } catch (_) {
      return (FormulaEvaluator.evaluateExpression("'$text'"), null);
    }
  }
}


// other option: DartCodeField
class D4rtEditingTextField extends TextFormField {
  D4rtEditingTextField({super.controller, super.validator})
    : super(
        keyboardType: TextInputType.multiline,
        inputFormatters: [
          //FilteringTextInputFormatter.allow(RegExp(r'[0-9\.\-]')),
        ],
        decoration: const InputDecoration(border: UnderlineInputBorder()),
        autovalidateMode: AutovalidateMode.always,
      );
}

// other option: DartCodeController
class D4rtEditingController extends TextEditingController {
  String? _lastError;
  String? get lastError => _lastError;
  FormulaResult? _lastValue;
  FormulaResult? get d4rtValue => _lastError == null ? _lastValue : null;

  final bool isString;

  D4rtEditingController({super.text, this.isString = false});

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

//// End of D4rtEditingController class ////
