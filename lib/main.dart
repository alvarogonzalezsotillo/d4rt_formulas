import 'package:d4rt_formulas/formula_models.dart';
import 'package:flutter/material.dart';

import 'package:resource_portable/resource.dart' show Resource;
import 'dart:convert';

import 'ai/formula_screen.dart';
import 'ai/formula_list.dart';
import 'corpus.dart';
import 'defaults/default_corpus.dart';

void main() {
  runApp(MaterialApp(
    home: FutureBuilder<Corpus>(
      future: createDefaultCorpus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Center(child: Text('Error loading units: ${snapshot.error}'));
          }
          return Scaffold(
            appBar: AppBar(title: const Text('Formulas')),
            body: FormulaList(
              corpus: snapshot.data!,
              formulas: snapshot.data!.getFormulas(),
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    ),
  ));
}


