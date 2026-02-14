import 'package:get_it/get_it.dart';

import 'database/formulas_database.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerSingleton<FormulasDatabase>(getDatabase());
}

FormulasDatabase getDatabase() {
  // Check if already registered to avoid recreating
  if (locator.isRegistered<FormulasDatabase>()) {
    return locator.get<FormulasDatabase>();
  }
  
  // Create new instance based on platform
  return FormulasDatabase();
}