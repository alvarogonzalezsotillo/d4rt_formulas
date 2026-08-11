import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

late File? _cachedFile;

Future<Directory> _directory() async {
  // Determine the platform-specific database directory
  Directory dbDirectory;

  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    final appSupportDir = await getApplicationSupportDirectory();
    dbDirectory = Directory(p.join(appSupportDir.path, 'd4rt_formulas'));
  } else {
    dbDirectory = await getApplicationDocumentsDirectory();
  }
  return dbDirectory;
}

Future<File> _file() async {
  final dbDirectory = await _directory();
  final ret = File(p.join(dbDirectory.path, 'formulas.sqlite'));
  _cachedFile = ret;
  return ret;
}

String openConnectionStorage() {
  if (_cachedFile == null) {
    throw Exception("Call openConnection first");
  }
  return _cachedFile!.path;
}

LazyDatabase openConnection() {
  return LazyDatabase(() async {
    final dbDirectory = await _directory();

    final file = await _file();

    // Ensure the directory exists
    await dbDirectory.create(recursive: true);

    // Create the database file in the platform-specific directory
    print("Database file path: ${file.path}");
    return NativeDatabase.createInBackground(file);
  });
}
