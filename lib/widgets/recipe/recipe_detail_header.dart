import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/color_constants.dart';

class RecipeDetailHeader extends StatelessWidget {
  final Map<String, dynamic> recipe;
  
  const RecipeDetailHeader({
    super.key,
    required this.recipe,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = recipe['image_url'] as String?;

    return SliverAppBar(
      expandedHeight: 300.0,
      floating: false,
      pinned: true,
      backgroundColor: primaryPeach,
      elevation: 0,
       leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            padding: const EdgeInsets.only(left: 6),
            alignment: Alignment.center,
            child: const Icon(Icons.arrow_back_ios, color: primaryPeach, size: 20),
          ),
        ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
            recipe['name'] ?? '',
            style: GoogleFonts.recursive(
                color: Colors.white,
                fontWeight: FontWeight.bold,
            ),
        ),
        background: imageUrl != null && imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: primaryPeach,
                    child: Icon(Icons.broken_image, size: 100, color: Colors.white.withOpacity(0.5)),
                  );
                },
              )
            : Container(
                color: primaryPeach,
                child: Icon(Icons.restaurant_menu, size: 100, color: Colors.white.withOpacity(0.5)),
            ),
      ),
    );
  }
}
