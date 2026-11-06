import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traveltrack/src/models/analytics_consent_status.dart';
import 'package:traveltrack/src/services/analytics_consent_storage.dart';
import 'package:traveltrack/src/services/analytics_service.dart';
import 'package:traveltrack/src/viewmodels/analytics_consent_viewmodel.dart';

class _RecordingAnalyticsService implements AnalyticsService {
  final List<bool> consentUpdates = [];

  @override
  Future<void> updateConsent({required bool hasConsent}) async {
    consentUpdates.add(hasConsent);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FailingConsentStorage extends AnalyticsConsentStorage {
  @override
  Future<AnalyticsConsentStatus> readStatus() async {
    throw StateError('read failed');
  }

  @override
  Future<void> saveConsent({required bool isConsentGranted}) async {
    throw StateError('save failed');
  }
}

void main() {
  late _RecordingAnalyticsService analyticsService;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    analyticsService = _RecordingAnalyticsService();
  });

  AnalyticsConsentViewModel buildViewModel({
    AnalyticsConsentStorage? consentStorage,
  }) {
    return AnalyticsConsentViewModel(
      consentStorage: consentStorage ?? AnalyticsConsentStorage(),
      analyticsService: analyticsService,
    );
  }

  test('a first launch has no consent', () async {
    final viewModel = buildViewModel();

    await viewModel.loadSavedConsent();

    expect(viewModel.isUnanswered, isTrue);
    expect(viewModel.hasConsent, isFalse);
    expect(analyticsService.consentUpdates, isEmpty);
  });

  test('accepting enables analytics and survives a restart', () async {
    final viewModel = buildViewModel();

    await viewModel.updateConsent(hasConsent: true);

    expect(viewModel.hasConsent, isTrue);
    expect(analyticsService.consentUpdates, [true]);

    final restartedViewModel = buildViewModel();
    await restartedViewModel.loadSavedConsent();
    expect(restartedViewModel.status, AnalyticsConsentStatus.granted);
  });

  test('declining disables analytics and survives a restart', () async {
    final viewModel = buildViewModel();

    await viewModel.updateConsent(hasConsent: false);

    expect(viewModel.status, AnalyticsConsentStatus.denied);
    expect(analyticsService.consentUpdates, [false]);

    final restartedViewModel = buildViewModel();
    await restartedViewModel.loadSavedConsent();
    expect(restartedViewModel.status, AnalyticsConsentStatus.denied);
  });

  test('an unreadable choice counts as unanswered', () async {
    final viewModel = buildViewModel(consentStorage: _FailingConsentStorage());

    await viewModel.loadSavedConsent();

    expect(viewModel.isUnanswered, isTrue);
    expect(viewModel.hasConsent, isFalse);
  });

  test('accepting does not enable analytics if saving fails', () async {
    final viewModel = buildViewModel(consentStorage: _FailingConsentStorage());

    await viewModel.updateConsent(hasConsent: true);

    expect(viewModel.hasConsent, isFalse);
    expect(viewModel.errorMessage, isNotNull);
    expect(viewModel.isSaving, isFalse);
    expect(analyticsService.consentUpdates, isEmpty);
  });

  test('declining stops analytics even if saving fails', () async {
    final viewModel = buildViewModel(consentStorage: _FailingConsentStorage());

    await viewModel.updateConsent(hasConsent: false);

    expect(viewModel.errorMessage, isNotNull);
    expect(analyticsService.consentUpdates, [false]);
  });

  test('a new attempt clears the previous error', () async {
    final failingViewModel = buildViewModel(
      consentStorage: _FailingConsentStorage(),
    );
    final errorMessagesWhileSaving = <String?>[];
    failingViewModel.addListener(() {
      if (failingViewModel.isSaving) {
        errorMessagesWhileSaving.add(failingViewModel.errorMessage);
      }
    });

    await failingViewModel.updateConsent(hasConsent: true);
    await failingViewModel.updateConsent(hasConsent: true);

    expect(errorMessagesWhileSaving, [null, null]);
  });
}
