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

  User? get currentUser => _authService.currentUser;

  bool get isAuthenticated => _authService.currentSession != null;

  Stream<AuthState> get authStateChanges => _authService.authStateChanges;

  Future<bool> signUp({required String email, required String password}) {
    return _run(() => _authService.signUp(email: email, password: password));
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
    notifyListeners();
    try {
      await action();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'Une erreur inattendue est survenue. Réessaie.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

/// Instance partagée par app_router.dart et les écrans de connexion/inscription,
/// dans le même esprit que le getter global `supabase` de supabase_client.dart.
final AuthViewModel authViewModel = AuthViewModel();
