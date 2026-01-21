import 'package:flutter/material.dart';

class ProductDetailHeader extends StatelessWidget {
  final String? imageUrl;
  final VoidCallback onBack;

  const ProductDetailHeader({
    super.key,
    required this.imageUrl,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      backgroundColor: Colors.white,
      elevation: 0,
      pinned: true,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: onBack,
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: imageUrl != null
            ? Image.network(
                imageUrl!,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[100],
                    child: Icon(Icons.broken_image,
                        size: 64, color: Colors.grey[400]),
                  );
                },
              )
            : Container(
                color: Colors.grey[100],
                child:
                    Icon(Icons.image_not_supported, size: 64, color: Colors.grey[400]),
              ),
      ),
    );
  }
}
