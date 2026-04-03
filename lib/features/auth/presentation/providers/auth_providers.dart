import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pickle_pick/features/auth/data/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(Supabase.instance.client);
});

/// Provides a stream of [AuthState] changes.
final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

/// Whether the current user is authenticated.
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.maybeWhen(
    data: (state) => state.session != null,
    orElse: () => Supabase.instance.client.auth.currentUser != null,
  );
});

/// AsyncNotifier for managing auth operations with loading/error states.
class AuthNotifier extends AsyncNotifier<User?> {
  late AuthService _service;

  @override
  Future<User?> build() async {
    _service = ref.watch(authServiceProvider);
    // Listen to auth changes and rebuild
    ref.listen(authStateProvider, (_, next) {
      next.whenData(
        (state) => state.event == AuthChangeEvent.signedIn
            ? ref.invalidateSelf()
            : null,
      );
    });
    return _service.currentUser;
  }

  /// Sign in with email/password.
  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final response = await _service.signIn(email: email, password: password);
      return response.user;
    });
  }

  /// Sign up with email/password.
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final response = await _service.signUp(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      );
      return response.user;
    });
  }

  /// Sign out.
  Future<void> signOut() async {
    state = const AsyncLoading();
    await _service.signOut();
    state = const AsyncData(null);
  }

  /// Update the current user's profile.
  Future<void> updateProfile(Map<String, dynamic> updates) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _service.updateProfile(updates);
      return _service.currentUser;
    });
  }

  /// Update the current user's profile avatar.
  Future<String> updateAvatar(Uint8List bytes, String name) async {
    final url = await _service.uploadAvatar(bytes, name);
    await updateProfile({'avatar_url': url});
    return url;
  }

  /// Get the user profile data.
  Future<Map<String, dynamic>?> getProfile() async {
    return _service.getProfile();
  }
}

final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, User?>(AuthNotifier.new);
