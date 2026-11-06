import 'package:flutter/material.dart';

/// Bouton principal d'un formulaire, avec ses états de chargement, d'erreur et
/// de succès. [onSubmit] à null désactive le bouton.
class AuthSubmitSection extends StatelessWidget {
  const AuthSubmitSection({
    super.key,
    required this.label,
    required this.onSubmit,
    required this.isLoading,
    this.errorMessage,
    this.successMessage,
  });

  final String label;
  final VoidCallback? onSubmit;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentErrorMessage = errorMessage;
    final currentSuccessMessage = successMessage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (currentErrorMessage != null) ...[
          Text(currentErrorMessage, style: TextStyle(color: colorScheme.error)),
          const SizedBox(height: 12),
        ],
        if (currentSuccessMessage != null) ...[
          Text(
            currentSuccessMessage,
            style: TextStyle(color: colorScheme.primary),
          ),
          const SizedBox(height: 12),
        ],
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: isLoading ? null : onSubmit,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(label),
          ),
        ),
      ],
    );
  }
}
