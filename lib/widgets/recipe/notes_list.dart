import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RecipeNotesList extends StatelessWidget {
  final List<Map<String, dynamic>> notes;

  const RecipeNotesList({
    super.key,
    required this.notes,
  });

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) {
      return Text(
        "Aucun avis pour le moment",
        style: GoogleFonts.recursive(color: Colors.grey),
      );
    }

    return Column(
      children: notes.map((n) {
        final int rating = (n['rating'] as num?)?.toInt() ?? 0;
        final String comment = n['note'] ?? '';

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                5,
                    (i) => Icon(
                  i < rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 18,
                ),
              ),
            ),
            title: Text(
              comment.isEmpty ? "—" : comment,
              style: GoogleFonts.recursive(),
            ),
          ),
        );
      }).toList(),
    );
  }
}
