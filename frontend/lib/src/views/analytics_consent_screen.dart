import 'package:flutter/material.dart';
import 'package:traveltrack/src/constants/app_strings.dart';
import 'package:traveltrack/src/viewmodels/analytics_consent_viewmodel.dart';
import 'package:traveltrack/src/widgets/auth_submit_section.dart';

/// Recueille le choix de mesure d'audience au premier lancement. Le routeur
/// quitte cet écran dès que le choix est enregistré.
class AnalyticsConsentScreen extends StatelessWidget {
  const AnalyticsConsentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: analyticsConsentViewModel,
          builder: (context, _) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.analyticsConsentTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(AppStrings.analyticsConsentDescription),
                const SizedBox(height: 12),
                Text(
                  AppStrings.analyticsConsentChangeLater,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),
                AuthSubmitSection(
                  label: AppStrings.analyticsConsentAccept,
                  isLoading: analyticsConsentViewModel.isSaving,
                  errorMessage: analyticsConsentViewModel.errorMessage,
                  onSubmit: () =>
                      analyticsConsentViewModel.updateConsent(hasConsent: true),
                ),
                const SizedBox(height: 12),
                AuthSubmitSection(
                  label: AppStrings.analyticsConsentDecline,
                  isLoading: analyticsConsentViewModel.isSaving,
                  onSubmit: () => analyticsConsentViewModel.updateConsent(
                    hasConsent: false,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
