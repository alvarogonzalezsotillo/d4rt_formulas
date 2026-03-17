import 'dart:io';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:d4rt_formulas/formula_models.dart';
import 'package:d4rt_formulas/set_utils.dart';
import 'package:d4rt_formulas/error_handler.dart';

/// Service to handle import of formula elements from shared files or text
class ImportService {
  static final ImportService _instance = ImportService._internal();
  factory ImportService() => _instance;
  ImportService._internal();

  /// Parses shared text content as formula elements
  /// The text should be in the same format as files in ./assets/formulas
  List<FormulaElement> parseSharedText(String text) {
    try {
      final List<Object?> list = SetUtils.parseD4rtLiteral(text);
      
      final elements = <FormulaElement>[];
      for (final item in list) {
        if (item is Map) {
          // Try to parse as Formula first (has 'd4rtCode' field)
          if (item.containsKey('d4rtCode')) {
            elements.add(Formula.fromSet(item));
          } 
          // Try to parse as UnitSpec (has 'name' and 'baseUnit' or 'isBase')
          else if (item.containsKey('name')) {
            elements.add(UnitSpec.fromSet(item));
          }
          else {
            throw ArgumentError('Unknown element type: $item');
          }
        }
      }
      
      return elements;
    } catch (e, stack) {
      errorHandler.notify(e, stack);
      throw FormatException('Failed to parse shared text as formula elements: $e');
    }
  }

  /// Parses a .d4rtf file content as formula elements
  List<FormulaElement> parseD4rtfFile(String filePath) {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        throw FileSystemException('File not found', filePath);
      }
      
      final content = file.readAsStringSync();
      return parseSharedText(content);
    } catch (e, stack) {
      errorHandler.notify(e, stack);
      throw FormatException('Failed to parse .d4rtf file: $e');
    }
  }

  /// Listens for shared files (Android only for now)
  Stream<List<SharedMediaFile>> get sharedFilesStream {
    return ReceiveSharingIntent.instance.getMediaStream();
  }

  /// Gets initial shared media (for when app is launched via share)
  Future<List<SharedMediaFile>> getInitialSharedMedia() async {
    try {
      return await ReceiveSharingIntent.instance.getInitialMedia();
    } catch (e, stack) {
      errorHandler.notify(e, stack);
      return [];
    }
  }

  /// Gets shared text (for when app receives text via share)
  Future<String?> getSharedText() async {
    try {
      final media = await ReceiveSharingIntent.instance.getInitialMedia();
      // Note: In newer versions of receive_sharing_intent, TEXT type may not be available
      // We check if media exists and try to get the path
      if (media.isNotEmpty) {
        return media.first.path;
      }
      return null;
    } catch (e, stack) {
      errorHandler.notify(e, stack);
      return null;
    }
  }

  /// Clears the initial shared media after processing
  Future<void> clearInitialSharedMedia() async {
    try {
      // Note: resetInitialMedia() was removed in newer versions
      // The media is automatically cleared after being read
    } catch (e, stack) {
      errorHandler.notify(e, stack);
    }
  }
}
