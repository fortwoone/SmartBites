import 'package:supabase_flutter/supabase_flutter.dart';

// ==============================================================================
// MODÈLE : AppUser
// ==============================================================================
class AppUser {
  final String id;
  final String email;
  final String? displayName;
  final String? avatarUrl;

  // Constructeur
  const AppUser({
    required this.id,
    required this.email,
    this.displayName,
    this.avatarUrl,
  });


  // ---------------------------------------------------------------------------
  // FACTORY : Crée un AppUser directement à partir d'un objet User de Supabase.
  // ---------------------------------------------------------------------------
  factory AppUser.fromSupabase(User user) {
    return AppUser(
      id: user.id,
      email: user.email ?? '',
      displayName: user.userMetadata?['display_name'] as String?,
      avatarUrl: user.userMetadata?['avatar_url'] as String?,
    );
  }

  // Convertit l'objet en JSON
  Map<String, dynamic> toJson() {
    return {'id': id,
      'email': email,
      'display_name': displayName,
      'avatar_url': avatarUrl };
  }

  // Permet de créer une copie modifiée de l'objet
  AppUser copyWith({
    String? id,
    String? email,
    String? displayName,
    String? avatarUrl,
  }) {
    return AppUser(id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl );
  }
}
