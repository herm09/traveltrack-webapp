// path: lib/src/views/quest_list_screen.dart
import 'package:flutter/material.dart';

class QuestListScreen extends StatelessWidget {
  const QuestListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quêtes'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Liste de quêtes',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }
}
