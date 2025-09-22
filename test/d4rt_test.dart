import 'package:test/test.dart';
import 'package:d4rt/d4rt.dart';
import 'dart:math' as Math;


main(){
  test('Access to Math', () {

      final completeSource = """
        import  'dart:math';
        main() => sin(42);

      """;
      final interpreter = D4rt();
      final result = interpreter.execute(source: completeSource);

      expect(result, Math.sin(42));
  });

  test('Access to IO', () {

    final completeSource = """
       import 'dart:io';

       main() {
        File file = File('/etc/passwd');
        String contents = file.readAsStringSync();
        return contents;
       }
      """;
    final interpreter = D4rt();
    final result = interpreter.execute(source: completeSource);

    expect(result, contains("root"));
  });

}
