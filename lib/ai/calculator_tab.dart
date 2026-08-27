import 'package:d4rt_formulas/ai/dart_code_field.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../calculator_state.dart';
import '../formula_evaluator.dart';
import '../value_formatter.dart';
import 'd4rt_editing_controller.dart';

class _CalculatorEntry {
  final int index;
  final List<String> aditionalKeywords;
  final DartCodeController inputController;
  final TextEditingController outputController = TextEditingController();

  // TODO: Update aditionalKeywords when adding or removing globalVariables
  _CalculatorEntry({required this.index, this.aditionalKeywords = const [] }): inputController = DartCodeController(aditionalKeywords: aditionalKeywords);
}

class CalculatorTab extends StatefulWidget {
  const CalculatorTab({super.key});

  @override
  State<CalculatorTab> createState() => _CalculatorTabState();
}

class _CalculatorTabState extends State<CalculatorTab> {
  final int maxEntries = 100;

  static const double variableWidth = 50;
  static const double rowMargin = 12;

  late final List<_CalculatorEntry> _entries;
  final CalculatorState _calculatorState = CalculatorState();

  @override
  void initState() {
    super.initState();
    _restoreState();
  }

  void _restoreState() {
    _entries = [];
    final maxIndex = _calculatorState.maxIndex;
    final minIndex = _calculatorState.minIndex;

    for (var index = minIndex; index <= maxIndex; index += 1) {
      final entry = _CalculatorEntry(index: index);
      entry.inputController.text = _calculatorState.getInput(index);
      _entries.add(entry);
    }

    _entries.forEach(_updateEntryOutput);

    _entries.add(_CalculatorEntry(index: maxIndex + 1));

    _adjustNumberOfEntries();
  }

  @override
  void dispose() {
    for (final entry in _entries) {
      entry.inputController.dispose();
      entry.outputController.dispose();
    }
    super.dispose();
  }

  void _adjustNumberOfEntries() {
    bool entryHasInput(_CalculatorEntry entry) {
      return entry.inputController.text.trim() != "";
    }

    void addNewEntryIfNecesary() {
      final lastEntry = _entries.last;
      final lastHasOutput = entryHasInput(lastEntry);

      if (lastHasOutput && _entries.length < maxEntries) {
        final nextIndex = lastEntry.index + 1;
        if (!_entries.any((e) => e.index == nextIndex)) {
          _entries.add(_CalculatorEntry(index: nextIndex));
        }
      }
    }

    void removeLastEntryIfNecesary() {
      if (_entries.length < 2) {
        return;
      }
      final lastEntry = _entries.last;
      final lastHasOutput = entryHasInput(lastEntry);
      final beforeLastEntry = _entries[_entries.length - 2];
      final beforeLastHasOutput = entryHasInput(beforeLastEntry);

      if (!lastHasOutput && !beforeLastHasOutput) {
        _entries.removeLast();
        removeLastEntryIfNecesary();
      }
    }

    addNewEntryIfNecesary();
    removeLastEntryIfNecesary();
  }

  void _onInputChanged(_CalculatorEntry entry) {
    setState(() {
      _updateEntryOutput(entry);

      // Re-evaluate all subsequent entries since they may depend on ansN
      final changedIndex = entry.index;
      for (final e in _entries) {
        if (e.index > changedIndex && e.inputController.text.trim().isNotEmpty) {
          e.inputController.validate();
          _updateEntryOutput(e);
        }
      }
      _adjustNumberOfEntries();
    });
  }

  void _updateEntryOutput(_CalculatorEntry entry) {
    final formatted = _getFormattedD4rtValue(entry.inputController);
    entry.outputController.text = formatted ?? '';

    _calculatorState.setInput(entry.index, entry.inputController.text);
    final d4rtValue = entry.inputController.d4rtValue;
    if (d4rtValue != null) {
      _calculatorState.setAnswer(entry.index, d4rtValue);
    } else {
      _calculatorState.removeAnswer(entry.index);
    }
  }

  String? _getFormattedD4rtValue(DartCodeController controller) {
    final value = controller.d4rtValue;
    if (value == null || controller.text.trim().isEmpty) return null;
    return value.toVisibleString();
  }

  Widget _buildInputRow(_CalculatorEntry entry) {
    entry.inputController.addListener(() => _onInputChanged(entry));
    final index = entry.index;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: rowMargin/3),
      child: Row(
        children: [
          SizedBox(
            width: variableWidth,
            child: Text(
              CalculatorState.inputName(index),
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: rowMargin),
          Expanded(
            child: DartCodeField(
              key: Key(CalculatorState.inputName(index)),
              controller: entry.inputController,
              validator: (value) {
                return entry.inputController.lastError;
              },
            ),
          ),
          const SizedBox(width: variableWidth + rowMargin),
        ],
      ),
    );
  }

  Widget _buildOutputRow(_CalculatorEntry entry) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: rowMargin/3),
      child: Row(
        children: [
          const SizedBox(width: variableWidth + rowMargin),
          Expanded(
            child: TextFormField(
              readOnly: true,
              enabled: true,
              controller: entry.outputController,
              decoration: const InputDecoration(
                border: InputBorder.none, // OutlineInputBorder(),
                filled: true,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: rowMargin),
          SizedBox(
            width: variableWidth,
            child: Text(
              CalculatorState.outputName(entry.index),
              style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _entries.length,
      itemBuilder: (context, index) {
        final entry = _entries[index];
        return Column(children: [_buildInputRow(entry), _buildOutputRow(entry), Divider()]);
      },
    );
  }
}
