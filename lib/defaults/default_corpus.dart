import 'dart:async';
import 'dart:convert' show utf8;
import 'package:flutter/services.dart' show rootBundle;

import 'package:resource_portable/resource_portable.dart' show Resource;

import '../corpus.dart';
import '../formula_models.dart';


Future<Corpus> createDefaultCorpus() async{
  final corpus = Corpus();

  Future<String> loadResourceAsString(String path) async {
    return await rootBundle.loadString(path, cache: false);
  }


  Future<void> loadUnits() async {
    final unitResources = [
      "assets/units/angle.d4rt.units",
      "assets/units/area.d4rt.units",
      "assets/units/currency.d4rt.units",
      "assets/units/distance.d4rt.units",
      "assets/units/elasticity.d4rt.units",
      "assets/units/electricity.d4rt.units",
      "assets/units/energy.d4rt.units",
      "assets/units/frequency.d4rt.units",
      "assets/units/force.d4rt.units",
      "assets/units/mass.d4rt.units",
      "assets/units/pressure.d4rt.units",
      "assets/units/scalar.d4rt.units",
      "assets/units/temperature.d4rt.units",
      "assets/units/time.d4rt.units",
      "assets/units/velocity.d4rt.units",
    ];

    for (final unitRes in unitResources) {
      print( "Loading units from $unitRes");
      final literal = await loadResourceAsString(unitRes);
      final units = UnitSpec.fromArrayStringLiteral(literal);
      corpus.loadFormulaElements(units);
    }
  }

  Future<void> loadFormulas() async {
    final formulaResources = ["assets/formulas/formulas.d4rt"];

    for (final formRes in formulaResources) {
      final literal = await loadResourceAsString(formRes);
      final formulas = Formula.fromArrayStringLiteral(literal);
      corpus.loadFormulaElements(formulas);
    }
  }

  await loadUnits();
  await loadFormulas();

  return corpus;
}
