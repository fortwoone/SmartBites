import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/color_constants.dart';
import '../../l10n/app_localizations.dart';

enum RecipeMenuAction {
  edit,
  delete,
}

class RecipeCard extends StatelessWidget {
  final Map<String, dynamic> recipe;
  final bool isMine;
  final VoidCallback onTap;
  final Function(RecipeMenuAction) onMenuAction;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.isMine,
    required this.onTap,
    required this.onMenuAction,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final description = (recipe['description'] ?? '').toString();
    final imageUrl = recipe['image_url'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(26),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: primaryPeach.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    image: imageUrl != null && imageUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                            onError: (exception, stackTrace) {
                                debugPrint('Error loading image: $exception');
                            },
                          )
                        : null,
                  ),
                  child: imageUrl == null || imageUrl.isEmpty
                      ? const Icon(Icons.restaurant, color: primaryPeach, size: 32)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe['name'] ?? 'Sans titre',
                        style: GoogleFonts.recursive(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: GoogleFonts.recursive(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (recipe['creator_name'] != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Créé par: ${recipe['creator_name']}',
                          style: GoogleFonts.recursive(
                            fontSize: 12,
                            color: Colors.grey.shade400,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
                if (isMine)
                  PopupMenuButton<RecipeMenuAction>(
                    icon: Icon(Icons.more_vert, color: Colors.grey.shade400),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    onSelected: onMenuAction,
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: RecipeMenuAction.edit,
                        child: Row(
                          children: [
                            const Icon(Icons.edit, size: 18, color: Colors.blueAccent),
                            const SizedBox(width: 12),
                            Text(loc.update, style: GoogleFonts.recursive()),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: RecipeMenuAction.delete,
                        child: Row(
                          children: [
                            const Icon(Icons.delete, size: 18, color: Colors.redAccent),
                            const SizedBox(width: 12),
                            Text(loc.delete, style: GoogleFonts.recursive()),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
