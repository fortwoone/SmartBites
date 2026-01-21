import 'package:flutter/material.dart';
import 'dart:convert';

class ProfileAvatar extends StatelessWidget {
  final String? avatarUrl;
  final bool isLoading;
  final VoidCallback onTap;
  final double size;

  const ProfileAvatar({
    super.key,
    this.avatarUrl,
    required this.isLoading,
    required this.onTap,
    this.size = 110,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    ImageProvider? imageProvider;
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      if (avatarUrl!.startsWith('data:image')) {
        try {
          final base64String = avatarUrl!.split(',')[1];
          imageProvider = MemoryImage(base64Decode(base64String));
        } catch (_) {}
      } else {
        imageProvider = NetworkImage(avatarUrl!);
      }
    }
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
              border: Border.all(color: Colors.white, width: 4),
            ),
            child: CircleAvatar(
              radius: size / 2,
              backgroundColor: Colors.grey.shade100,
              backgroundImage: imageProvider,
              child: imageProvider == null
                  ? Icon(Icons.person, size: size * 0.5, color: Colors.grey.shade300)
                  : null,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 4,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF8C61),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(Icons.camera_alt_rounded, color: Colors.white, size: size * 0.16),
            ),
          ),
        ],
      ),
    );
  }
}
