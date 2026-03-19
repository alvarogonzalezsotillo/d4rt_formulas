import 'package:d4rt_formulas/d4rt_formulas.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:highlight/languages/dart.dart';

import '../database/database_service.dart';
import '../service_locator.dart';

import '../services/import_service.dart';
import 'formula_list.dart';
import '../corpus.dart';
import '../defaults/default_corpus.dart';
import '../formula_models.dart' as models;
import 'import_preview_screen.dart';


/// Screen to import formula elements from text
class ImportFromTextScreen extends StatefulWidget {
  final Corpus corpus;

  const ImportFromTextScreen({super.key, required this.corpus});

  @override
  State<ImportFromTextScreen> createState() => _ImportFromTextScreenState();
}

class _ImportFromTextScreenState extends State<ImportFromTextScreen> {
  final CodeController _codeController = CodeController(language: dart, text: "// Insert code here...");
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    setState(() => _isLoading = true);

    try {
      final clipboardData = await Clipboard.getData('text/plain');
      if (clipboardData?.text != null) {
        _codeController.text = clipboardData!.text!;
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Clipboard is empty'), backgroundColor: Colors.orange));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error pasting from clipboard: $e'), backgroundColor: Colors.red));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _import() async {
    final text = _codeController.fullText;
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter or paste formula text'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final importService = ImportService();
      final elements = importService.parseSharedText(text);

      if (!mounted) return;

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImportPreviewScreen(elements: elements, corpus: widget.corpus),
        ),
      );

      if (result == true) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error parsing text: $e'), backgroundColor: Colors.red));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import from Text')),
      body: Column(
        children: [
          Expanded(
            child: CodeTheme(
              data: CodeThemeData(styles: monokaiSublimeTheme),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(child: CodeField(controller: _codeController)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _pasteFromClipboard,
                    icon: _isLoading
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.content_paste),
                    label: const Text('Paste'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _import,
                    icon: const Icon(Icons.library_add),
                    label: const Text('Import'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
