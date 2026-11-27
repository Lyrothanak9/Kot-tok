import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (response.user != null) {
      try {
        await _client.from('profiles').upsert({
          'id': response.user!.id,
          'full_name': response.user!.userMetadata?['name'] ?? email.split('@').first,
        }, onConflict: 'id');
      } catch (_) {}
    }
    return response;
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? username,
  }) async {
    final cleanName = username?.trim();
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: cleanName != null && cleanName.isNotEmpty
          ? {'name': cleanName, 'full_name': cleanName}
          : null,
    );
    if (response.user != null) {
      try {
        await _client.from('profiles').upsert({
          'id': response.user!.id,
          'full_name': (cleanName != null && cleanName.isNotEmpty)
              ? cleanName
              : (response.user!.userMetadata?['name'] ?? email.split('@').first),
        }, onConflict: 'id');
      } catch (_) {}
    }
    return response;
  }

  Future<void> resetPassword({
    required String email,
  }) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
