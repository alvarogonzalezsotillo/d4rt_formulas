import 'package:d4rt_formulas/formula_models.dart';
import 'package:flutter/material.dart';

import 'package:resource_portable/resource.dart' show Resource;
import 'dart:convert';

import 'ai/formula_screen.dart';
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
            body: ListView.builder(
              itemCount: snapshot.data!.getFormulas().length,
              itemBuilder: (context, index) {
                final formula = snapshot.data!.getFormulas()[index];
                return ListTile(
                  title: Text(formula.name),
                  subtitle: Text(formula.description ?? ''),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FormulaScreen(
                          formula: formula,
                          corpus: snapshot.data!,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    ),
  ));
}


