import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:traveltrack/src/constants/app_strings.dart';
import 'package:traveltrack/src/models/analytics_consent_status.dart';
import 'package:traveltrack/src/services/analytics_consent_storage.dart';
import 'package:traveltrack/src/services/analytics_service.dart';

class AnalyticsConsentViewModel extends ChangeNotifier {
  AnalyticsConsentViewModel({
    AnalyticsConsentStorage? consentStorage,
    AnalyticsService? analyticsService,
  }) : _consentStorage = consentStorage ?? AnalyticsConsentStorage(),
       _analyticsService = analyticsService ?? AnalyticsService.instance;

  final AnalyticsConsentStorage _consentStorage;
  final AnalyticsService _analyticsService;

  AnalyticsConsentStatus _status = AnalyticsConsentStatus.unanswered;
  AnalyticsConsentStatus get status => _status;

  bool get isUnanswered => _status == AnalyticsConsentStatus.unanswered;
  bool get hasConsent => _status == AnalyticsConsentStatus.granted;

  /// La mesure d'audience n'existe que sur la version web : les autres
  /// plateformes n'ont aucun choix à proposer.
  bool get isAnalyticsAvailable => kIsWeb;
  bool get isChoiceRequired => isAnalyticsAvailable && isUnanswered;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// En cas d'échec de lecture, le choix reste sans réponse : aucune donnée
  /// n'est envoyée et la question sera reposée.
  Future<void> loadSavedConsent() async {
    try {
      _status = await _consentStorage.readStatus();
    } catch (storageError, stackTrace) {
      _status = AnalyticsConsentStatus.unanswered;
      developer.log(
        'Reading analytics consent failed',
        name: 'AnalyticsConsentViewModel',
        error: storageError,
        stackTrace: stackTrace,
      );
    }
    notifyListeners();
  }

  Future<void> updateConsent({required bool hasConsent}) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();
    try {
      // Un refus s'applique avant l'enregistrement : il doit stopper l'envoi
      // même si l'enregistrement échoue. Un accord attend, lui, d'être enregistré.
      if (!hasConsent) {
        await _analyticsService.updateConsent(hasConsent: false);
      }
      await _consentStorage.saveConsent(isConsentGranted: hasConsent);
      if (hasConsent) {
        await _analyticsService.updateConsent(hasConsent: true);
      }
      _status = hasConsent
          ? AnalyticsConsentStatus.granted
          : AnalyticsConsentStatus.denied;
    } catch (storageError, stackTrace) {
      _errorMessage = AppStrings.analyticsConsentSaveError;
      developer.log(
        'Saving analytics consent failed',
        name: 'AnalyticsConsentViewModel',
        error: storageError,
        stackTrace: stackTrace,
      );
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}

/// Instance partagée par app_router.dart et les écrans de consentement, dans le
/// même esprit que `authViewModel`.
final AnalyticsConsentViewModel analyticsConsentViewModel =
    AnalyticsConsentViewModel();
