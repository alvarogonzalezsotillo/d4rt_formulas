import 'package:d4rt_formulas/error_handler.dart';
import 'package:test/test.dart';

void main() {
  group('ErrorHandler', () {
    test('should print exceptions to stdout', () {
      final errors = <Object>[];
      final stacks = <StackTrace?>[];
      
      // Capture errors instead of printing them
      errorHandler.onError = (error, [stackTrace]) {
        errors.add(error);
        stacks.add(stackTrace);
      };
      
      // Simulate an exception being caught
      try {
        throw Exception('Test exception');
      } catch (e, s) {
        errorHandler.notify(e, s);
      }
      
      expect(errors.length, 1);
      expect(errors.first.toString(), 'Exception: Test exception');
      expect(stacks.length, 1);
    });

    test('should handle errors in handleError method', () {
      final errors = <Object>[];
      errorHandler.onError = (error, [stackTrace]) {
        errors.add(error);
      };
      
      int result = ErrorHandler().handleError(() => 42, defaultValue: 0);
      expect(result, 42);
      
      result = ErrorHandler().handleError(() {
        throw Exception('Handled exception');
      }, defaultValue: 100);
      
      expect(result, 100);
      expect(errors.length, 1);
    });

    test('should rethrow exceptions when no default value provided', () {
      final errors = <Object>[];
      errorHandler.onError = (error, [stackTrace]) {
        errors.add(error);
      };
      
      expect(() {
        ErrorHandler().handleError(() {
          throw Exception('Rethrown exception');
        });
      }, throwsA(const TypeMatcher<Exception>()));
      
      expect(errors.length, 1);
    });
  });
}