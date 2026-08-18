import 'formula_models.dart';

class CalculatorState {
  final Map<int, String> _inputs = {};
  final Map<int, Number> _answers = {};

  Map<int, String> get inputs => Map.unmodifiable(_inputs);
  Map<int, Number> get answers => Map.unmodifiable(_answers);

  int get maxIndex {
    if (_inputs.isEmpty) return 0;
    return _inputs.keys.reduce((a, b) => a > b ? a : b);
  }

  void setInput(int index, String value) {
    _inputs[index] = value;
  }

  void removeInput(int index) {
    _inputs.remove(index);
  }

  void setAnswer(int index, Number value) {
    _answers[index] = value;
  }

  void removeAnswer(int index) {
    _answers.remove(index);
  }

  void clear() {
    _inputs.clear();
    _answers.clear();
  }

  String? generateAnsDeclarations() {
    if (_answers.isEmpty) return null;

    final buffer = StringBuffer();

    // Declare individual ansN variables (sorted by index)
    final sortedIndices = _answers.keys.toList()..sort();
    for (final index in sortedIndices) {
      final value = _answers[index];
      buffer.writeln('final ans$index = $value;');
    }

    // Declare ans[] array with all answer values
    final ansValues = sortedIndices.map((i) => _answers[i]).toList();
    buffer.writeln('final ans = <dynamic>[${ansValues.join(', ')}];');

    return buffer.toString();
  }
}
