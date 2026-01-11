import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'profile_avatar.dart';

class ProfileHeader extends StatelessWidget {
  final String displayName;
  final String email;
  final String? avatarUrl;
  final bool isLoadingAvatar;
  final VoidCallback onAvatarTap;
  final VoidCallback onEditNameTap;

  const ProfileHeader({
    super.key,
    required this.displayName,
    required this.email,
    this.avatarUrl,
    required this.isLoadingAvatar,
    required this.onAvatarTap,
    required this.onEditNameTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          ProfileAvatar(
            avatarUrl: avatarUrl,
            isLoading: isLoadingAvatar,
            onTap: onAvatarTap,
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: onEditNameTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 250),
                  child: Text(
                    displayName.isNotEmpty ? displayName : 'Utilisateur',
                    style: GoogleFonts.recursive(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.edit_rounded, color: Colors.grey.shade400, size: 18),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: GoogleFonts.recursive(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
