import 'package:d4rt/d4rt.dart';
import 'package:collection/collection.dart';
import 'package:d4rt_formulas/d4rt_formulas.dart';
import 'formula_models.dart';

class Multimap<K, V> extends DelegatingMap<K, List<V>> {
  final Map<K, List<V>> _map;

  Multimap(super.map) : _map = map;

  factory Multimap.create() {
    return Multimap({});
  }

  @override
  List<V>? operator [](Object? key) {
    if (_map.containsKey(key)) {
      return super[key];
    }
    final List<V> newList = [];
    super[key as K] = newList;
    return super[key];
  }
}

class Corpus{
  final Multimap<String, Formula> _tags = Multimap.create();
  // Map formulas by uuid
  final Map<String, Formula> _allFormulas = {};

  void loadFormulas(List<Formula> formulas, {bool replaceOnDuplicates = true, bool checkUnits = true}) {
    for (final formula in formulas) {
      if (!replaceOnDuplicates && _allFormulas.containsKey(formula.uuid)) {
        throw ArgumentError("Duplicate formula:${formula}");
      }

      if( checkUnits ){
        for( final inputVar in formula.input + [formula.output] ){
          if( inputVar.unit != null && !_allUnits.containsKey(inputVar.unit) ){
            throw ArgumentError( "Unit not found in formula ${formula.name}: ${inputVar.unit}");
          }
        }
      }

      _allFormulas[formula.uuid] = formula;
      for( final tag in formula.tags ){
        _tags[tag]?.add(formula);
      }
    }
  }

  List<Formula> getTagFormulas(String tag){
    if( _tags[tag] == null ){
      return [];
    }
    return _tags[tag]?.toList(growable:false) as List<Formula>;
  }

  List<Formula> getFormulas(){
    return _allFormulas.values.toList(growable:false);
  }

  /// Returns first formula with the given name (preserves old API semantics).
  Formula? getFormula(String name) {
    try {
      return _allFormulas.values.firstWhere((f) => f.name == name);
    } catch (e) {
      return null;
    }
  }

  /// Returns formula by uuid
  Formula? getFormulaByUuid(String uuid) {
    return _allFormulas[uuid];
  }

  /// Updates a formula in the corpus
  void updateFormula(Formula formula) {
    if (!_allFormulas.containsKey(formula.name)) {
      throw ArgumentError("Formula not found: ${formula.name}");
    }
    
    // Remove old tags
    final oldFormula = _allFormulas[formula.name]!;
    for (final tag in oldFormula.tags) {
      _tags[tag]?.removeWhere((f) => f.name == formula.name);
    }
    
    // Update the formula
    _allFormulas[formula.name] = formula;
    
    // Add new tags
    for (final tag in formula.tags) {
      _tags[tag]?.add(formula);
    }
  }

  final Multimap<String, String> _baseToUnits = Multimap.create();
  final Map<String, UnitSpec> _allUnits = {};

  void loadUnits(List<UnitSpec> units, [bool replaceOnDuplicates = false]) {
    for (final unit in units) {
      if (!replaceOnDuplicates && _allUnits.containsKey(unit.name)) {
        throw ArgumentError("Duplicate unit:$unit");
      }
      _allUnits[unit.name] = unit;
      _baseToUnits[unit.baseUnit]?.add(unit.name);
    }
  }

  List<String> unitsOfSameMagnitude(String? unit){
    if( unit == null ){
      return ["scalar"];
    }
    final base = getUnit(unit).baseUnit;
    return _baseToUnits[base] as List<String>;
  }


  UnitSpec getUnit(String unit) {
    if (!_allUnits.containsKey(unit)) {
      print(  _allUnits.keys.join(",") );
      throw ArgumentError("Unit not found:$unit");
    }
    return _allUnits.get(unit);
  }

  String _converterFromCodeStringAsExpression(Number x, String codeString) {
    final buffer = StringBuffer();
    buffer.writeln("final x = $x;");
    buffer.writeln("main(){return $codeString;}");
    final code = buffer.toString();
    return code;
  }

  String _converterFromCodeStringAsStatement(Number x, String codeString) {
    final buffer = StringBuffer();
    buffer.writeln("final x = $x;");
    buffer.writeln("main(){ $codeString; return x; }");
    final code = buffer.toString();
    return code;
  }

