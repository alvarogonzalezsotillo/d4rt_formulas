import 'package:d4rt_formulas/corpus.dart';
import 'package:d4rt_formulas/defaults/default_corpus.dart';
import 'package:d4rt_formulas/formula_evaluator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:d4rt_formulas/formula_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<Corpus> createTestCorpus() async {
    return createDefaultCorpus();
  }

  Future<Corpus> testCorpus = createTestCorpus();

  group('Physics Formulas Tests', () {
    test('evaluates Mass-Energy Equivalence formula (E=mc²)', () async {
      final corpus = await testCorpus;
      final formula = corpus.getFormula("Mass-Energy Equivalence")!;
      final evaluator = FormulaEvaluator();

      // Test with 1 kg of mass
      final result = evaluator.evaluate(formula, {
        'm': 1.0, // 1 kg
      });

      // E = mc² = 1 * (299792458)² ≈ 8.98755179 × 10^16 Joules
      expect(result, closeTo(8.98755179e16, 1e12));
    });

    test('evaluates Ohm\'s Law formula (V=IR)', () async {
      final corpus = await testCorpus;
      final formula = corpus.getFormula("Ohm's Law")!;
      final evaluator = FormulaEvaluator();

      // Test with 2 amperes and 5 ohms
      final result = evaluator.evaluate(formula, {
        'I': 2.0, // 2 Amperes
        'R': 5.0, // 5 Ohms
      });

      // V = I * R = 2 * 5 = 10 Volts
      expect(result, 10.0);
    });

    test('evaluates Hooke\'s Law formula (F=-kx)', () async {
      final corpus = await testCorpus;
      final formula = corpus.getFormula("Hooke's Law")!;
      final evaluator = FormulaEvaluator();

      // Test with spring constant k=100 N/m and displacement x=0.5 m
      final result = evaluator.evaluate(formula, {
        'k': 100.0, // 100 N/m
        'x': 0.5,   // 0.5 m
      });

      // F = -k * x = -100 * 0.5 = -50 N
      expect(result, -50.0);
    });

    test('evaluates Centripetal Force formula (F=mv²/r)', () async {
      final corpus = await testCorpus;
      final formula = corpus.getFormula("Centripetal Force")!;
      final evaluator = FormulaEvaluator();

      // Test with m=10 kg, v=5 m/s, r=2 m
      final result = evaluator.evaluate(formula, {
        'm': 10.0, // 10 kg
        'v': 5.0,  // 5 m/s
        'r': 2.0,  // 2 m
      });

      // F = (m * v²) / r = (10 * 25) / 2 = 250 / 2 = 125 N
      expect(result, 125.0);
    });

    test('evaluates Wave Equation formula (v=fλ)', () async {
      final corpus = await testCorpus;
      final formula = corpus.getFormula("Wave Equation")!;
      final evaluator = FormulaEvaluator();

      // Test with frequency f=50 Hz and wavelength λ=2 m
      final result = evaluator.evaluate(formula, {
        'f': 50.0,    // 50 Hz
        'lambda': 2.0, // 2 m
      });

      // v = f * λ = 50 * 2 = 100 m/s
      expect(result, 100.0);
    });
  });

  group('Trigonometry Formulas Tests', () {
    test('evaluates Pythagorean Theorem formula (a²+b²=c²)', () async {
      final corpus = await testCorpus;
      final formula = corpus.getFormula("Pythagorean Theorem")!;
      final evaluator = FormulaEvaluator();

      // Test with a=3, b=4 (classic 3-4-5 triangle)
      final result = evaluator.evaluate(formula, {
        'a': 3.0, // 3 m
        'b': 4.0, // 4 m
      });

      // c = √(a² + b²) = √(9 + 16) = √25 = 5
      expect(result, 5.0);
    });

    test('evaluates Sine Rule formula (a/sin A = b/sin B)', () async {
      final corpus = await testCorpus;
      final formula = corpus.getFormula("Sine Rule")!;
      final evaluator = FormulaEvaluator();

      // Test with a=5, angle A=30°, angle B=60°
      final result = evaluator.evaluate(formula, {
        'a': 5.0, // Side a = 5 m
        'A': 30.0, // Angle A = 30 degrees
        'B': 60.0, // Angle B = 60 degrees
      });

      // b = (a * sin(B)) / sin(A) = (5 * sin(60°)) / sin(30°)
      // b = (5 * 0.866) / 0.5 = 4.33 / 0.5 = 8.66
      expect(result, closeTo(8.66, 0.01));
    });

    test('evaluates Cosine Rule formula (c²=a²+b²-2ab cos C)', () async {
      final corpus = await testCorpus;
      final formula = corpus.getFormula("Cosine Rule")!;
      final evaluator = FormulaEvaluator();

      // Test with a=5, b=7, angle C=60°
      final result = evaluator.evaluate(formula, {
        'a': 5.0, // Side a = 5 m
        'b': 7.0, // Side b = 7 m
        'C': 60.0, // Angle C = 60 degrees
      });

      // c = √(a² + b² - 2ab*cos(C))
      // c = √(25 + 49 - 2*5*7*cos(60°))
      // c = √(74 - 70*0.5) = √(74 - 35) = √39 ≈ 6.24
      expect(result, closeTo(6.24, 0.01));
    });

    test('evaluates Trigonometric Identity formula (sin²θ + cos²θ = 1)', () async {
      final corpus = await testCorpus;
      final formula = corpus.getFormula("Trigonometric Identity")!;
      final evaluator = FormulaEvaluator();

      // Test with θ=45°
      final result = evaluator.evaluate(formula, {
        'theta': 45.0, // 45 degrees
      });

      // sin²(45°) + cos²(45°) should equal 1
      // (≈0.707)² + (≈0.707)² = 0.5 + 0.5 = 1
      expect(result, closeTo(1.0, 0.001));
    });
  });
}