import 'package:flutter/material.dart';

/// Phrase suivie d'un lien, centrée (ex: "Tu as déjà un compte ? Se connecter").
class AuthLinkRow extends StatelessWidget {
  const AuthLinkRow({
    super.key,
    required this.message,
    required this.linkLabel,
    required this.onLinkPressed,
  });

  final String message;
  final String linkLabel;
  final VoidCallback onLinkPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            message,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          TextButton(
            onPressed: onLinkPressed,
            child: Text(
              linkLabel,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
