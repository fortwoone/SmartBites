import 'dart:convert';
import 'package:flutter/material.dart';

/// Widget réutilisable pour afficher un avatar utilisateur
/// Supporte les images base64 et les URLs réseau
class AvatarWidget extends StatelessWidget {
  final String? avatarUrl;
  final double size;
  final Color? borderColor;
  final double borderWidth;
  final List<BoxShadow>? boxShadow;
  final IconData fallbackIcon;
  final Color? fallbackIconColor;

  const AvatarWidget({
    super.key,
    this.avatarUrl,
    this.size = 40,
    this.borderColor,
    this.borderWidth = 2,
    this.boxShadow,
    this.fallbackIcon = Icons.person_outline,
    this.fallbackIconColor,
  });

  @override
  Widget build(BuildContext context) {
    if (avatarUrl == null || avatarUrl!.isEmpty) {
      return _buildFallbackIcon();
    }

    // Vérifier si c'est une image base64
    final isBase64 = avatarUrl!.startsWith('data:image');

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: borderColor != null
            ? Border.all(color: borderColor!, width: borderWidth)
            : null,
        boxShadow: boxShadow,
      ),
      child: ClipOval(
        child: isBase64
            ? _buildBase64Image()
            : _buildNetworkImage(),
      ),
    );
  }

  /// Construit une image à partir de données base64
  Widget _buildBase64Image() {
    try {
      final base64Data = avatarUrl!.split(',').last;
      final bytes = base64Decode(base64Data);

      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(),
      );
    } catch (e) {
      return _buildFallbackIcon();
    }
  }

  /// Construit une image à partir d'une URL réseau
  Widget _buildNetworkImage() {
    return Image.network(
      avatarUrl!,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey.shade200,
          child: Center(
            child: SizedBox(
              width: size * 0.4,
              height: size * 0.4,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  borderColor?.withValues(alpha: 0.5) ?? Colors.grey,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Affiche l'icône par défaut en cas d'absence d'avatar
  Widget _buildFallbackIcon() {
    return Container(
      color: Colors.grey.shade200,
      child: Icon(
        fallbackIcon,
        size: size * 0.6,
        color: fallbackIconColor ?? Colors.grey.shade600,
      ),
    );
  }
}

/// Variante spécifique pour la NavigationBar
class NavigationAvatarIcon extends StatelessWidget {
  final String? avatarUrl;
  final bool isSelected;
  final Color selectedColor;
  final Color unselectedColor;

  const NavigationAvatarIcon({
    super.key,
    required this.avatarUrl,
    required this.isSelected,
    required this.selectedColor,
    this.unselectedColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return AvatarWidget(
      avatarUrl: avatarUrl,
      size: 28,
      borderColor: isSelected ? selectedColor : Colors.grey.shade400,
      borderWidth: isSelected ? 2.5 : 2,
      boxShadow: isSelected
          ? [
        BoxShadow(
          color: selectedColor.withValues(alpha: 0.3),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ]
          : null,
      fallbackIcon: isSelected ? Icons.person : Icons.person_outline,
      fallbackIconColor: isSelected ? selectedColor : unselectedColor,
    );
  }
}