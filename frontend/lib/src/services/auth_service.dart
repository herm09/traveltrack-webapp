import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:traveltrack/src/services/supabase_client.dart';

class AuthService {
  /// Adresse de retour après OAuth ou un lien reçu par email. Doit figurer dans
  /// les "Redirect URLs" du projet Supabase, et le schéma mobile dans
  /// AndroidManifest.xml et Info.plist.
  static String get _authRedirectUrl =>
      kIsWeb ? Uri.base.origin : 'com.traveltrack.traveltrack://login-callback';

  Session? get currentSession => supabase.auth.currentSession;

  User? get currentUser => supabase.auth.currentUser;

  Stream<AuthState> get authStateChanges => supabase.auth.onAuthStateChange;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) {
    return supabase.auth.signUp(
      email: email,
      password: password,
      data: data,
      emailRedirectTo: _authRedirectUrl,
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<bool> signInWithOAuth(OAuthProvider provider) {
    return supabase.auth.signInWithOAuth(
      provider,
      redirectTo: _authRedirectUrl,
    );
  }

  Future<void> sendPasswordResetEmail(String email) {
    return supabase.auth.resetPasswordForEmail(
      email,
      redirectTo: _authRedirectUrl,
    );
  }

  Future<void> updatePassword(String newPassword) {
    return supabase.auth.updateUser(UserAttributes(password: newPassword));
  }

  Future<void> signOut() => supabase.auth.signOut();
}
