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
      "assets/units/amount.d4rt.units",
      "assets/units/angle.d4rt.units",
      "assets/units/area.d4rt.units",
      "assets/units/charge.d4rt.units",
      "assets/units/currency.d4rt.units",
      "assets/units/derived.d4rt.units",
      "assets/units/distance.d4rt.units",
      "assets/units/elasticity.d4rt.units",
      "assets/units/electricity.d4rt.units",
      "assets/units/energy.d4rt.units",
      "assets/units/frequency.d4rt.units",
      "assets/units/force.d4rt.units",
      "assets/units/mass.d4rt.units",
      "assets/units/power.d4rt.units",
      "assets/units/pressure.d4rt.units",
      "assets/units/scalar.d4rt.units",
      "assets/units/temperature.d4rt.units",
      "assets/units/time.d4rt.units",
      "assets/units/velocity.d4rt.units",
      "assets/units/volume.d4rt.units",
    ];

    for (final unitRes in unitResources) {
      print( "Loading units from $unitRes");
      final literal = await loadResourceAsString(unitRes);
      final units = UnitSpec.fromArrayStringLiteral(literal);
      final formulaElements = units.cast<FormulaElement>();
      corpus.loadFormulaElements(formulaElements);
    }
  }

  Future<void> loadFormulas() async {
    final formulaResources = [
      "assets/formulas/conversions_and_constants.d4rt",
      "assets/formulas/electromagnetism.d4rt",
      "assets/formulas/energy_and_power.d4rt",
      "assets/formulas/fluids_and_pressure.d4rt",
      "assets/formulas/formulas.d4rt",
      "assets/formulas/geometry.d4rt",
      "assets/formulas/gravity.d4rt",
      "assets/formulas/it-networking.d4rt",
      "assets/formulas/kinematics_and_dynamics.d4rt",
      "assets/formulas/materials_elasticity.d4rt",
      "assets/formulas/medical_and_bio.d4rt",
      "assets/formulas/misc_math.d4rt",
      "assets/formulas/optics.d4rt",
      "assets/formulas/thermodynamics.d4rt",
      "assets/formulas/trigonometry.d4rt",

    ];

    for (final formRes in formulaResources) {
      print( "Loading formulas from $formRes ...");
      final literal = await loadResourceAsString(formRes);
      print( "Loaded $formRes");
      final formulas = Formula.fromArrayStringLiteral(literal);
      print( "Parsed $formRes");
      final formulaElements = formulas.cast<FormulaElement>();
      corpus.loadFormulaElements(formulaElements);
    }
  }

  await loadUnits();
  await loadFormulas();

  return corpus;
}
