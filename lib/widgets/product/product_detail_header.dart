import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/color_constants.dart';

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
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Center(
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.9),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
            onPressed: onBack,
            padding: EdgeInsets.zero,
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: imageUrl != null && imageUrl!.isNotEmpty
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: Colors.grey.shade200, child: const Icon(Icons.broken_image, size: 50, color: Colors.grey)),
              )
            : Container(
                color: primaryPeach.withOpacity(0.2),
                child: const Icon(Icons.shopping_bag_outlined, size: 80, color: primaryPeach),
              ),
      ),
    );
  }
}
