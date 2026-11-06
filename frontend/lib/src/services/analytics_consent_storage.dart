import 'package:shared_preferences/shared_preferences.dart';
import 'package:traveltrack/src/models/analytics_consent_status.dart';

/// Conserve le choix de mesure d'audience sur l'appareil.
class AnalyticsConsentStorage {
  static const _consentGrantedKey = 'analytics_consent_granted';

  Future<AnalyticsConsentStatus> readStatus() async {
    final preferences = await SharedPreferences.getInstance();
    final isConsentGranted = preferences.getBool(_consentGrantedKey);
    if (isConsentGranted == null) return AnalyticsConsentStatus.unanswered;
    return isConsentGranted
        ? AnalyticsConsentStatus.granted
        : AnalyticsConsentStatus.denied;
  }

  Future<void> saveConsent({required bool isConsentGranted}) async {
    final preferences = await SharedPreferences.getInstance();
    final isSaved = await preferences.setBool(
      _consentGrantedKey,
      isConsentGranted,
    );
    if (!isSaved) {
      throw StateError('Analytics consent could not be saved.');
    }
  }
}
