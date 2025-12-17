import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';

class RecipeImagePicker extends StatelessWidget {
  final File? imageFile;
  final String? existingImageUrl;
  final VoidCallback onTap;

  const RecipeImagePicker({
    super.key,
    required this.imageFile,
    required this.existingImageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade300),
            image: imageFile != null
                ? DecorationImage(image: FileImage(imageFile!), fit: BoxFit.cover)
                : existingImageUrl != null && existingImageUrl!.isNotEmpty
                    ? DecorationImage(image: NetworkImage(existingImageUrl!), fit: BoxFit.cover)
                    : null,
          ),
          child: (imageFile == null && (existingImageUrl == null || existingImageUrl!.isEmpty))
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo, size: 40, color: Colors.grey.shade400),
                    const SizedBox(height: 8),
                    Text("Ajouter une photo", style: GoogleFonts.recursive(color: Colors.grey.shade500)),
                  ],
                )
              : null,
        ),
      ),
    );
  }
}
