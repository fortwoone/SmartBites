import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/color_constants.dart';

class MenuHeader extends StatelessWidget {
  final VoidCallback onTap;

  const MenuHeader({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final userEmail = user?.email ?? '';
    final userName = user?.userMetadata?['display_name'] as String? ?? _nameFromEmail(userEmail);
    final avatarUrl = user?.userMetadata?['avatar_url'] as String?;
    final avatarImage = _getAvatarImage(avatarUrl);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              primaryPeach.withAlpha(30),
              primaryPeach.withAlpha(10),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: primaryPeach.withAlpha(50),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            _buildAvatar(userName, avatarImage),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: GoogleFonts.recursive(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    userEmail,
                    style: GoogleFonts.recursive(
                      fontSize: 12,
                      color: Colors.black45,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.black26,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String userName, ImageProvider? avatarImage) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: avatarImage != null ? Colors.white : primaryPeach,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: avatarImage != null
            ? Image(
                image: avatarImage,
                fit: BoxFit.cover,
                width: 48,
                height: 48,
              )
            : Center(
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                  style: GoogleFonts.recursive(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
      ),
    );
  }

  ImageProvider? _getAvatarImage(String? avatarUrl) {
    if (avatarUrl == null || avatarUrl.isEmpty) return null;

    if (avatarUrl.startsWith('data:image')) {
      try {
        final base64String = avatarUrl.split(',')[1];
        return MemoryImage(base64Decode(base64String));
      } catch (_) {
        return null;
      }
    }

    return NetworkImage(avatarUrl);
  }

  String _nameFromEmail(String? email) {
    if (email == null || email.isEmpty) return 'Utilisateur';
    final local = email.split('@').first;
    final parts = local.replaceAll(RegExp(r'[._]+'), ' ').split(' ');
    final titled = parts.map((p) {
      if (p.isEmpty) return '';
      return p[0].toUpperCase() + (p.length > 1 ? p.substring(1) : '');
    }).where((s) => s.isNotEmpty).join(' ');
    return titled.isNotEmpty ? titled : local;
  }
}

