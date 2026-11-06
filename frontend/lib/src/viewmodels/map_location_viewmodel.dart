import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:traveltrack/src/models/user_location.dart';
import 'package:traveltrack/src/services/location_service.dart';
import 'package:traveltrack/src/services/permission_service.dart';

enum UserLocationStatus {
  /// Suivi pas encore démarré : l'autorisation n'a jamais été demandée.
  notStarted,

  /// Demande d'autorisation ou attente de la première position.
  locating,

  /// Position reçue, mise à jour en continu.
  tracking,

  /// La demande a été fermée sans réponse : on peut la reproposer.
  permissionDismissed,

  /// Refus enregistré : le navigateur ne reposera plus la question.
  permissionBlocked,

  /// Le navigateur / l'appareil ne fournit pas de géolocalisation.
  serviceUnavailable,

  /// Autorisation accordée mais position impossible à obtenir.
  positionUnavailable,
}

/// Demande à la vue de recentrer la carte sur [location].
class MapRecenterRequest {
  const MapRecenterRequest({
    required this.location,
    required this.isRequestedByUser,
  });

  final UserLocation location;

  /// Vrai après un appui sur le bouton « recentrer » ; faux quand la carte
  /// suit simplement les déplacements de l'utilisateur.
  final bool isRequestedByUser;
}

/// Gère la position en temps réel de l'utilisateur sur la carte : autorisation,
/// suivi continu, et mode « suivi » à la manière de Plans (la carte suit
/// l'utilisateur jusqu'à ce qu'il la déplace au doigt).
class MapLocationViewModel extends ChangeNotifier {
  MapLocationViewModel({
    LocationService? locationService,
    PermissionService? permissionService,
  }) : _locationService = locationService ?? LocationService(),
       _permissionService = permissionService ?? PermissionService.instance;

  static const _errorStatuses = {
    UserLocationStatus.permissionDismissed,
    UserLocationStatus.permissionBlocked,
    UserLocationStatus.serviceUnavailable,
    UserLocationStatus.positionUnavailable,
  };

  final LocationService _locationService;
  final PermissionService _permissionService;
  final StreamController<MapRecenterRequest> _recenterRequestsController =
      StreamController<MapRecenterRequest>.broadcast();
  StreamSubscription<UserLocation>? _userLocationSubscription;
  bool _isDisposed = false;
  bool _isUserRecenterPending = false;

  UserLocationStatus _status = UserLocationStatus.notStarted;
  UserLocationStatus get status => _status;

  UserLocation? _currentLocation;
  UserLocation? get currentLocation => _currentLocation;

  bool _isFollowingUser = false;
  bool get isFollowingUser => _isFollowingUser;

  bool _isErrorMessageDismissed = false;
  bool get hasLocationError => _errorStatuses.contains(_status);
  bool get isErrorMessageVisible =>
      hasLocationError && !_isErrorMessageDismissed;

  Stream<MapRecenterRequest> get recenterRequests =>
      _recenterRequestsController.stream;

  /// À l'ouverture de la carte : démarre le suivi uniquement si l'accès est
  /// déjà autorisé, sans jamais afficher de demande.
  Future<void> startTrackingIfAlreadyAllowed() {
    _isFollowingUser = true;
    return _startTracking(canRequestPermission: false);
  }

  /// Bouton « recentrer » : demande l'autorisation si besoin, puis centre la
  /// carte sur l'utilisateur et réactive le suivi.
  Future<void> onRecenterButtonPressed() async {
    if (_status == UserLocationStatus.locating) return;

    _isFollowingUser = true;
    final location = _currentLocation;
    if (_status == UserLocationStatus.tracking && location != null) {
      _emitRecenterRequest(location, isRequestedByUser: true);
      _notifyListenersIfActive();
      return;
    }

    _isUserRecenterPending = true;
    await _startTracking(canRequestPermission: true);
  }

  /// L'utilisateur a déplacé la carte au doigt : on arrête de la recentrer
  /// automatiquement jusqu'au prochain appui sur le bouton.
  void onMapMovedByUser() {
    if (!_isFollowingUser) return;
    _isFollowingUser = false;
    _notifyListenersIfActive();
  }

  void dismissErrorMessage() {
    _isErrorMessageDismissed = true;
    _notifyListenersIfActive();
  }

  Future<void> _startTracking({required bool canRequestPermission}) async {
    await _stopTracking();
    _setStatus(UserLocationStatus.locating);

    try {
      final isServiceEnabled = await _locationService
          .isLocationServiceEnabled();
      if (!isServiceEnabled) {
        _setStatus(UserLocationStatus.serviceUnavailable);
        return;
      }

      final permissionStatus = await _permissionService
          .checkLocationPermission();
      if (permissionStatus == AppPermissionStatus.denied) {
        _setStatus(UserLocationStatus.permissionBlocked);
        return;
      }

      if (permissionStatus == AppPermissionStatus.prompt) {
        if (!canRequestPermission) {
          _setStatus(UserLocationStatus.notStarted);
          return;
        }
        final isPermissionGranted = await _permissionService
            .requestLocationPermission();
        if (!isPermissionGranted) {
          final permissionStatusAfterRequest = await _permissionService
              .checkLocationPermission();
          _setStatus(
            permissionStatusAfterRequest == AppPermissionStatus.denied
                ? UserLocationStatus.permissionBlocked
                : UserLocationStatus.permissionDismissed,
          );
          return;
        }
      }

      if (_isDisposed) return;
      _userLocationSubscription = _locationService.watchUserLocation().listen(
        _onUserLocationReceived,
        onError: _onUserLocationError,
      );
    } catch (_) {
      _setStatus(UserLocationStatus.positionUnavailable);
    }
  }

  void _onUserLocationReceived(UserLocation location) {
    _currentLocation = location;
    _status = UserLocationStatus.tracking;
    if (_isFollowingUser) {
      _emitRecenterRequest(location, isRequestedByUser: _isUserRecenterPending);
    }
    _isUserRecenterPending = false;
    _notifyListenersIfActive();
  }

  void _onUserLocationError(Object error) {
    _isUserRecenterPending = false;
    if (error is LocationPermissionRevokedException) {
      _currentLocation = null;
      unawaited(_stopTracking());
      _setStatus(UserLocationStatus.permissionBlocked);
      return;
    }
    // Erreur passagère : on garde la dernière position connue et le flux
    // reste ouvert pour recevoir la suivante.
    _setStatus(UserLocationStatus.positionUnavailable);
  }

  Future<void> _stopTracking() async {
    final subscription = _userLocationSubscription;
    _userLocationSubscription = null;
    try {
      await subscription?.cancel();
    } catch (_) {
      // L'annulation d'un flux déjà fermé n'a pas d'impact pour l'utilisateur.
    }
  }

  void _emitRecenterRequest(
    UserLocation location, {
    required bool isRequestedByUser,
  }) {
    if (_isDisposed) return;
    _recenterRequestsController.add(
      MapRecenterRequest(
        location: location,
        isRequestedByUser: isRequestedByUser,
      ),
    );
  }

  void _setStatus(UserLocationStatus newStatus) {
    if (newStatus != _status) _isErrorMessageDismissed = false;
    _status = newStatus;
    _notifyListenersIfActive();
  }

  void _notifyListenersIfActive() {
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    unawaited(_stopTracking());
    unawaited(_recenterRequestsController.close());
    super.dispose();
  }
}
