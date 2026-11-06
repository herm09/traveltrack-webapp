import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:traveltrack/src/services/analytics_service.dart';
import 'package:traveltrack/src/services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel({AuthService? authService, AnalyticsService? analyticsService})
    : _authService = authService ?? AuthService(),
      _analyticsService = analyticsService ?? AnalyticsService.instance {
    _authStateSubscription = _authService.authStateChanges.listen(
      _onAuthStateChanged,
      onError: _onAuthStateError,
    );
  }

  final AuthService _authService;
  final AnalyticsService _analyticsService;
  late final StreamSubscription<AuthState> _authStateSubscription;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Erreur spécifique au champ email (ex: adresse déjà utilisée), affichée
  /// sous l'input mail plutôt que dans le message d'erreur générique.
  String? _emailErrorMessage;
  String? get emailErrorMessage => _emailErrorMessage;

  /// Confirmation d'une action sans changement d'écran (ex: email envoyé).
  String? _successMessage;
  String? get successMessage => _successMessage;

  /// Vrai quand l'utilisateur revient d'un lien de réinitialisation et doit
  /// encore choisir son nouveau mot de passe. Écouté par le routeur.
  final ValueNotifier<bool> _isPasswordRecoveryPending = ValueNotifier(false);
  ValueListenable<bool> get isPasswordRecoveryPending =>
      _isPasswordRecoveryPending;

  User? get currentUser => _authService.currentUser;

  bool get isAuthenticated => _authService.currentSession != null;

  Stream<AuthState> get authStateChanges => _authService.authStateChanges;

  Future<bool> signUp({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) {
    return _run(() async {
      final signUpResponse = await _authService.signUp(
        email: email,
        password: password,
        data: {
          if (firstName != null && firstName.isNotEmpty)
            'first_name': firstName,
          if (lastName != null && lastName.isNotEmpty) 'last_name': lastName,
        },
      );
      // Avec une session, le routeur redirige seul vers /map. Sans session, la
      // confirmation par email est active et il faut prévenir l'utilisateur.
      if (signUpResponse.session != null) {
        await _captureEmailAuthEvent(AnalyticsEvents.userSignedUp);
        return;
      }

      // Supabase masque les adresses déjà inscrites derrière un faux succès,
      // reconnaissable à une liste d'identités vide.
      final userIdentities = signUpResponse.user?.identities;
      if (userIdentities != null && userIdentities.isEmpty) {
        throw AuthException('already registered', code: 'user_already_exists');
      }
      await _captureEmailAuthEvent(AnalyticsEvents.userSignedUp);
      _successMessage =
          'Compte créé ! Confirme ton adresse grâce au lien reçu par email, puis connecte-toi.';
    });
  }

  Future<bool> signIn({required String email, required String password}) {
    return _run(() async {
      await _authService.signIn(email: email, password: password);
      await _captureEmailAuthEvent(AnalyticsEvents.userLoggedIn);
    });
  }

  Future<bool> signInWithGoogle() => _signInWithProvider(OAuthProvider.google);

  Future<bool> signInWithFacebook() =>
      _signInWithProvider(OAuthProvider.facebook);

  Future<bool> sendPasswordResetEmail(String email) {
    return _run(() async {
      await _authService.sendPasswordResetEmail(email);
      _successMessage =
          'Si un compte existe pour cette adresse, un lien de réinitialisation vient de lui être envoyé.';
    });
  }

  Future<bool> updatePassword(String newPassword) {
    return _run(() async {
      await _authService.updatePassword(newPassword);
      _isPasswordRecoveryPending.value = false;
    });
  }

  Future<void> signOut() async {
    await _analyticsService.captureEvent(AnalyticsEvents.userLoggedOut);
    await _authService.signOut();
    notifyListeners();
  }

  /// Efface les messages affichés dès que l'utilisateur corrige sa saisie ou
  /// change d'écran.
  void clearMessages() {
    if (_errorMessage == null &&
        _emailErrorMessage == null &&
        _successMessage == null) {
      return;
    }
    _errorMessage = null;
    _emailErrorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  Future<bool> _signInWithProvider(OAuthProvider provider) {
    return _run(() async {
      final isBrowserOpened = await _authService.signInWithOAuth(provider);
      if (!isBrowserOpened) {
        throw AuthException('Impossible d\'ouvrir la page de connexion.');
      }
      await _analyticsService.captureEvent(
        AnalyticsEvents.oauthLoginStarted,
        properties: {'provider': provider.name},
      );
    });
  }

  Future<void> _captureEmailAuthEvent(String eventName) {
    return _analyticsService.captureEvent(
      eventName,
      properties: {'method': 'email'},
    );
  }

  void _onAuthStateChanged(AuthState authState) {
    if (authState.event == AuthChangeEvent.passwordRecovery) {
      _isPasswordRecoveryPending.value = true;
    }

    final signedInUserId = authState.session?.user.id;
    if (signedInUserId != null) {
      _analyticsService.identifyUser(signedInUserId);
    } else if (authState.event == AuthChangeEvent.signedOut) {
      _analyticsService.resetUser();
    }
  }

  void _onAuthStateError(Object authStateError) {
    _errorMessage = 'Ce lien est invalide ou a expiré. Réessaie.';
    notifyListeners();
  }

  Future<bool> _run(Future<void> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    _emailErrorMessage = null;
    _successMessage = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on AuthException catch (e) {
      if (_isEmailAlreadyUsed(e)) {
        _emailErrorMessage = 'Adresse mail déjà utilisée.';
      } else if (_isInvalidCredentials(e)) {
        _errorMessage = 'Email ou mot de passe incorrect.';
      } else if (e.code == 'email_not_confirmed') {
        _errorMessage = 'Confirme ton adresse email avant de te connecter.';
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
    return message.contains('already registered') ||
        message.contains('already exists');
  }

  bool _isInvalidCredentials(AuthException e) {
    if (e.code == 'invalid_credentials') return true;
    return e.message.toLowerCase().contains('invalid login credentials');
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    _isPasswordRecoveryPending.dispose();
    super.dispose();
  }
}

/// Instance partagée par app_router.dart et les écrans de connexion/inscription,
/// dans le même esprit que le getter global `supabase` de supabase_client.dart.
final AuthViewModel authViewModel = AuthViewModel();
