import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import 'permission_service_types.dart';

@JS('navigator.permissions')
external _NavigatorPermissions get _navigatorPermissions;

extension type _NavigatorPermissions._(JSObject _) implements JSObject {
  external JSPromise<_PermissionStatus> query(JSObject descriptor);
}

extension type _PermissionStatus._(JSObject _) implements JSObject {
  external String get state;
}

@JS('navigator.mediaDevices')
external _MediaDevices get _mediaDevices;

@JS('Notification.permission')
external String get _notificationPermission;

@JS('Notification.requestPermission')
external JSPromise<JSString> _requestNotificationPermission();

extension type _MediaDevices._(JSObject _) implements JSObject {
  external JSPromise<JSObject> getUserMedia(JSObject constraints);
}

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

  Future<AppPermissionStatus> checkCameraPermission() async {
    try {
      final descriptor = {'name': 'camera'}.jsify() as JSObject;
      final status = await _navigatorPermissions.query(descriptor).toDart;
      return _fromWebPermissionState(status.state);
    } catch (_) {
      return AppPermissionStatus.prompt;
    }
  }

  Future<AppPermissionStatus> checkNotificationPermission() async {
    try {
      return _fromWebPermissionState(_notificationPermission);
    } catch (_) {
      return AppPermissionStatus.prompt;
    }
  }

  Future<bool> requestNotificationPermission() async {
    try {
      final result = await _requestNotificationPermission().toDart;
      return result.toDart == 'granted';
    } catch (_) {
      return false;
    }
  }

  Future<bool> requestCameraPermission() async {
    try {
      final constraints = {'video': true}.jsify() as JSObject;
      final stream = await _mediaDevices.getUserMedia(constraints).toDart;
      final tracks = stream.callMethod('getTracks'.toJS) as JSArray<JSObject>;
      for (final track in tracks.toDart) {
        track.callMethod('stop'.toJS);
      }
      return true;
    } catch (e) {
      debugPrint('Camera permission error: $e');
      return false;
    }
  }

  AppPermissionStatus _fromGeolocatorPermission(LocationPermission p) {
    return switch (p) {
      LocationPermission.always ||
      LocationPermission.whileInUse =>
        AppPermissionStatus.granted,
      LocationPermission.deniedForever => AppPermissionStatus.denied,
      _ => AppPermissionStatus.prompt,
    };
  }

  AppPermissionStatus _fromWebPermissionState(String state) {
    return switch (state) {
      'granted' => AppPermissionStatus.granted,
      'denied' => AppPermissionStatus.denied,
      _ => AppPermissionStatus.prompt,
    };
  }
}
