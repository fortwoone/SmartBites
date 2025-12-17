import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/color_constants.dart';
import '../../l10n/app_localizations.dart';

class RecipeListHeader extends StatelessWidget {
  final bool isMenuOpen;
  final VoidCallback onToggleMenu;
  final bool showOnlyMine;
  final VoidCallback onToggleFilter;
  final VoidCallback onAddRecipe;

  const RecipeListHeader({
    super.key,
    required this.isMenuOpen,
    required this.onToggleMenu,
    required this.showOnlyMine,
    required this.onToggleFilter,
    required this.onAddRecipe,
  });

  Widget _buildSquareButton({
    required Widget child,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
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
          borderRadius: BorderRadius.circular(15),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildSquareButton(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return RotationTransition(
                  turns: Tween(begin: 0.5, end: 1.0).animate(animation),
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              },
              child: Icon(
                isMenuOpen ? Icons.close_rounded : Icons.menu_rounded,
                key: ValueKey(isMenuOpen),
                color: Colors.black87,
              ),
            ),
            onPressed: onToggleMenu,
          ),
          Text(
            showOnlyMine ? loc.myRecipes : loc.recipes,
            style: GoogleFonts.recursive(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Row(
            children: [
              _buildSquareButton(
                child: Icon(showOnlyMine ? Icons.person : Icons.people_alt_outlined, color: Colors.black87),
                onPressed: onToggleFilter,
              ),
              const SizedBox(width: 12),
              _buildSquareButton(
                child: const Icon(Icons.add, color: primaryPeach),
                onPressed: onAddRecipe,
              ),
            ],
          )
        ],
      ),
    );
  }
}
