import 'package:d4rt_formulas/set_utils.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'package:flutter/services.dart' show rootBundle;

class CompileConstants {
  static Future<String> loadResourceAsString(String path) async {
    return await rootBundle.loadString(path, cache: false);
  }

  static Future<Map<String, String>> loadGeneratedCompileConstants() async {
    try {
      String arrayStringLiteral = await loadResourceAsString(
        "assets/compile_constants.d4rt",
      );
      var read = SetUtils.parseD4rtLiteral("[$arrayStringLiteral]");
      print(read);
      var map = read[0] as Map;
      return map.cast<String, String>();
    } catch (e, st) {
      print(e);
      print(st);
      return {};
    }
  }

  static Map<String, String>? _generatedCompileConstants;

  static Future<void> init() async {
    _generatedCompileConstants = await loadGeneratedCompileConstants();
  }

  static void _checkInit() {
    if (_generatedCompileConstants == null) {
      throw Exception("Call CompileConstants.init() before");
    }
  }

  static String buildHost() {
    _checkInit();
    return _generatedCompileConstants?["buildHost"] ?? "no build host info";
  }

  static String release() {
    _checkInit();
    return _generatedCompileConstants?["release"] ?? "no release info";
  }

  static bool isDebugBuild() {
    return kDebugMode;
  }

  static String buildTimestamp() {
    _checkInit();
    return _generatedCompileConstants?["buildTimestamp"] ??
        "no build timestamp info";
  }

  static bool isDatabaseBackend() {
    return !isWeb();
  }

  static bool isWeb() {
    return kIsWeb;
  }

  static bool isAndroid() {
    return !isWeb() && Platform.isAndroid;
  }

  static bool isLinux() {
    return !isWeb() && Platform.isLinux;
  }

  static bool isWindows() {
    return !isWeb() && Platform.isWindows;
  }
}
