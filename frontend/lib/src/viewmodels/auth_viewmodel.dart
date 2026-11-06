import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel({AuthService? authService}) : _authService = authService ?? AuthService();

  final AuthService _authService;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Erreur spécifique au champ email (ex: adresse déjà utilisée), affichée
  /// sous l'input mail plutôt que dans le message d'erreur générique.
  String? _emailErrorMessage;
  String? get emailErrorMessage => _emailErrorMessage;

  User? get currentUser => _authService.currentUser;

  bool get isAuthenticated => _authService.currentSession != null;

  Stream<AuthState> get authStateChanges => _authService.authStateChanges;

  Future<bool> signUp({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) {
    return _run(() => _authService.signUp(
          email: email,
          password: password,
          data: {
            if (firstName != null && firstName.isNotEmpty) 'first_name': firstName,
            if (lastName != null && lastName.isNotEmpty) 'last_name': lastName,
          },
        ));
  }

  Future<bool> signIn({required String email, required String password}) {
    return _run(() => _authService.signIn(email: email, password: password));
  }

  Future<void> signOut() async {
    await _authService.signOut();
    notifyListeners();
  }

  Future<bool> _run(Future<void> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    _emailErrorMessage = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on AuthException catch (e) {
      if (_isEmailAlreadyUsed(e)) {
        _emailErrorMessage = 'Adresse mail déjà utilisée.';
      } else if (_isInvalidCredentials(e)) {
        _errorMessage = 'Email ou mot de passe incorrect.';
      } else {
        _errorMessage = e.message;
      }
      return false;
    } catch (_) {
      _errorMessage = 'Une erreur inattendue est survenue. Réessaie.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool _isEmailAlreadyUsed(AuthException e) {
    if (e.code == 'user_already_exists') return true;
    final message = e.message.toLowerCase();
    return message.contains('already registered') || message.contains('already exists');
  }

  bool _isInvalidCredentials(AuthException e) {
    if (e.code == 'invalid_credentials') return true;
    return e.message.toLowerCase().contains('invalid login credentials');
  }
}

/// Instance partagée par app_router.dart et les écrans de connexion/inscription,
/// dans le même esprit que le getter global `supabase` de supabase_client.dart.
final AuthViewModel authViewModel = AuthViewModel();
