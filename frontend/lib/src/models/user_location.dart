/// Position de l'utilisateur telle que l'app la manipule, indépendante du
/// package de géolocalisation utilisé pour l'obtenir.
class UserLocation {
  const UserLocation({
    required this.latitude,
    required this.longitude,
    required this.accuracyInMeters,
  });

  final double latitude;
  final double longitude;

  /// Rayon d'incertitude renvoyé par le navigateur / l'appareil.
  final double accuracyInMeters;
}
