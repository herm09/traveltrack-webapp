// path: lib/src/views/map_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../services/data/mock_data.dart';
import '../models/quest.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const _userPosition = LatLng(48.8566, 2.3522); // Paris - à adapter avec localisation réelle

  QuestCategory? _selectedCategory; // null = "Toutes"

  IconData _iconForCategory(QuestCategory category) {
    switch (category) {
      case QuestCategory.histoire:
        return Icons.star;
      case QuestCategory.gastro:
        return Icons.restaurant;
      case QuestCategory.social:
        return Icons.music_note;
      case QuestCategory.sport:
        return Icons.directions_run;
      case QuestCategory.nature:
        return Icons.park;
      case QuestCategory.culture:
        return Icons.museum;
      case QuestCategory.all:
        return Icons.apps;
    }
  }

  List<Quest> get _filteredQuests {
    final all = MockData.quests;
    if (_selectedCategory == null) return all;
    return all.where((q) => q.category == _selectedCategory).toList();
  }

  Quest? get _nearestQuest {
    final quests = _filteredQuests;
    if (quests.isEmpty) return null;
    return quests.first;
  }

  @override
  Widget build(BuildContext context) {
    final quests = _filteredQuests;
    final nearest = _nearestQuest;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // --- Carte ---
            Positioned.fill(
              child: FlutterMap(
                options: const MapOptions(
                  initialCenter: _userPosition,
                  initialZoom: 14,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.traveltrack.app',
                  ),
                  // Cercle de précision GPS
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: _userPosition,
                        radius: 80,
                        useRadiusInMeter: true,
                        color: const Color(0x332F6FED),
                        borderColor: const Color(0xFF2F6FED),
                        borderStrokeWidth: 1,
                      ),
                    ],
                  ),
                  MarkerLayer(
                    markers: [
                      // Pins des quêtes
                      ...quests.map((quest) {
                        return Marker(
                          point: LatLng(quest.lat, quest.lng),
                          width: 40,
                          height: 40,
                          child: GestureDetector(
                            onTap: () => context.push('/quest/${quest.id}'),
                            child: _QuestPin(
                              icon: _iconForCategory(quest.category),
                            ),
                          ),
                        );
                      }),
                      // Position utilisateur
                      Marker(
                        point: _userPosition,
                        width: 46,
                        height: 46,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF2F6FED),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.my_location,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // --- Barre de recherche + filtres ---
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Column(
                children: [
                  const _SearchBar(),
                  const SizedBox(height: 10),
                  _CategoryFilters(
                    selected: _selectedCategory,
                    onSelect: (cat) => setState(() => _selectedCategory = cat),
                  ),
                ],
              ),
            ),

            // --- Bouton boussole (haut droite) ---
            Positioned(
              top: 12,
              right: 12,
              child: _RoundIconButton(
                icon: Icons.explore_outlined,
                onTap: () {},
              ),
            ),

            // --- Bouton localisation ---
            Positioned(
              right: 12,
              bottom: nearest != null ? 190 : 20,
              child: _RoundIconButton(
                icon: Icons.my_location,
                onTap: () {},
              ),
            ),

            // --- Sheet quête à proximité ---
            if (nearest != null)
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: _NearbyQuestSheet(
                  quest: nearest,
                  onClose: () => setState(() {}),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _QuestPin extends StatelessWidget {
  const _QuestPin({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(Icons.search, color: Colors.grey[500]),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Rechercher une quête...',
                border: InputBorder.none,
                isCollapsed: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryFilters extends StatelessWidget {
  const _CategoryFilters({
    required this.selected,
    required this.onSelect,
  });

  final QuestCategory? selected;
  final ValueChanged<QuestCategory?> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _FilterChip(
            label: 'Toutes',
            isSelected: selected == null,
            onTap: () => onSelect(null),
          ),
          const SizedBox(width: 8),
          ...QuestCategory.values
              .where((cat) => cat != QuestCategory.all)
              .map((cat) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _FilterChip(
                label: cat.label,
                isSelected: selected == cat,
                onTap: () => onSelect(cat),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.black87, size: 22),
      ),
    );
  }
}

class _NearbyQuestSheet extends StatelessWidget {
  const _NearbyQuestSheet({
    required this.quest,
    required this.onClose,
  });

  final Quest quest;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const SizedBox(width: 16),
              const Icon(Icons.location_on, size: 16, color: Colors.black54),
              const SizedBox(width: 4),
              Text(
                'Quête à proximité',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const SizedBox(width: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  quest.imageUrl,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        quest.category.label,
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      quest.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${quest.distanceKm.toStringAsFixed(1)} km • ${quest.xp} XP',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: onClose,
              ),
              const SizedBox(width: 8),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    height: 44,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      onPressed: () => context.push('/quest/${quest.id}'),
                      child: const Text('Faire la quête'),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(22),
                ),
                child: IconButton(
                  icon: const Icon(Icons.directions, size: 20),
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
