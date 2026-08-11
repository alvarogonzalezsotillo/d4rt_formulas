import 'dart:async';
import 'package:flutter/services.dart' show AssetManifest, rootBundle;

import '../corpus.dart';
import '../formula_models.dart';
import '../compile_constants.dart';

Future<Corpus> createDefaultCorpus() async {
  final corpus = Corpus();

  Future<String> loadResourceAsString(String path) async {
    return CompileConstants.loadResourceAsString(path);
  }

  Future<List<String>> listUnitAssets() async {
    final assetManifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    return assetManifest
        .listAssets()
        .where((s) => s.startsWith("assets/units/") && s.endsWith("d4rt.units"))
        .toList();
  }

  Future<List<String>> listFormulaAssets() async {
    final assetManifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    return assetManifest
        .listAssets()
        .where(
          (s) => s.startsWith("assets/formulas/") && s.endsWith("d4rt.formulas"),
        )
        .toList();
  }

  Future<void> loadUnits() async {
    final unitResources = await listUnitAssets();
    for (final unitRes in unitResources) {
      print("Loading units from $unitRes");
      final literal = await loadResourceAsString(unitRes);
      final units = UnitSpec.fromArrayStringLiteral(literal);
      final formulaElements = units.cast<FormulaElement>();
      corpus.loadFormulaElements(formulaElements);
    }
  }

  Future<void> loadFormulas() async {
    final formulaResources = await listFormulaAssets();

    for (final formRes in formulaResources) {
      print("Loading formulas from $formRes ...");
      final literal = await loadResourceAsString(formRes);
      print("Loaded $formRes");
      final formulas = Formula.fromArrayStringLiteral(literal);
      print("Parsed $formRes");
      final formulaElements = formulas.cast<FormulaElement>();
      corpus.loadFormulaElements(formulaElements);
    }
  }

  await loadUnits();
  await loadFormulas();

  return corpus;
}