  Number _convertToBase(Number x, String fromUnit) {
    final unit = getUnit(fromUnit);

    if (unit.factorFromUnitToBase != null) {
      return x * (unit.factorFromUnitToBase as Number);
    }

    if (unit.codeFromUnitToBase == null) {
      throw ArgumentError("Unit has no codeFromUnitToBase: $unit");
    }

    final ret = _convertUsingCode(x, unit.codeFromUnitToBase as String);
    return ret;
  }

  Number _convertFromBase(Number x, String toUnit) {
    final unit = getUnit(toUnit);

    if (unit.factorFromUnitToBase != null) {
      return x / (unit.factorFromUnitToBase as Number);
    }

    if (unit.codeFromBaseToUnit == null) {
      throw ArgumentError("Unit has no codeFromBaseToUnit: $unit");
    }

    final ret = _convertUsingCode(x, unit.codeFromBaseToUnit as String);
    return ret;
  }


  Number _convertUsingCode(Number x, String code ){
    late String completeSourceExpression;
    late String completeSourceStatement;
    try {
      completeSourceExpression = _converterFromCodeStringAsExpression(x, code);
      final ret = _evaluate(completeSourceExpression);
      return ret;
    }
    catch(e1, stack1){
      try{
        completeSourceStatement = _converterFromCodeStringAsStatement(x, code);
        final ret = _evaluate(completeSourceStatement);
        return ret;
      }
      catch( e2, stack2 ){
        errorHandler.notify(e1.toString() + "\n" + completeSourceExpression, stack1);
        errorHandler.notify(e2.toString() + "\n" + completeSourceStatement, stack2);
        throw FormulaEvaluationException( "Evaluation as statement and expression failed" );
      }
    }
  }

  static Number _evaluate(String code, [D4rt? interpreter]) {
    final d4rtInterpreter = interpreter ?? FormulaEvaluator.createDefaultInterpreter();
    FormulaEvaluator.prepareInterpreter(d4rtInterpreter);
    final completeCode = "${FormulaEvaluator.preamble}\n$code";
    final result = d4rtInterpreter.execute(source: completeCode);
    return result.toDouble();
  }


  Number convert(Number x, String fromUnit, String toUnit) {
    final xBase = _convertToBase(x, fromUnit);
    final xTo = _convertFromBase(xBase, toUnit);

    //print( "convert: x:${x}${fromUnit} xTo:${xTo}${toUnit}");
    return xTo;
  }

  Iterable<UnitSpec> allUnits() => _allUnits.values;

  /// Loads formula elements, making sure to load units first, then formulas
  /// to avoid dependency issues.
  void loadFormulaElements(List<FormulaElement> elements) {
    List<UnitSpec> units = [];
    List<Formula> formulas = [];

    // Separate units and formulas
    for (final element in elements) {
      if (element is UnitSpec) {
        units.add(element);
      } else if (element is Formula) {
        formulas.add(element);
      } else {
        throw ArgumentError('Element must be either UnitSpec or Formula: $element');
      }
    }

    // Load units first to satisfy dependencies
    loadUnits(units);

    // Then load formulas
    loadFormulas(formulas);
  }

  /// Loads corpus from database elements
  static Future<Corpus> fromDatabaseElements(List<FormulaElement> elements) async {
    final corpus = Corpus();
    corpus.loadFormulaElements(elements);
    return corpus;
  }

  /// Returns the formula, the units of the formula, and all the units from the corpus with the same base unit.
  List<FormulaElement> withDependencies(Formula formula) {
    final result = <FormulaElement>{};

    // Add the formula itself
    result.add(formula);

    // Helper function to add units and their base equivalents
    void addUnitsAndBaseEquivalents(String? unitName) {
      if (unitName != null) {
        final unit = getUnit(unitName);
        result.add(unit);
        // Add all units with the same base unit
        final unitsWithSameBase = unitsOfSameMagnitude(unitName);
        result.addAll(unitsWithSameBase.map((name) => getUnit(name)));
      }
    }

    // Process input variable units
    formula.input.where((inputVar) => inputVar.unit != null).forEach((inputVar) {
      addUnitsAndBaseEquivalents(inputVar.unit);
    });

    // Process output variable unit
    addUnitsAndBaseEquivalents(formula.output.unit);

    return result.toList();
  }

}
