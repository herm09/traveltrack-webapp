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
  static const _userPosition = LatLng(48.8566, 2.3522); // mock

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
        return Icons.location_on;
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
    quests.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
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
                        color: Colors.blue.withOpacity(0.15),
                        borderColor: Colors.blue.withOpacity(0.3),
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
                            onTap: () {
                              setState(() {}); // pourrait scroller vers la quête sélectionnée
                              context.push('/trip/${quest.id}');
                            },
                            child: _QuestPin(
                              icon: _iconForCategory(quest.category),
                            ),
                          ),
                        );
                      }),
                      // Pin utilisateur (bleu, avec icône cloche/notif)
                      Marker(
                        point: _userPosition,
                        width: 46,
                        height: 46,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFF2F6FED),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.notifications,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SearchBar(),
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
                topOffsetForFilters: true,
              ),
            ),

            // --- Bouton géoloc (bas droite, au-dessus du bottom sheet) ---
            Positioned(
              right: 12,
              bottom: nearest != null ? 190 : 20,
              child: _RoundIconButton(
                icon: Icons.my_location,
                onTap: () {},
              ),
            ),

            // --- Bottom sheet "Quête à proximité" ---
            if (nearest != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _NearbyQuestSheet(quest: nearest),
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
      decoration: const BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey[500]),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher un lieu, une quête...',
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
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
  const _CategoryFilters({required this.selected, required this.onSelect});

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
          ...QuestCategory.values.map((cat) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _FilterChip(
                label: cat.label,
                isSelected: selected == cat,
                onTap: () => onSelect(cat),
              ),
            );
          }),
          // bouton filtres additionnels (icône sliders)
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
              ],
            ),
            child: const Icon(Icons.tune, size: 18, color: Colors.black87),
          ),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontSize: 13,
            fontWeight: FontWeight.w500,
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
    this.topOffsetForFilters = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool topOffsetForFilters;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: topOffsetForFilters ? 0 : 0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
            ],
          ),
          child: Icon(icon, color: Colors.black87, size: 20),
        ),
      ),
    );
  }
}

class _NearbyQuestSheet extends StatelessWidget {
  const _NearbyQuestSheet({required this.quest});

  final Quest quest;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Quête à proximité',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              const Icon(Icons.keyboard_arrow_up, size: 20, color: Colors.black54),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
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
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        quest.category.label,
                        style: const TextStyle(fontSize: 11, color: Colors.black54),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      quest.title,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${(quest.distanceKm * 1000).round()} m · +${quest.xp} XP',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => context.push('/trip/${quest.id}'),
                    child: const Text('Voir le détail'),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.bookmark_border, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
