import 'dart:convert' show utf8;

import 'package:resource_portable/resource_portable.dart' show Resource;

import '../corpus.dart';
import '../formula_models.dart';

Future<Corpus> createDefaultCorpus() async{
  final corpus = Corpus();

  Future<void> loadUnits() async {
    final unitResources = [
      "lib/defaults/units/angle.d4rt.units",
      "lib/defaults/units/area.d4rt.units",
      "lib/defaults/units/distance.d4rt.units",
      "lib/defaults/units/energy.d4rt.units",
      "lib/defaults/units/force.d4rt.units",
      "lib/defaults/units/mass.d4rt.units",
      "lib/defaults/units/pressure.d4rt.units",
      "lib/defaults/units/scalar.d4rt.units",
      "lib/defaults/units/temperature.d4rt.units",
      "lib/defaults/units/time.d4rt.units",
      "lib/defaults/units/velocity.d4rt.units",
    ];

    for (final unitRes in unitResources) {
      final resource = Resource(unitRes);
      final literal = await resource.readAsString(encoding: utf8);
      final units = UnitSpec.fromArrayStringLiteral(literal);
      corpus.loadUnits(units);
    }
  }

  Future<void> loadFormulas() async {
    final formulaResources = ["lib/defaults/formulas.d4rt"];

    for (final formRes in formulaResources) {
      final resource = Resource(formRes);
      final literal = await resource.readAsString(encoding: utf8);
      final formulas = Formula.fromArrayStringLiteral(literal);
      corpus.loadFormulas(formulas);
    }
  }

  await loadUnits();
  await loadFormulas();

  return corpus;
}
