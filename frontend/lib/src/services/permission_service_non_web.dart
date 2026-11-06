import 'package:geolocator/geolocator.dart';

import 'permission_service_types.dart';

class PermissionService {
  static final PermissionService _instance = PermissionService._();
  PermissionService._();
  static PermissionService get instance => _instance;

  Future<AppPermissionStatus> checkLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    return _fromGeolocatorPermission(permission);
  }

  Future<bool> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  Future<AppPermissionStatus> checkCameraPermission() async =>
      AppPermissionStatus.prompt;

  Future<AppPermissionStatus> checkNotificationPermission() async =>
      AppPermissionStatus.prompt;

  Future<bool> requestNotificationPermission() async => false;

  Future<bool> requestCameraPermission() async => false;

  AppPermissionStatus _fromGeolocatorPermission(LocationPermission p) {
    return switch (p) {
      LocationPermission.always ||
      LocationPermission.whileInUse =>
        AppPermissionStatus.granted,
      LocationPermission.deniedForever => AppPermissionStatus.denied,
      _ => AppPermissionStatus.prompt,
    };
  }
}
