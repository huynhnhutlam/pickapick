import 'dart:developer' as developer;
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for handling Supabase Auth operations.
class AuthService {
  AuthService(this._client);

  final SupabaseClient _client;

  /// Upload avatar image to Supabase storage.
  Future<String> uploadAvatar(Uint8List imageBytes, String fileName) async {
    final userId = currentUser?.id;
    if (userId == null) throw const AuthException('User not authenticated');

    final path = 'avatars/$userId/$fileName';
    try {
      await _client.storage.from('avatars').uploadBinary(
            path,
            imageBytes,
            fileOptions: const FileOptions(upsert: true),
          );
      return _client.storage.from('avatars').getPublicUrl(path);
    } catch (e) {
      developer.log('Upload avatar failed', name: 'AuthService', error: e);
      rethrow;
    }
  }

  /// Current signed-in user, or null if not authenticated.
  User? get currentUser => _client.auth.currentUser;

  /// Stream of auth state changes.
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Returns true when a user session is active.
  bool get isAuthenticated => currentUser != null;

  /// Sign up with email and password.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    try {
      return await _client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName, 'phone': phone},
      );
    } on AuthException catch (e) {
      developer.log('Sign up failed', name: 'AuthService', error: e);
      rethrow;
    }
  }

  /// Sign in with email and password.
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      developer.log('Sign in failed', name: 'AuthService', error: e);
      rethrow;
    }
  }

  /// Sign out current user.
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on AuthException catch (e) {
      developer.log('Sign out failed', name: 'AuthService', error: e);
      rethrow;
    }
  }

  /// Send a password reset email.
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      developer.log('Reset password failed', name: 'AuthService', error: e);
      rethrow;
    }
  }

  /// Get the current user's profile from the `profiles` table.
  Future<Map<String, dynamic>?> getProfile() async {
    final userId = currentUser?.id;
    if (userId == null) return null;
    try {
      return await _client.from('profiles').select().eq('id', userId).single();
    } catch (e) {
      developer.log('Get profile failed', name: 'AuthService', error: e);
      return null;
    }
  }

  /// Update the current user's profile.
  Future<void> updateProfile(Map<String, dynamic> updates) async {
    final userId = currentUser?.id;
    if (userId == null) return;
    try {
      await _client.from('profiles').update(updates).eq('id', userId);
    } catch (e) {
      developer.log('Update profile failed', name: 'AuthService', error: e);
      rethrow;
    }
  }
}
