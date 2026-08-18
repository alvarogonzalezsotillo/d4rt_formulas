import 'package:flutter/material.dart';
import 'd4rt_editing_controller.dart';
import '../formula_evaluator.dart';
import '../value_formatter.dart';

class _CalculatorEntry {
  final int index;
  final D4rtEditingController inputController = D4rtEditingController();
  final TextEditingController outputController = TextEditingController();

  _CalculatorEntry({required this.index});
}

class CalculatorTab extends StatefulWidget {
  const CalculatorTab({super.key});

  @override
  State<CalculatorTab> createState() => _CalculatorTabState();
}

class _CalculatorTabState extends State<CalculatorTab> {

  final int maxEntries = 100;
  
  final List<_CalculatorEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    _entries.add(_CalculatorEntry(index: 1));
  }

  @override
  void dispose() {
    for (final entry in _entries) {
      entry.inputController.dispose();
      entry.outputController.dispose();
    }
    super.dispose();
  }

  void _onInputChanged(_CalculatorEntry entry) {
    print( "CALC: onInputChanged");
    print( "CALC: ${entry.index}/${_entries.length} --> ${entry.inputController.text}");
    setState(() {
      final formatted = _formatResult(entry.inputController);
      entry.outputController.text = formatted ?? '';

      final lastEntry = _entries.last;
      final lastHasOutput = lastEntry.inputController.d4rtValue != null &&
          lastEntry.inputController.text.trim().isNotEmpty;

      if (lastHasOutput && _entries.length < maxEntries) {
        final nextIndex = lastEntry.index + 1;
        if (!_entries.any((e) => e.index == nextIndex)) {
          _entries.add(_CalculatorEntry(index: nextIndex));
        }
      }
    });
  }

  String? _formatResult(D4rtEditingController controller) {
    final value = controller.d4rtValue;
    if (value == null || controller.text.trim().isEmpty) return null;
    if (value is NumberResult) {
      return formatOutput(value.value);
    }
    if (value is StringResult) {
      return formatOutput(value.value);
    }
    return value.toString();
  }

  Widget _buildInputRow(_CalculatorEntry entry) {
    entry.inputController.addListener(()=>_onInputChanged(entry));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              key: Key('input${entry.index}'),
              controller: entry.inputController,
              autovalidateMode: AutovalidateMode.always,
              validator: (value) {
                return entry.inputController.lastError;
              },
              
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(
              'input${entry.index}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          
        ],
      ),
    );
  }

  Widget _buildOutputRow(_CalculatorEntry entry) {
    final formatted = _formatResult(entry.inputController);
    print( "CALC: buildOutputRow: ${entry.index} --> $formatted ");

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              'ans${entry.index}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              readOnly: true,
              controller: entry.outputController,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print( "CALC: build");
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _entries.length,
      itemBuilder: (context, index) {
        final entry = _entries[index];
        return Column(
          children: [
            _buildInputRow(entry),
            _buildOutputRow(entry),
          ],
        );
      },
    );
  }
}
