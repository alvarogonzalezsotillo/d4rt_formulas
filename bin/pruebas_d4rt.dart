import 'package:d4rt_formulas/d4rt_formulas.dart' as pruebas_d4rt;
import 'package:d4rt/d4rt.dart';

void main() {
  final code = '''
    int fib(int n) {
      if (n <= 1) return n;
      return fib(n - 1) + fib(n - 2);
    }
    main() {
      return fib(6);
    }
  ''';

  final interpreter = D4rt();
  final result = interpreter.execute(source: code);
  print('Result: $result'); // Result: 8
}
