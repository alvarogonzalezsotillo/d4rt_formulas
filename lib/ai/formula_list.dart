import 'package:flutter/material.dart';
import 'package:d4rt_formulas/formula_models.dart';
import '../corpus.dart';
import 'formula_screen.dart';

class FormulaList extends StatelessWidget {
  final Corpus corpus;
  final List<Formula> formulas;

  const FormulaList({
    super.key,
    required this.corpus,
    required this.formulas,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: formulas.length,
      itemBuilder: (context, index) {
        final formula = formulas[index];
        return ListTile(
          title: Text(formula.name),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FormulaScreen(
                  formula: formula,
                  corpus: corpus,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
