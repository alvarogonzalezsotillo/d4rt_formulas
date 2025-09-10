import 'package:flutter/material.dart';
import '../../formula_models.dart';
import '../../corpus.dart';

class UnitDropdown extends StatelessWidget {
  final UnitCorpus corpus;
  final VariableSpec variable;
  final String? selectedUnit;
  final ValueChanged<String?> onUnitChanged;

  const UnitDropdown({
    super.key,
    required this.corpus,
    required this.variable,
    required this.selectedUnit,
    required this.onUnitChanged,
  });

  @override
  Widget build(BuildContext context) {
    final unitNames = corpus.unitsOfSameMagnitude(variable.magnitude);
    final availableUnits = unitNames.map((name) => corpus.get(name)).toList();

    return DropdownButton<String>(
      value: selectedUnit ?? variable.magnitude,
      icon: const Icon(Icons.arrow_drop_down),
      elevation: 16,
      style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 14),
      underline: Container(height: 1, color: Theme.of(context).dividerColor),
      onChanged: onUnitChanged,
      items: availableUnits.map<DropdownMenuItem<String>>((UnitSpec unit) {
        return DropdownMenuItem<String>(
          value: unit.name,
          child: Text(unit.symbol, style: const TextStyle(fontSize: 14)),
        );
      }).toList(),
    );
  }
}
