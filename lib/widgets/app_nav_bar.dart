import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_localizations.dart';
import '../utils/color_constants.dart';

class AppNavBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final bool showSearch;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onSearchSubmitted;
  final String? initialQuery;
  final Color? backgroundColor;
  final bool showSquareButtons;
  final String? leftRoute;
  final String? rightRoute;
  final VoidCallback? onMenuPressed;
  final bool isMenuOpen;
  final VoidCallback? onSearchClosed;

  const AppNavBar({
    super.key,
    required this.title,
    this.showSearch = false,
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.initialQuery,
    this.backgroundColor,
    this.showSquareButtons = false,
    this.leftRoute,
    this.rightRoute,
    this.onMenuPressed,
    this.isMenuOpen = false,
    this.onSearchClosed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 10);

  @override
  State<AppNavBar> createState() => _AppNavBarState();
}

class _AppNavBarState extends State<AppNavBar> {
  late final TextEditingController _controller;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startSearch() => setState(() => _isSearching = true);
  void _stopSearch() {
    setState(() => _isSearching = false);
    _controller.clear();
    widget.onSearchChanged?.call('');
    widget.onSearchClosed?.call();
  }

  Widget _squareButton({
    required Color color,
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
    final Color bg = widget.backgroundColor ?? Colors.transparent;

    final actions = <Widget>[];
    if (widget.showSearch) {
      if (_isSearching) {
        actions.add(
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.black87),
            onPressed: _stopSearch,
          ),
        );
      } else {
        actions.add(
          IconButton(
            icon: const Icon(Icons.search_rounded, size: 28, color: Colors.black87),
            onPressed: _startSearch,
          ),
        );
      }
    }
    Widget? leading;
    if (widget.onMenuPressed != null) {
      leading = Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: _squareButton(
            color: Colors.transparent,
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
                widget.isMenuOpen ? Icons.close_rounded : Icons.menu_rounded,
                key: ValueKey(widget.isMenuOpen),
                color: Colors.black87,
              ),
            ),
            onPressed: widget.onMenuPressed!,
          ),
        ),
      );
    }
    Widget titleWidget;
    if (_isSearching) {
      titleWidget = Container(
        height: 45,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(20),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          style: GoogleFonts.recursive(color: Colors.black87),
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.hint_search,
            hintStyle: GoogleFonts.recursive(color: Colors.black38),
            border: InputBorder.none,
            isDense: false,
            icon: const Icon(Icons.search_rounded, color: primaryPeach),
          ),
          onChanged: widget.onSearchChanged,
          onSubmitted: widget.onSearchSubmitted,
        ),
      );
    } else {
      titleWidget = Text(
        widget.title,
        style: GoogleFonts.recursive(
          fontWeight: FontWeight.w700,
          fontSize: 22,
          color: Colors.black87,
        ),
        overflow: TextOverflow.ellipsis,
      );
    }
    return AppBar(backgroundColor: bg, elevation: 0, leading: leading, leadingWidth: 80, titleSpacing: 16, title: titleWidget, centerTitle: false, actions: actions,);
  }
}
