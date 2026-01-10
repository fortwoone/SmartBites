
import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_user.dart';
import '../providers/app_providers.dart';
import '../repositories/auth_repository.dart';

// ==============================================================================
// VIEW MODEL : AuthViewModel
// ==============================================================================
final authViewModelProvider = AsyncNotifierProvider<AuthViewModel, AppUser?>(() {
  return AuthViewModel();
});

class AuthViewModel extends AsyncNotifier<AppUser?> {
  late final AuthRepository _authRepository;

  @override
  FutureOr<AppUser?> build() {
    _authRepository = ref.watch(authRepositoryProvider);
    final authStream = _authRepository.authStateChanges.listen((data) {
        final session = data.session;
        if (session != null) {
          if (state.value?.id != session.user.id) {
             state = AsyncData(AppUser.fromSupabase(session.user));
          }
        } else {
           if (state.value != null) {
             state = const AsyncData(null);
           }
        }
    });
    ref.onDispose(() => authStream.cancel());
    return _authRepository.currentUser;
  }

  // ---------------------------------------------------------------------------
  // Connexion
  // ---------------------------------------------------------------------------
  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _authRepository.signIn(email, password));
  }

  // ---------------------------------------------------------------------------
  // Inscription
  // ---------------------------------------------------------------------------
  Future<void> signUp(String email, String password, {String? username}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _authRepository.signUp(email, password, username: username));
  }

  // ---------------------------------------------------------------------------
  // Déconnexion
  // ---------------------------------------------------------------------------
  Future<void> signOut() async {
    await _authRepository.signOut();
  }

  // ---------------------------------------------------------------------------
  // Mise à jour Avatar
  // ---------------------------------------------------------------------------
  Future<void> updateAvatar(File imageFile) async {
    final currentUser = state.value;
    if (currentUser == null) return;

    try {
      final newUrl = await _authRepository.updateAvatar(imageFile);
      state = AsyncData(currentUser.copyWith(avatarUrl: newUrl));
    } catch (e) {
      // Ignore
    }
  }
}
