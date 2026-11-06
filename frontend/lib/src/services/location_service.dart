import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:traveltrack/src/models/user_location.dart';

/// L'autorisation de localisation a été retirée pendant le suivi.
class LocationPermissionRevokedException implements Exception {
  const LocationPermissionRevokedException();
}

/// Une mise à jour de position a échoué (signal, délai dépassé...). Le suivi
/// continue : la prochaine position valide arrivera dans le même flux.
class LocationUnavailableException implements Exception {
  const LocationUnavailableException(this.cause);

  final Object cause;
}

/// Accès à la position de l'appareil via `geolocator`. Ne gère pas les
/// autorisations : c'est le rôle de `PermissionService`.
class LocationService {
  static const _minimumDistanceBetweenUpdatesInMeters = 5;

  Future<bool> isLocationServiceEnabled() =>
      Geolocator.isLocationServiceEnabled();

  /// Suit la position en continu (équivalent de `watchPosition` sur le web).
  /// Les erreurs sont converties en [LocationPermissionRevokedException] ou
  /// [LocationUnavailableException].
  Stream<UserLocation> watchUserLocation() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: _minimumDistanceBetweenUpdatesInMeters,
    );

    return Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).transform(
      StreamTransformer<Position, UserLocation>.fromHandlers(
        handleData: (position, sink) => sink.add(
          UserLocation(
            latitude: position.latitude,
            longitude: position.longitude,
            accuracyInMeters: position.accuracy,
          ),
        ),
        handleError: (error, stackTrace, sink) => sink.addError(
          error is PermissionDeniedException
              ? const LocationPermissionRevokedException()
              : LocationUnavailableException(error),
          stackTrace,
        ),
      ),
    );
  }
}
