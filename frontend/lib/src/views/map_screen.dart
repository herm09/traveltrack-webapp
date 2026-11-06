// path: lib/src/views/map_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:traveltrack/src/constants/location_strings.dart';
import 'package:traveltrack/src/viewmodels/map_location_viewmodel.dart';

import '../models/quest.dart';
import '../services/quest_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Centre affiché tant que la position de l'utilisateur est inconnue.
  static const _defaultMapCenter = LatLng(48.8566, 2.3522); // Paris
  static const _proximityCircleRadiusInMeters = 80.0;
  static const _userRecenterZoom = 16.0;

  List<Quest> _quests = [];
  String? _error;
  QuestCategory? _selectedCategory; // null = "Toutes"
  bool _isNearbySheetDismissed = false;

  final MapController _mapController = MapController();
  final MapLocationViewModel _locationViewModel = MapLocationViewModel();
  StreamSubscription<MapRecenterRequest>? _recenterRequestSubscription;
  bool _isMapReady = false;
  MapRecenterRequest? _recenterRequestWaitingForMap;

  @override
  void initState() {
    super.initState();
    _locationViewModel.addListener(_onUserLocationStateChanged);
    _recenterRequestSubscription = _locationViewModel.recenterRequests.listen(
      _applyRecenterRequest,
    );
    _locationViewModel.startTrackingIfAlreadyAllowed();
    _loadQuests();
  }

  @override
  void dispose() {
    _recenterRequestSubscription?.cancel();
    _locationViewModel.removeListener(_onUserLocationStateChanged);
    _locationViewModel.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _onUserLocationStateChanged() {
    if (mounted) setState(() {});
  }

  void _onMapReady() {
    _isMapReady = true;
    final waitingRecenterRequest = _recenterRequestWaitingForMap;
    _recenterRequestWaitingForMap = null;
    if (waitingRecenterRequest != null) {
      _applyRecenterRequest(waitingRecenterRequest);
    }
  }

  void _applyRecenterRequest(MapRecenterRequest recenterRequest) {
    if (!_isMapReady) {
      _recenterRequestWaitingForMap = recenterRequest;
      return;
    }
    final currentZoom = _mapController.camera.zoom;
    final targetZoom =
        recenterRequest.isRequestedByUser && currentZoom < _userRecenterZoom
        ? _userRecenterZoom
        : currentZoom;
    _mapController.move(
      LatLng(
        recenterRequest.location.latitude,
        recenterRequest.location.longitude,
      ),
      targetZoom,
    );
  }

  LatLng? get _userLatLng {
    final userLocation = _locationViewModel.currentLocation;
    if (userLocation == null) return null;
    return LatLng(userLocation.latitude, userLocation.longitude);
  }

  IconData get _locationButtonIcon {
    return _locationViewModel.hasLocationError
        ? Icons.location_disabled
        : Icons.my_location;
  }

  Future<void> _loadQuests() async {
    try {
      final quests = await QuestService.fetchQuests();
      setState(() {
        _quests = quests;
        _error = null;
      });
    } catch (e) {
      setState(() => _error = 'Impossible de charger les quêtes: $e');
    }
  }

  // Quests are fetched from Supabase without a distance (that depends on
  // where the user is standing), so it's computed live against the current
  // position instead of being read off the model.
  double _distanceKm(Quest quest) {
    final distanceOrigin = _userLatLng ?? _defaultMapCenter;
    final meters = Geolocator.distanceBetween(
      distanceOrigin.latitude,
      distanceOrigin.longitude,
      quest.lat,
      quest.lng,
    );
    return meters / 1000;
  }

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
    if (_selectedCategory == null) return _quests;
    return _quests.where((q) => q.category == _selectedCategory).toList();
  }

  Quest? get _nearestQuest {
    final quests = _filteredQuests;
    if (quests.isEmpty) return null;
    final sorted = [...quests]
      ..sort((a, b) => _distanceKm(a).compareTo(_distanceKm(b)));
    return sorted.first;
  }

  @override
  Widget build(BuildContext context) {
    final quests = _filteredQuests;
    final nearest = _isNearbySheetDismissed ? null : _nearestQuest;
    final userLatLng = _userLatLng;
    final isFollowingUser =
        _locationViewModel.isFollowingUser &&
        _locationViewModel.status == UserLocationStatus.tracking;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // --- Carte ---
            Positioned.fill(
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _defaultMapCenter,
                  initialZoom: 14,
                  onMapReady: _onMapReady,
                  onPositionChanged: (camera, hasGesture) {
                    if (hasGesture) _locationViewModel.onMapMovedByUser();
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.traveltrack.app',
                  ),
                  // Cercle de proximité autour de l'utilisateur
                  if (userLatLng != null)
                    CircleLayer(
                      circles: [
                        CircleMarker(
                          point: userLatLng,
                          radius: _proximityCircleRadiusInMeters,
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
                      if (userLatLng != null)
                        Marker(
                          point: userLatLng,
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
                    onSelect: (cat) => setState(() {
                      _selectedCategory = cat;
                      _isNearbySheetDismissed = false;
                    }),
                  ),
                  if (_locationViewModel.isErrorMessageVisible) ...[
                    const SizedBox(height: 10),
                    _LocationErrorBanner(
                      status: _locationViewModel.status,
                      onRetry: _locationViewModel.onRecenterButtonPressed,
                      onClose: _locationViewModel.dismissErrorMessage,
                    ),
                  ],
                  if (_error != null) ...[
                    const SizedBox(height: 10),
                    Material(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          _error!,
                          style: TextStyle(color: Colors.red.shade900),
                        ),
                      ),
                    ),
                  ],
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
                icon: _locationButtonIcon,
                iconColor: isFollowingUser
                    ? Theme.of(context).colorScheme.primary
                    : null,
                isLoading:
                    _locationViewModel.status == UserLocationStatus.locating,
                semanticLabel: LocationStrings.recenterButtonLabel,
                onTap: _locationViewModel.onRecenterButtonPressed,
              ),
            ),

            // --- Sheet quête à proximité ---
            if (nearest != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _NearbyQuestSheet(
                  quest: nearest,
                  distanceKm: _distanceKm(nearest),
                  onClose: () => setState(() => _isNearbySheetDismissed = true),
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
          ...QuestCategory.values.where((cat) => cat != QuestCategory.all).map((
            cat,
          ) {
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
    this.iconColor,
    this.isLoading = false,
    this.semanticLabel,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;
  final bool isLoading;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
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
          child: isLoading
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(icon, color: iconColor ?? Colors.black87, size: 22),
        ),
      ),
    );
  }
}

