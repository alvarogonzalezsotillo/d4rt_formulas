import 'package:d4rt/d4rt.dart';
import 'package:collection/collection.dart';
import 'package:d4rt_formulas/d4rt_formulas.dart';

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

class UnitCorpus {
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

  UnitSpec operator [](String unit) {
    if (!_allUnits.containsKey(unit)) {
      throw ArgumentError("Unit not found:$unit");
    }
    return _allUnits.get(unit);
  }

  UnitSpec get(String unit) => this[unit];

  String _converterFromCodeString(Number x, String codeString) {
    final buffer = StringBuffer();
    buffer.writeln("final x = ${x};");
    buffer.writeln("main(){return $codeString;}");
    final code = buffer.toString();
    return code;
  }

  Number _convertToBase(Number x, String fromUnit) {
    final unit = this[fromUnit];

    if (unit.factorFromUnitToBase != null) {
      return x * (unit.factorFromUnitToBase as Number);
    }

    if (unit.codeFromUnitToBase == null) {
      throw ArgumentError("Unit has no codeFromUnitToBase: $unit");
    }

    final d4rt = D4rt();
    final completeSource = _converterFromCodeString(x, unit.codeFromUnitToBase as String);
    final ret = d4rt.execute(source: completeSource);
    return ret as Number;
  }

  Number _convertFromBase(Number x, String toUnit) {
    final unit = this[toUnit];

    if (unit.factorFromUnitToBase != null) {
      return x / (unit.factorFromUnitToBase as Number);
    }

    if (unit.codeFromBaseToUnit == null) {
      throw ArgumentError("Unit has no codeFromBaseToUnit: $unit");
    }

    final d4rt = D4rt();
    final completeSource = _converterFromCodeString(x, unit.codeFromBaseToUnit as String);
    final ret = d4rt.execute(source: completeSource);
    return ret as Number;
  }

  Number convert(Number x, String fromUnit, String toUnit) {
    final xBase = _convertToBase(x, fromUnit);
    final xTo = _convertFromBase(xBase, toUnit);

    return xTo;
  }

  Iterable<UnitSpec> allUnits() => _allUnits.values;
}
