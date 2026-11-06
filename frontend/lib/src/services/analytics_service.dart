import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:traveltrack/src/services/analytics_sdk_loader.dart';

/// Noms des événements envoyés à PostHog.
abstract final class AnalyticsEvents {
  static const userSignedUp = 'user_signed_up';
  static const userLoggedIn = 'user_logged_in';
  static const userLoggedOut = 'user_logged_out';
  static const oauthLoginStarted = 'oauth_login_started';
}

/// Point d'entrée unique vers PostHog, actif uniquement sur la version web.
///
/// La configuration se trouve dans `web/index.html`. Rien n'est envoyé sans le
/// consentement de l'utilisateur. Une panne d'analytics ne doit jamais gêner
/// l'application : chaque appel journalise ses erreurs sans les propager.
///
/// Ne jamais transmettre ici d'email, de nom, de coordonnées GPS ni de photo.
class AnalyticsService {
  AnalyticsService._();

  static final AnalyticsService instance = AnalyticsService._();

  bool _hasConsent = false;
  bool _isSdkLoaded = false;
  String? _currentUserId;
  String? _identifiedUserId;

  bool get _canSendData => kIsWeb && _hasConsent && _isSdkLoaded;

  /// Sans consentement, le SDK n'est même pas téléchargé : aucune requête ne
  /// part vers PostHog et rien n'est stocké dans le navigateur.
  Future<void> initialize({required bool hasConsent}) async {
    _hasConsent = hasConsent;
    if (!kIsWeb || !hasConsent) return;

    await _runSafely('initialize', () async => _loadSdkOnce());
  }

  Future<void> updateConsent({required bool hasConsent}) async {
    _hasConsent = hasConsent;
    if (!kIsWeb) return;

    await _runSafely('updateConsent', () async {
      if (hasConsent) {
        _loadSdkOnce();
        await Posthog().optIn();
        await _identifyCurrentUser();
      } else if (_isSdkLoaded) {
        // L'identité est oubliée pour ne pas relier un éventuel retour du
        // consentement à l'activité passée sur cet appareil.
        await Posthog().reset();
        await Posthog().optOut();
        _identifiedUserId = null;
      }
    });
  }

  void _loadSdkOnce() {
    if (_isSdkLoaded) return;
    loadAnalyticsSdk();
    _isSdkLoaded = true;
  }

  Future<void> identifyUser(String userId) async {
    _currentUserId = userId;
    await _runSafely('identifyUser', _identifyCurrentUser);
  }

  Future<void> resetUser() async {
    _currentUserId = null;
    _identifiedUserId = null;
    if (!_canSendData) return;
    await _runSafely('resetUser', Posthog().reset);
  }

  Future<void> captureEvent(
    String eventName, {
    Map<String, Object>? properties,
  }) async {
    if (!_canSendData) return;
    await _runSafely(
      'captureEvent',
      () => Posthog().capture(eventName: eventName, properties: properties),
    );
  }

  Future<void> captureScreen(String screenName) async {
    if (!_canSendData) return;
    await _runSafely(
      'captureScreen',
      () => Posthog().screen(screenName: screenName),
    );
  }

  Future<void> _identifyCurrentUser() async {
    final userId = _currentUserId;
    if (!_canSendData || userId == null || userId == _identifiedUserId) return;
    await Posthog().identify(userId: userId);
    _identifiedUserId = userId;
  }

  Future<void> _runSafely(
    String operationName,
    Future<void> Function() operation,
  ) async {
    try {
      await operation();
    } catch (analyticsError, stackTrace) {
      developer.log(
        '$operationName failed',
        name: 'AnalyticsService',
        error: analyticsError,
        stackTrace: stackTrace,
      );
    }
  }
}