/// Message affiché quand la position de l'utilisateur ne peut pas être
/// obtenue, avec une action pour réessayer.
class _LocationErrorBanner extends StatelessWidget {
  const _LocationErrorBanner({
    required this.status,
    required this.onRetry,
    required this.onClose,
  });

  final UserLocationStatus status;
  final VoidCallback onRetry;
  final VoidCallback onClose;

  String get _message {
    return switch (status) {
      UserLocationStatus.serviceUnavailable =>
        LocationStrings.locationNotSupportedMessage,
      UserLocationStatus.positionUnavailable =>
        LocationStrings.positionUnavailableMessage,
      _ => LocationStrings.permissionRequiredMessage,
    };
  }

  String? get _hint {
    return status == UserLocationStatus.permissionBlocked
        ? LocationStrings.permissionBlockedHint
        : null;
  }

  String get _actionLabel {
    return status == UserLocationStatus.permissionDismissed
        ? LocationStrings.enableLocationAction
        : LocationStrings.retryAction;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hint = _hint;

    return Material(
      color: colorScheme.errorContainer,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 4, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Icon(
                    Icons.location_off_outlined,
                    size: 20,
                    color: colorScheme.onErrorContainer,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _message,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onErrorContainer,
                          ),
                        ),
                        if (hint != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            hint,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onErrorContainer,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  color: colorScheme.onErrorContainer,
                  tooltip: LocationStrings.closeMessageTooltip,
                  visualDensity: VisualDensity.compact,
                  onPressed: onClose,
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onRetry,
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.onErrorContainer,
                ),
                child: Text(_actionLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NearbyQuestSheet extends StatelessWidget {
  const _NearbyQuestSheet({
    required this.quest,
    required this.distanceKm,
    required this.onClose,
  });

  final Quest quest;
  final double distanceKm;
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
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const SizedBox(width: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: quest.imageUrl.isEmpty
                    ? Container(width: 56, height: 56, color: Colors.grey[200])
                    : Image.network(
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
                      '${(distanceKm * 1000).round()} m · +${quest.xp} XP',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
