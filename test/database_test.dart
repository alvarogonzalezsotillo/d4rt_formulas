import 'package:flutter_test/flutter_test.dart';
import 'package:d4rt_formulas/service_locator.dart';

void main() {
  setUp(() {
    setupLocator();
  });

  test('Database service can be initialized', () {
    final database = getDatabase();
    expect(database, isNotNull);
  });
}
