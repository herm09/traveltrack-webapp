/// Règles de validation partagées par les formulaires d'authentification.
/// Chaque fonction renvoie le message d'erreur, ou null si la saisie est valide.
class AuthFormValidators {
  const AuthFormValidators._();

  /// Longueur minimale imposée par défaut par Supabase Auth.
  static const int _minimumPasswordLength = 6;

  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? validateEmail(String? enteredEmail) {
    final trimmedEmail = enteredEmail?.trim() ?? '';
    if (trimmedEmail.isEmpty) return 'Saisis ton adresse email.';
    if (!_emailPattern.hasMatch(trimmedEmail)) {
      return 'Cette adresse email n\'est pas valide.';
    }
    return null;
  }

  static String? validateExistingPassword(String? enteredPassword) {
    if (enteredPassword == null || enteredPassword.isEmpty) {
      return 'Saisis ton mot de passe.';
    }
    return null;
  }

  static String? validateNewPassword(String? enteredPassword) {
    if (enteredPassword == null ||
        enteredPassword.length < _minimumPasswordLength) {
      return 'Le mot de passe doit contenir au moins $_minimumPasswordLength caractères.';
    }
    return null;
  }

  static String? validatePasswordConfirmation(
    String? enteredConfirmation,
    String expectedPassword,
  ) {
    if (enteredConfirmation != expectedPassword) {
      return 'Les mots de passe ne correspondent pas.';
    }
    return null;
  }
}
