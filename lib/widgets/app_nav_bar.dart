import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

class AppNavBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final bool showSearch;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onSearchSubmitted;
  final String? initialQuery;
  final Color? backgroundColor;
  final bool showSquareButtons;
  final String? leftRoute;   // bouton vert
  final String? rightRoute;  // bouton rouge

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
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

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
  }

  Widget _squareButton({
    required Color color,
    required Widget child,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: kToolbarHeight,
      height: kToolbarHeight,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        constraints: BoxConstraints.tight(Size(kToolbarHeight, kToolbarHeight)),
        icon: child,
        onPressed: onPressed,
      ),
    );
  }

  // === LOGIQUE DE NAVIGATION PROPRE ===
  void _safeNavigateTo(String routeName) {
    final current = ModalRoute.of(context)?.settings.name;
    if (current == routeName) return; // déjà sur la page => ne rien faire
    Navigator.of(context).pushNamed(routeName);
  }

  @override
  Widget build(BuildContext context) {
    final Color bg = widget.backgroundColor ?? Theme.of(context).colorScheme.inversePrimary;
    final actions = <Widget>[];

    // Bouton de recherche
    if (widget.showSearch) {
      actions.add(
        IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search),
          onPressed: () => _isSearching ? _stopSearch() : _startSearch(),
        ),
      );
    }

    // Bouton carré à droite (rouge)
    if (widget.showSquareButtons && widget.rightRoute != null) {
      actions.add(
        Padding(
          padding: const EdgeInsets.only(left: 6),
          child: _squareButton(
            color: Colors.red,
            child: SizedBox(
              width: kToolbarHeight * 0.8, // ajuste la taille si nécessaire
              child: Image.asset(
                'lib/ressources/cuisine_icon.png',
                fit: BoxFit.contain,
              ),
            ),
            onPressed: () {
              if (Navigator.of(context).canPop() &&
                  ModalRoute.of(context)?.settings.name != widget.rightRoute) {
                Navigator.of(context).pop();
              } else if (widget.rightRoute != null) {
                _safeNavigateTo(widget.rightRoute!);
              }
            },
          )
          ,
        ),
      );
    }

    // Bouton carré à gauche (vert)
    Widget? leading;
    if (widget.showSquareButtons) {
      leading = Padding(
        padding: const EdgeInsets.only(right: 6),
        child: _squareButton(
          color: Colors.green,
          child: SizedBox(
            width: kToolbarHeight * 0.8, // ajuste selon la taille du logo
            child: Image.asset(
              'lib/ressources/ingredients_icon.png',
              fit: BoxFit.contain,
            ),
          ),
          onPressed: () {
            if (Navigator.of(context).canPop() &&
                ModalRoute.of(context)?.settings.name != widget.leftRoute) {
              Navigator.of(context).pop();
            } else if (widget.leftRoute != null) {
              _safeNavigateTo(widget.leftRoute!);
            }
          },
        ),
      );
    }

    return AppBar(
      backgroundColor: bg,
      leading: leading,
      leadingWidth: 64,
      titleSpacing: 0,
      title: _isSearching
          ? TextField(
        controller: _controller,
        autofocus: true,
        textInputAction: TextInputAction.search,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.hint_search,
          hintStyle: const TextStyle(color: Colors.white70),
          border: InputBorder.none,
          isDense: true,
        ),
        onChanged: widget.onSearchChanged,
        onSubmitted: widget.onSearchSubmitted,
      )
          : Text(
        widget.title,
        style: const TextStyle(fontWeight: FontWeight.w600),
        overflow: TextOverflow.ellipsis,
      ),
      centerTitle: false,
      actions: actions,
    );
  }
}
