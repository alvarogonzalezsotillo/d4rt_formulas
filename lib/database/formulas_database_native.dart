import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io';


LazyDatabase openConnection() {
  return LazyDatabase(() async {
    // Determine the platform-specific database directory
    Directory dbDirectory;
    
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      final appSupportDir = await getApplicationSupportDirectory();
      dbDirectory = Directory(p.join(appSupportDir.path, 'd4rt_formulas'));
    } else {
      dbDirectory = await getApplicationDocumentsDirectory();
    }
    
    // Ensure the directory exists
    await dbDirectory.create(recursive: true);
    
    // Create the database file in the platform-specific directory
    final file = File(p.join(dbDirectory.path, 'formulas.sqlite'));
    print( "Database file path: ${file.path}");
    return NativeDatabase.createInBackground(file);
  });
}

