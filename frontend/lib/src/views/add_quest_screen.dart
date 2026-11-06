import 'package:flutter/material.dart';

class AddQuestScreen extends StatelessWidget {
  const AddQuestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter une quête')),
      body: const Center(
        child: Text('Formulaire d\'ajout de quête (à venir)'),
      ),
    );
  }
}
