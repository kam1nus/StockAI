import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final SupabaseClient _client =
      Supabase.instance.client;

  static User? get currentUser =>
      _client.auth.currentUser;

  static bool get isLoggedIn =>
      currentUser != null;

  static Stream<AuthState> get authChanges =>
      _client.auth.onAuthStateChange;

  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    return _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'display_name': displayName.trim(),
      },
    );
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  static Future<void> saveConsents({
    required bool termsAccepted,
    required bool privacyAccepted,
    required bool ageConfirmed,
  }) async {
    final user = currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    await _client.from('user_consents').upsert({
      'user_id': user.id,
      'terms_accepted': termsAccepted,
      'privacy_accepted': privacyAccepted,
      'age_confirmed': ageConfirmed,
      'terms_version': '1.0',
      'privacy_version': '1.0',
      'accepted_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}