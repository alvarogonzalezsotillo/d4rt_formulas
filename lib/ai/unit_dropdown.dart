import 'package:flutter/material.dart';
import '../../formula_models.dart';
import '../../corpus.dart';

class UnitDropdown extends StatelessWidget {
  final Corpus corpus;
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
    final unitNames = corpus.unitsOfSameMagnitude(variable.unit);
    final availableUnits = unitNames.map((name) => corpus.getUnit(name)).toList();

    return SizedBox(
      width: 200, // Constrain dropdown width
      child: DropdownButton<String>(
        value: selectedUnit ?? variable.unit,
      selectedItemBuilder: (context) => availableUnits.map((unit) => 
        SizedBox(
          width: 200,
          child: Text(unit.symbol, overflow: TextOverflow.ellipsis),
        )
      ).toList(),
      icon: const Icon(Icons.arrow_drop_down),
      elevation: 16,
      style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 14),
      underline: Container(height: 1, color: Theme.of(context).dividerColor),
      onChanged: onUnitChanged,
      items: availableUnits.map<DropdownMenuItem<String>>((UnitSpec unit) {
        return DropdownMenuItem<String>(
          value: unit.name,
          child: SizedBox(
            width: 200, // Fixed width for all items
            child: Text("${unit.symbol} - ${unit.name}", 
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      }).toList(),
      menuMaxHeight: 400,
      isExpanded: true,
      ),
    );
  }
}
