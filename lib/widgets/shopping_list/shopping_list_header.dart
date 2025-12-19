import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/color_constants.dart';
import '../../l10n/app_localizations.dart';

class ShoppingListHeader extends StatelessWidget implements PreferredSizeWidget {
  final bool isMenuOpen;
  final VoidCallback onToggleMenu;
  final VoidCallback onAddList;

  const ShoppingListHeader({
    super.key,
    required this.isMenuOpen,
    required this.onToggleMenu,
    required this.onAddList,
  });

  @override
  Size get preferredSize => const Size.fromHeight(80);

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

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 80,
      automaticallyImplyLeading: false,
      flexibleSpace: SafeArea(
        child: Padding(
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
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: Icon(
                    isMenuOpen ? Icons.close_rounded : Icons.menu_rounded,
                    key: ValueKey(isMenuOpen),
                    color: Colors.black87,
                  ),
                ),
                onPressed: onToggleMenu,
              ),Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      loc.shopping_lists,
                      style: GoogleFonts.recursive(
                          fontSize: 22,
                          fontWeight: FontWeight.bold
                      ),
                      maxLines: 1,
                    ),
                  ),
                ),
              ),
              _buildSquareButton(
                child: const Icon(Icons.add, color: primaryPeach),
                onPressed: onAddList,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
