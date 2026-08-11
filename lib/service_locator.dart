import 'package:d4rt_formulas/compile_constants.dart';
import 'package:get_it/get_it.dart';

import 'database/formulas_database.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  final useDatabase = CompileConstants.isDatabaseBackend();
  if (useDatabase) {
    locator.registerSingleton<FormulasDatabase>(getDatabase());
  }
}

FormulasDatabase getDatabase() {
  // Check if already registered to avoid recreating
  if (locator.isRegistered<FormulasDatabase>()) {
    return locator.get<FormulasDatabase>();
  }

  // Create new instance based on platform
  return FormulasDatabase();
}
