import 'package:d4rt_formulas/corpus.dart';
import 'package:d4rt_formulas/defaults/default_corpus.dart';
import 'package:d4rt_formulas/formula_evaluator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<Corpus> createTestCorpus() async {
    return createDefaultCorpus();
  }

  Future<Corpus> testCorpus = createTestCorpus();

  group('MDCalc formulas are loaded', () {
    test('all MDCalc formulas exist in the default corpus', () async {
      final corpus = await testCorpus;
      const names = [
        'Mean Arterial Pressure (MAP)',
        'Pulse Pressure',
        'QTc Interval (Bazett)',
        'CHA₂DS₂-VASc Score',
        'CHADS₂ Score',
        'Body Mass Index (BMI)',
        'Body Surface Area (Mosteller)',
        'Ideal Body Weight (Devine)',
        'Creatinine Clearance (Cockcroft-Gault)',
        'MDRD GFR Equation',
        'CKD-EPI 2021 GFR (creatinine)',
        'Revised Schwartz eGFR (Pediatric)',
        'Anion Gap',
        'Osmolar Gap',
        'Corrected Calcium (Albumin-Adjusted)',
        'A-a Gradient',
        'PaO₂/FiO₂ (P/F) Ratio',
        'MELD Score',
        'Child-Pugh Score',
        'CURB-65 Score',
        'qSOFA Score',
        'Wells Criteria for Pulmonary Embolism',
        'Holliday-Segar Maintenance Fluids',
      ];
      for (final name in names) {
        expect(corpus.getFormula(name), isNotNull, reason: '$name not found');
      }
    });

    test('medical units load and convert', () async {
      final corpus = await testCorpus;
      // 100 mg/dL = 1000 mg/L (mass concentration)
      expect(corpus.convert(100, 'milligram per deciliter', 'milligram per liter'),
          closeTo(1000, 0.001));
      // 1 g/dL = 1000 mg/dL
      expect(corpus.convert(1, 'gram per deciliter', 'milligram per deciliter'),
          closeTo(1000, 0.001));
      // 1 year in seconds
      expect(corpus.convert(1, 'year', 'second'), closeTo(31557600, 0.001));
      // 100 cm = 1 m
      expect(corpus.convert(100, 'centimeter', 'meter'), closeTo(1, 0.001));
    });
  });

  group('Hemodynamics', () {
    test('Mean Arterial Pressure', () async {
      final corpus = await testCorpus;
      final formula = corpus.getFormula('Mean Arterial Pressure (MAP)')!;
      final evaluator = FormulaEvaluator();
      final result = evaluator.evaluate(formula, {'SystolicBP': 120.0, 'DiastolicBP': 80.0});
      expect(result, closeTo(93.33, 0.01));
    });

    test('Pulse Pressure', () async {
      final corpus = await testCorpus;
      final formula = corpus.getFormula('Pulse Pressure')!;
      final evaluator = FormulaEvaluator();
      final result = evaluator.evaluate(formula, {'SystolicBP': 120.0, 'DiastolicBP': 80.0});
      expect(result, closeTo(40.0, 0.001));
    });

    test('QTc Interval (Bazett)', () async {
      final corpus = await testCorpus;
      final formula = corpus.getFormula('QTc Interval (Bazett)')!;
      final evaluator = FormulaEvaluator();
      final result = evaluator.evaluate(formula, {'QT': 400.0, 'RR': 1000.0});
      expect(result, closeTo(400.0, 0.001));
    });

    test('QTc throws signal for non-positive RR', () async {
      final corpus = await testCorpus;
      final formula = corpus.getFormula('QTc Interval (Bazett)')!;
      final evaluator = FormulaEvaluator();
      final result = evaluator.evaluate(formula, {'QT': 400.0, 'RR': 0.0});
      expect(result, 'QT and RR must be greater than 0');
    });
  });

  group('Stroke risk scores', () {
    test('CHA2DS2-VASc - high risk', () async {
      final corpus = await testCorpus;
      final formula = corpus.getFormula('CHA₂DS₂-VASc Score')!;
      final evaluator = FormulaEvaluator();
      final result = evaluator.evaluate(formula, {
        'Age': '>= 75',
        'Sex': 'Male',
        'CHF': 'No',
        'Hypertension': 'Yes',
        'StrokeTIA': 'Yes',
        'VascularDisease': 'No',
        'Diabetes': 'Yes',
      });
      expect(result, 'Score: 6 - Oral anticoagulation recommended');
    });

    test('CHA2DS2-VASc - low risk female', () async {
      final corpus = await testCorpus;
      final formula = corpus.getFormula('CHA₂DS₂-VASc Score')!;
      final evaluator = FormulaEvaluator();
      final result = evaluator.evaluate(formula, {
        'Age': '< 65',
        'Sex': 'Female',
        'CHF': 'No',
        'Hypertension': 'No',
        'StrokeTIA': 'No',
        'VascularDisease': 'No',
        'Diabetes': 'No',
      });
      expect(result, 'Score: 1 - Anticoagulation not recommended');
    });

    test('CHADS2 - intermediate risk', () async {
      final corpus = await testCorpus;
      final formula = corpus.getFormula('CHADS₂ Score')!;
      final evaluator = FormulaEvaluator();
      final result = evaluator.evaluate(formula, {
        'CHF': 'Yes',
        'Hypertension': 'Yes',
        'Age75': '>= 75',
        'Diabetes': 'No',
        'StrokeHistory': 'Yes',
      });
      expect(result, 'CHADS2: 5 - annual stroke risk 12.5%');
    });
  });

  group('Body habitus', () {
    test('BMI', () async {
      final corpus = await testCorpus;
      final formula = corpus.getFormula('Body Mass Index (BMI)')!;
      final evaluator = FormulaEvaluator();
      final result = evaluator.evaluate(formula, {'Weight': 70.0, 'Height': 1.75});
      expect(result, closeTo(22.86, 0.01));
    });

    test('Body Surface Area (Mosteller)', () async {
      final corpus = await testCorpus;
      final formula = corpus.getFormula('Body Surface Area (Mosteller)')!;
      final evaluator = FormulaEvaluator();
      final result = evaluator.evaluate(formula, {'Weight': 70.0, 'Height': 170.0});
      expect(result, closeTo(1.818, 0.001));
    });

    test('Ideal Body Weight (Devine) - male', () async {
      final corpus = await testCorpus;
      final formula = corpus.getFormula('Ideal Body Weight (Devine)')!;
      final evaluator = FormulaEvaluator();
      final result = evaluator.evaluate(formula, {'Sex': 'Male', 'Height': 70.0});
      expect(result, closeTo(73.0, 0.001));
    });

    test('Ideal Body Weight (Devine) - female', () async {
      final corpus = await testCorpus;
      final formula = corpus.getFormula('Ideal Body Weight (Devine)')!;
      final evaluator = FormulaEvaluator();
      final result = evaluator.evaluate(formula, {'Sex': 'Female', 'Height': 70.0});
      expect(result, closeTo(68.5, 0.001));
    });
  });

  group('Renal', () {
    test('Cockcroft-Gault - male', () async {
      final corpus = await testCorpus;
      final formula = corpus.getFormula('Creatinine Clearance (Cockcroft-Gault)')!;
      final evaluator = FormulaEvaluator();
      final result = evaluator.evaluate(formula, {
        'Age': 70.0,
        'Sex': 'Male',
        'Weight': 70.0,
        'SerumCreatinine': 1.0,
      });
      expect(result, closeTo(68.06, 0.01));
    });

    test('Cockcroft-Gault - female', () async {
      final corpus = await testCorpus;
      final formula = corpus.getFormula('Creatinine Clearance (Cockcroft-Gault)')!;
      final evaluator = FormulaEvaluator();
      final result = evaluator.evaluate(formula, {
        'Age': 70.0,
        'Sex': 'Female',
        'Weight': 70.0,
        'SerumCreatinine': 1.0,
      });
      expect(result, closeTo(57.85, 0.01));
    });

    test('MDRD - female non-African American', () async {
      final corpus = await testCorpus;
      final formula = corpus.getFormula('MDRD GFR Equation')!;
      final evaluator = FormulaEvaluator();
      final result = evaluator.evaluate(formula, {
        'SerumCreatinine': 1.0,
        'Age': 50.0,
        'Sex': 'Female',
        'Race': 'Non-African American',
      });
      expect(result, closeTo(62.37, 0.05));
    });

    test('CKD-EPI 2021 - female', () async {
      final corpus = await testCorpus;
      final formula = corpus.getFormula('CKD-EPI 2021 GFR (creatinine)')!;
      final evaluator = FormulaEvaluator();
      final result = evaluator.evaluate(formula, {
        'SerumCreatinine': 0.7,
        'Age': 50.0,
        'Sex': 'Female',
      });
      expect(result, closeTo(105.29, 0.05));
    });

    test('Revised Schwartz - pediatric', () async {
      final corpus = await testCorpus;
      final formula = corpus.getFormula('Revised Schwartz eGFR (Pediatric)')!;
      final evaluator = FormulaEvaluator();
      final result = evaluator.evaluate(formula, {'Height': 100.0, 'SerumCreatinine': 0.5});
      expect(result, closeTo(82.6, 0.001));
    });
  });

  group('Electrolytes and gases', () {
    test('Anion Gap', () async {
      final corpus = await testCorpus;
      final formula = corpus.getFormula('Anion Gap')!;
      final evaluator = FormulaEvaluator();
      final result = evaluator.evaluate(formula, {
        'Sodium': 140.0,
        'Chloride': 105.0,
        'Bicarbonate': 24.0,
      });
      expect(result, closeTo(11.0, 0.001));
    });

    test('Osmolar Gap', () async {
      final corpus = await testCorpus;
      final formula = corpus.getFormula('Osmolar Gap')!;
      final evaluator = FormulaEvaluator();
      final result = evaluator.evaluate(formula, {
        'Sodium': 140.0,
        'Glucose': 100.0,
        'BUN': 14.0,
        'MeasuredOsmolality': 285.0,
      });
      expect(result, closeTo(-5.56, 0.01));
    });

    test('Corrected Calcium', () async {
      final corpus = await testCorpus;
      final formula = corpus.getFormula('Corrected Calcium (Albumin-Adjusted)')!;
      final evaluator = FormulaEvaluator();
      final result = evaluator.evaluate(formula, {'Calcium': 8.0, 'Albumin': 3.0});
      expect(result, closeTo(8.8, 0.001));
    });

    test('A-a gradient', () async {
      final corpus = await testCorpus;
      final formula = corpus.getFormula('A-a Gradient')!;
      final evaluator = FormulaEvaluator();
      final result = evaluator.evaluate(formula, {
        'FiO2': 21.0,
        'PaCO2': 40.0,
        'PaO2': 90.0,
      });
      expect(result, closeTo(9.73, 0.01));
    });

    test('P/F Ratio', () async {
      final corpus = await testCorpus;
      final formula = corpus.getFormula('PaO₂/FiO₂ (P/F) Ratio')!;
      final evaluator = FormulaEvaluator();
      final result = evaluator.evaluate(formula, {'PaO2': 90.0, 'FiO2': 40.0});
      expect(result, closeTo(225.0, 0.001));
    });
  });

  group('Liver scores', () {
    test('MELD Score', () async {
      final corpus = await testCorpus;
      final formula = corpus.getFormula('MELD Score')!;
      final evaluator = FormulaEvaluator();
      final result = evaluator.evaluate(formula, {
        'Bilirubin': 2.0,
        'INR': 1.5,
        'Creatinine': 1.2,
        'Dialysis': 'No',
      });
      expect(result, closeTo(15.0, 0.001));
    });

    test('Child-Pugh - class C', () async {
      final corpus = await testCorpus;
      final formula = corpus.getFormula('Child-Pugh Score')!;
      final evaluator = FormulaEvaluator();
      final result = evaluator.evaluate(formula, {
        'Bilirubin': '> 3 mg/dL',
        'Albumin': '< 2.8 g/dL',
        'INR': '> 2.3',
        'Ascites': 'Moderate to severe',
        'Encephalopathy': 'Grade III - IV (or refractory)',
      });
      expect(result, 'Child-Pugh: 15 - Class C (advanced dysfunction, 1-year survival ~45%)');
    });
  });

  group('Infectious disease and thromboembolism', () {
    test('CURB-65 - high risk', () async {
      final corpus = await testCorpus;
      final formula = corpus.getFormula('CURB-65 Score')!;
      final evaluator = FormulaEvaluator();
      final result = evaluator.evaluate(formula, {
        'Confusion': 'Yes',
        'UreaBUN': '> 19 mg/dL',
        'RespiratoryRate': '>= 30 breaths/min',
        'BloodPressure': 'Low (SBP < 90 or DBP <= 60 mmHg)',
        'Age65': '>= 65 years',
      });
      expect(result, 'CURB-65: 5 - 41.5% mortality - high risk, ICU admission');
    });

    test('qSOFA - high risk', () async {
      final corpus = await testCorpus;
      final formula = corpus.getFormula('qSOFA Score')!;
      final evaluator = FormulaEvaluator();
      final result = evaluator.evaluate(formula, {
        'RespiratoryRate': '>= 22 breaths/min',
        'SystolicBP': '<= 100 mmHg',
        'AlteredMentation': 'Yes',
      });
      expect(result, 'qSOFA: 3 - high risk - suspect sepsis, consider ICU admission');
    });

    test('Wells PE - high probability', () async {
      final corpus = await testCorpus;
      final formula = corpus.getFormula('Wells Criteria for Pulmonary Embolism')!;
      final evaluator = FormulaEvaluator();
      final result = evaluator.evaluate(formula, {
        'ClinicalSignsDVT': 'Yes',
        'PEmainDiagnosis': 'Yes',
        'HeartRate': '> 100 bpm',
        'Immobilization': 'No',
        'PreviousPEorDVT': 'No',
        'Hemoptysis': 'Yes',
        'Malignancy': 'No',
      });
      expect(result, 'Wells PE score: 8.5 - high probability');
    });
  });

  group('Pediatrics', () {
    test('Holliday-Segar maintenance fluids - above 20 kg', () async {
      final corpus = await testCorpus;
      final formula = corpus.getFormula('Holliday-Segar Maintenance Fluids')!;
      final evaluator = FormulaEvaluator();
      final result = evaluator.evaluate(formula, {'Weight': 25.0});
      expect(result, 'Maintenance: 1600 mL/day');
    });

    test('Holliday-Segar maintenance fluids - 10 kg', () async {
      final corpus = await testCorpus;
      final formula = corpus.getFormula('Holliday-Segar Maintenance Fluids')!;
      final evaluator = FormulaEvaluator();
      final result = evaluator.evaluate(formula, {'Weight': 10.0});
      expect(result, 'Maintenance: 1000 mL/day');
    });
  });
}
