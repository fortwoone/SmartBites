import 'dart:io';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_user.dart';

// ==============================================================================
// REPOSITORY : AuthRepository
// ==============================================================================
class AuthRepository {
  final SupabaseClient _client;

  AuthRepository(this._client);
  static final AuthRepository instance = AuthRepository(Supabase.instance.client);
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
  AppUser? get currentUser {
    final user = _client.auth.currentUser;
    return user != null ? AppUser.fromSupabase(user) : null;
  }

  // ---------------------------------------------------------------------------
  // Connexion
  // ---------------------------------------------------------------------------
  Future<AppUser> signIn(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user == null) {
        throw Exception('Connexion échouée : Utilisateur introuvable');
      }

      return AppUser.fromSupabase(response.user!);
    } catch (e) {
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Inscription
  // ---------------------------------------------------------------------------
  Future<AppUser> signUp(String email, String password, {String? username}) async {
    try {
      final response = await _client.auth.signUp(email: email, password: password, data: username != null ? {'display_name': username} : null);

      if (response.user == null) {
         if (response.session == null) {
           throw Exception('Veuillez confirmer votre email avant de vous connecter.');
         }
         throw Exception('Inscription échouée');
      }
      return AppUser.fromSupabase(response.user!);
    } catch (e) {
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Déconnexion
  // ---------------------------------------------------------------------------
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // ---------------------------------------------------------------------------
  // Mise à jour Avatar
  // ---------------------------------------------------------------------------
  Future<String> updateAvatar(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      final response = await _client.auth.updateUser(
        UserAttributes(
          data: {'avatar_url': base64Image},
        ),
      );

      if (response.user == null) {
        throw Exception("Erreur lors de la mise à jour");
      }
      return base64Image;
    } catch (e) {
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Mise à jour du Nom
  // ---------------------------------------------------------------------------
  Future<void> updateDisplayName(String newName) async {
     await _client.auth.updateUser(
        UserAttributes(
          data: {'display_name': newName},
        ),
      );
  }

  // ---------------------------------------------------------------------------
  // Mise à jour du Mot de passe
  // ---------------------------------------------------------------------------
  Future<void> updatePassword(String newPassword) async {
    await _client.auth.updateUser(
      UserAttributes(
        password: newPassword,
      ),
    );
  }
}
