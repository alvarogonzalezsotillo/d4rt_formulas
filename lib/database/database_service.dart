import 'package:get_it/get_it.dart';

// Conditionally import the correct database file based on platform
import 'formulas_database.dart'
    if (dart.library.html) 'formulas_database_web.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerSingleton<FormulasDatabase>(FormulasDatabase());
}

FormulasDatabase getDatabase() {
  return locator<FormulasDatabase>();
}