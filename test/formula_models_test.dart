import 'package:d4rt_formulas/corpus.dart';
import 'package:d4rt_formulas/defaults/default_corpus.dart';
import 'package:d4rt_formulas/formula_evaluator.dart';
import 'package:d4rt_formulas/set_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:d4rt_formulas/formula_models.dart';


void main() {

  TestWidgetsFlutterBinding.ensureInitialized();

  Future<Corpus> createTestCorpus() async {
    return createDefaultCorpus();
  }

  Future<Corpus> testCorpus = createTestCorpus();


  test("Parses unit", () {
    final setLiteral = {"name": "kilometer", "symbol": "km", "baseUnit": "meter", "factor": 1000};
    final unit = UnitSpec.fromSet(setLiteral);
    expect(unit.name, "kilometer");
    expect(unit.symbol, "km");
    expect(unit.baseUnit, "meter");
    expect(unit.factorFromUnitToBase, 1000);
    expect(unit.codeFromUnitToBase, null);
    expect(unit.codeFromBaseToUnit, null);
  });

  test("From km to in", () async {
    final corpus = await testCorpus;
    final inches = corpus.convert(1, "kilometer", "inch");
    expect( inches, closeTo(39370.078,0.001) );
  });

  test("From furlong to base", () async {
    final corpus = await testCorpus;
    final m = corpus.convert(1, "furlong", "meter");
    expect(m,closeTo(201.168,0.001));
  });

  test("From base to furlong", () async {
    final corpus = await testCorpus;
    final m = corpus.convert(201.168, "meter", "furlong");
    expect(m,closeTo(1,0.001));
  });

  test("From C to F", () async {
    final corpus = await testCorpus;
    final m = corpus.convert(37, "Celsius", "Fahrenheit");
    expect(m,closeTo(98.6,0.001));
  });

  test("From K to F", () async {
    final corpus = await testCorpus;
    final m = corpus.convert(37, "Kelvin", "Fahrenheit");
    expect(m,closeTo(-393.07,0.001));
  });

  test("From C to K", () async {
    final corpus = await testCorpus;
    final m = corpus.convert(100, "Celsius", "Kelvin");
    expect(m,closeTo(373.15,0.001));
  });

  test('Parses Newton\'s second law formula from set literal', () {
    final setLiteral = {
      "name": "Newton's second law",
      "input": [
        {"name": 'm', "unit": 'kilogram'},
        {"name": 'a', "unit": 'meters per square second'},
      ],
      "output": {"name": 'F', "unit": 'newton'},
      "d4rtCode": '''
              F = a * m;
          ''',
    };

    final formula = Formula.fromSet(setLiteral);
    final evaluator = FormulaEvaluator();

    final result = evaluator.evaluate(formula, {
      'm': 10.0, // 10 kg
      'a': 9.8, // 9.8 m/s²
    });

    expect(result, 98.0); // F = m * a = 10 * 9.8 = 98 N
  });

  test('d4rt parses formula from literal', () {
    final literal = """
    {
      "name": "Newton's second law",
      "input": [
        { "name": 'm', "unit": 'kilogram'},
        { "name": 'a', "unit": 'meters per square second'}
      ],
      "output": { "name": 'F', "unit": 'newton'},
      "d4rtCode": '''
              F = a * m;
          '''
    }
    """;

    final formula = Formula.fromStringLiteral(literal);
    final evaluator = FormulaEvaluator();

    final result = evaluator.evaluate(formula, {
      'm': 10.0, // 10 kg
      'a': 9.8, // 9.8 m/s²
    });

    expect(result, 98.0); // F = m * a = 10 * 9.8 = 98 N
  });

  test('Formula.toStringLiteral creates reversible string', () {
    final originalFormula = Formula(
      name: "Test Formula",
      description: r"""A test formula for toStringLiteral, with some latex $x^2$ and special 
      characters like "quotes" and \backslashes\ and some strange combinations \"'~()\\].""",
      input: [
        VariableSpec(name: 'x', unit: 'meter'),
        VariableSpec(name: 'y', unit: 'second', values: ['1', '2', '3']) // Using strings to match D4RT parsing behavior
      ],
      output: VariableSpec(name: 'result', unit: 'meter_per_second'),
      d4rtCode: 'result = x / y;',
      tags: ['test', 'simple'],
    );

    final literal = originalFormula.toStringLiteral();
    final parsedFormula = Formula.fromStringLiteral(literal);

    expect(parsedFormula.name, originalFormula.name);
    expect(parsedFormula.description, originalFormula.description);
    expect(parsedFormula.input.length, originalFormula.input.length);
    expect(parsedFormula.output, originalFormula.output);
    expect(parsedFormula.d4rtCode, originalFormula.d4rtCode);
    expect(parsedFormula.tags, originalFormula.tags);

    // Check inputs individually
    for (int i = 0; i < originalFormula.input.length; i++) {
      expect(parsedFormula.input[i].name, originalFormula.input[i].name);
      expect(parsedFormula.input[i].unit, originalFormula.input[i].unit);
      expect(parsedFormula.input[i].values, originalFormula.input[i].values);
    }
  });

  test('UnitSpec.toStringLiteral creates reversible string', () {
    final originalUnit = UnitSpec(
      name: "test_unit",
      baseUnit: "base_unit",
      symbol: "tu",
      factorFromUnitToBase: 10.0,
    );

    final literal = originalUnit.toStringLiteral();
    final parsedList = SetUtils.parseD4rtLiteral('[${literal}]');
    final parsedMap = parsedList[0] as Map<Object?, Object?>;
    final parsedUnit = UnitSpec.fromSet(parsedMap);

    expect(parsedUnit.name, originalUnit.name);
    expect(parsedUnit.baseUnit, originalUnit.baseUnit);
    expect(parsedUnit.symbol, originalUnit.symbol);
    expect(parsedUnit.factorFromUnitToBase, originalUnit.factorFromUnitToBase);
  });

  group('APGAR Score', () {
    test('evaluates APGAR score formula - Normal case', () async {
      final corpus = await testCorpus;
      final formula = corpus.getFormula("Apgar Score")!;
      final evaluator = FormulaEvaluator();

      final result = evaluator.evaluate(formula, {
        'HeartRate': '> 100 bpm',
        'Breathing': 'Strong, robust cry',
        'MuscleTone': 'Flexed arms/leg, resists extension',
        'Reflexes': 'Cry on stimulation',
        'SkinColor': 'Pink'
      });

      expect(result, 'Score: 10 - Normal');
    });

    test('evaluates APGAR score formula - Good condition case', () async {
      final corpus = await testCorpus;
      final formula = corpus.getFormula("Apgar Score")!;
      final evaluator = FormulaEvaluator();

      final result = evaluator.evaluate(formula, {
        'HeartRate': '> 100 bpm',  // 2
        'Breathing': 'Strong, robust cry',  // 2
        'MuscleTone': 'Some',  // 1
        'Reflexes': 'Grimace on aggressive stimulation',  // 1
        'SkinColor': 'Blue extremities, pink body'  // 1
      });

      expect(result, 'Score: 7 - Normal');
    });

    test('evaluates APGAR score formula - Needs assistance case', () async {
      final corpus = await testCorpus;
      final formula = corpus.getFormula("Apgar Score")!;
      final evaluator = FormulaEvaluator();

      final result = evaluator.evaluate(formula, {
        'HeartRate': '> 100 bpm',  // 2
        'Breathing': 'Weak, irregular',  // 1
        'MuscleTone': 'Some',  // 1
        'Reflexes': 'Grimace on aggressive stimulation',  // 1
        'SkinColor': 'Blue extremities, pink body'  // 1
      });

      expect(result, 'Score: 6 - Needs assistance');
    });

    test('evaluates APGAR score formula - Critical condition case', () async {
      final corpus = await testCorpus;
      final formula = corpus.getFormula("Apgar Score")!;
      final evaluator = FormulaEvaluator();

      final result = evaluator.evaluate(formula, {
        'HeartRate': 'Absent',  // 0
        'Breathing': 'Absent',  // 0
        'MuscleTone': 'None',  // 0
        'Reflexes': 'No response',  // 0
        'SkinColor': 'Blue or pale'  // 0
      });

      expect(result, 'Score: 0 - Critical condition');
    });

    test('evaluates APGAR score formula - Invalid value throws exception', () async {
      final corpus = await testCorpus;
      final formula = corpus.getFormula("Apgar Score")!;
      final evaluator = FormulaEvaluator();

      expect(() => evaluator.evaluate(formula, {
        'HeartRate': 'Invalid Value',  // Not in allowed values
        'Breathing': 'Absent',  // 0
        'MuscleTone': 'None',  // 0
        'Reflexes': 'No response',  // 0
        'SkinColor': 'Blue or pale'  // 0
      }), throwsA(isA<FormulaEvaluationException>()));
    });
  });

  test('Corpus.withDependencies returns formula and its dependencies', () async {
    final corpus = await testCorpus;

    // Get a formula that has units associated with it
    final formula = corpus.getFormula("Newton's Second Law");
    expect(formula, isNotNull);

    // Call withDependencies method
    final dependencies = corpus.withDependencies(formula!);

    // Check that the formula itself is included
    expect(dependencies.any((element) => element is Formula && element.name == formula.name), true);

    // Check that units from input and output are included
    for (final inputVar in formula.input) {
      if (inputVar.unit != null) {
        expect(dependencies.any((element) => element is UnitSpec && element.name == inputVar.unit), true);

        // Check that units with same base unit are included
        final unitsWithSameBase = corpus.unitsOfSameMagnitude(inputVar.unit!);
        for (final unitName in unitsWithSameBase) {
          expect(dependencies.any((element) => element is UnitSpec && element.name == unitName), true);
        }
      }
    }

    if (formula.output.unit != null) {
      expect(dependencies.any((element) => element is UnitSpec && element.name == formula.output.unit), true);

      // Check that units with same base unit as output are included
      final outputUnitsWithSameBase = corpus.unitsOfSameMagnitude(formula.output.unit!);
      for (final unitName in outputUnitsWithSameBase) {
        expect(dependencies.any((element) => element is UnitSpec && element.name == unitName), true);
      }
    }

    // Verify that there are no duplicates by checking the length of the list vs the set
    final uniqueDependencies = dependencies.toSet();
    expect(dependencies.length, equals(uniqueDependencies.length));
  });


}
