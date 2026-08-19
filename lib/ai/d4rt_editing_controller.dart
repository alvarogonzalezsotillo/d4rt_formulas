
import 'package:flutter/cupertino.dart';

import '../formula_evaluator.dart';

class D4rtEditingController extends TextEditingController {
  String? _lastError;
  String? get lastError => _lastError;
  FormulaResult? _lastValue;
  final bool isString;

  D4rtEditingController({super.text, this.isString = false});

  bool validate() {
    if( !isString && _validateAsNumberExpression(text) ){
      return true;
    }
    if( isString && _validateAsStringExpression(text) ){
      return true;
    }
    return false;
  }

  bool _validateAsNumberExpression(String text){
    return _validateAsD4rtExpression(text) && _lastValue is NumberResult;
  }

  bool _validateAsD4rtExpression(String text){
    try {
      _lastValue = null;
      if( text.trim().isEmpty ){
        return true;
      }
      _lastValue = FormulaEvaluator.evaluateExpression(text);
      _lastError = null;
      return true;
    } catch (e, s) {
      //errorHandler.notify(e, s);
      _lastError = e.toString();
      _lastValue = null;
      return false;
    }
  }

  bool _validateAsStringExpression(String text){
    if( _validateAsD4rtExpression(text) && _lastValue is StringResult ){
      return true;
    }
    if( _validateAsD4rtExpression('"$text"') && _lastValue is StringResult ){
      return true;
    }
    if( _validateAsD4rtExpression("'$text'") && _lastValue is StringResult ){
      return true;
    }
    return false;
  }


  FormulaResult? get d4rtValue => _lastError == null ? _lastValue : null;

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
