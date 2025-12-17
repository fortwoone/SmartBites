import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/color_constants.dart';
import '../../l10n/app_localizations.dart';

class IngredientListEditor extends StatelessWidget {
  final List<Map<String, dynamic>> ingredients;
  final VoidCallback onAddIngredient;
  final Function(Map<String, dynamic>) onRemoveIngredient;

  const IngredientListEditor({
    super.key,
    required this.ingredients,
    required this.onAddIngredient,
    required this.onRemoveIngredient,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(loc.ingredients, style: GoogleFonts.recursive(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.add_circle), color: primaryPeach, iconSize: 30, onPressed: onAddIngredient),
            ],
          ),
          const SizedBox(height: 12),
          ingredients.isEmpty
              ? Text(loc.noIngredientsAdded, style: GoogleFonts.recursive(color: Colors.grey, fontStyle: FontStyle.italic))
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ingredients
                      .map((ing) => Chip(
                            label: Text(ing['name'] ?? loc.ingredients, style: GoogleFonts.recursive()),
                            backgroundColor: primaryPeach.withOpacity(0.2),
                            deleteIconColor: Colors.redAccent,
                            onDeleted: () => onRemoveIngredient(ing),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
                          ))
                      .toList(),
                )
        ],
      ),
    );
  }
}
