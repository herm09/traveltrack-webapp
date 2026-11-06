import 'package:flutter/material.dart';
import 'package:traveltrack/src/constants/app_strings.dart';
import 'package:traveltrack/src/viewmodels/analytics_consent_viewmodel.dart';

/// Permet de modifier à tout moment le choix de mesure d'audience.
class AnalyticsConsentTile extends StatelessWidget {
  const AnalyticsConsentTile({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: analyticsConsentViewModel,
      builder: (context, _) {
        final errorMessage = analyticsConsentViewModel.errorMessage;
        return SwitchListTile(
          title: const Text(AppStrings.analyticsConsentSettingTitle),
          subtitle: errorMessage == null
              ? const Text(AppStrings.analyticsConsentSettingDescription)
              : Text(errorMessage, style: TextStyle(color: colorScheme.error)),
          value: analyticsConsentViewModel.hasConsent,
          onChanged: analyticsConsentViewModel.isSaving
              ? null
              : (isEnabled) => analyticsConsentViewModel.updateConsent(
                  hasConsent: isEnabled,
                ),
        );
      },
    );
  }
}
