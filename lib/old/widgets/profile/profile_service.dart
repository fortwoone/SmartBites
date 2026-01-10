import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'dart:convert';

import '../../l10n/app_localizations.dart';

class ProfileService {
  static String nameFromEmail(String? email) {
    if (email == null || email.isEmpty) return 'Utilisateur';
    final local = email.split('@').first;
    final parts = local.replaceAll(RegExp(r'[._]+'), ' ').split(' ');
    final titled = parts.map((p) {
      if (p.isEmpty) return '';
      return p[0].toUpperCase() + (p.length > 1 ? p.substring(1) : '');
    }).where((s) => s.isNotEmpty).join(' ');
    return titled.isNotEmpty ? titled : local;
  }

  static Future<Map<String, dynamic>> loadUserInfo() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser ?? client.auth.currentSession?.user;

    if (user == null) {
      throw Exception('no_user');
    }

    final email = user.email;
    final displayName = user.userMetadata?['display_name'] as String? ?? nameFromEmail(email);
    final avatarUrl = user.userMetadata?['avatar_url'] as String?;

    return {
      'email': email ?? '',
      'displayName': displayName,
      'avatarUrl': avatarUrl,
    };
  }

  static Future<String> pickAndUploadAvatar(
    BuildContext context,
    ImageSource source,
  ) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: source,
      maxWidth: 200,
      maxHeight: 200,
      imageQuality: 60,
    );

    if (image == null) {
      throw Exception('No image selected');
    }

    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;
    final loc = AppLocalizations.of(context)!;


    if (userId == null) {
      throw Exception(loc.user_not_connected_exception);
    }

    final file = File(image.path);
    final bytes = await file.readAsBytes();
    final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';

    await client.auth.updateUser(
      UserAttributes(
        data: {'avatar_url': base64Image},
      ),
    );

    return base64Image;
  }

  static Future<void> signOut(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
}

