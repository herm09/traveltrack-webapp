// path: lib/src/views/trip_detail_screen.dart
import 'package:flutter/material.dart';

import '../services/data/mock_data.dart';
import '../models/quest.dart';

class TripDetailScreen extends StatelessWidget {
  const TripDetailScreen({super.key, required this.tripId});

  final String tripId;

  @override
  Widget build(BuildContext context) {
    final quest = MockData.quests.firstWhere(
      (q) => q.id == tripId,
      orElse: () => MockData.quests.first,
    );

    return Scaffold(
      appBar: AppBar(title: Text(quest.title)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              quest.imageUrl,
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(quest.title, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Chip(label: Text(quest.category.label)),
                  const SizedBox(height: 16),
                  Text(quest.description, style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.directions_walk, size: 20),
                      const SizedBox(width: 4),
                      Text('${quest.distanceKm} km'),
                      const SizedBox(width: 16),
                      const Icon(Icons.star, size: 20, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text('${quest.xp} XP'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        // TODO: logique de démarrage/validation de quête
                      },
                      child: Text(
                        quest.status == QuestStatus.completed
                            ? 'Quête terminée'
                            : quest.status == QuestStatus.inProgress
                                ? 'Continuer la quête'
                                : 'Démarrer la quête',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
