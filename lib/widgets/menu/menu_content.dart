import 'package:flutter/material.dart';
import 'package:SmartBites/l10n/app_localizations.dart';
import 'menu_item.dart';
import 'menu_service.dart';

class MenuContent extends StatelessWidget {
  final String currentRoute;
  final VoidCallback onClose;

  const MenuContent({
    super.key,
    required this.currentRoute,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Column(
      children: [
        _buildMenuItem(
          context,
          icon: Icons.home_rounded,
          title: loc.homePageTitle,
          routeName: '/home',
        ),
        _buildMenuItem(
          context,
          icon: Icons.list_alt_rounded,
          title: loc.list_menu,
          routeName: '/shopping',
        ),
        _buildMenuItem(
          context,
          icon: Icons.menu_book_rounded,
          title: loc.recipes,
          routeName: '/recipe',
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String routeName,
  }) {
    final selected = routeName == currentRoute;

    return MenuItem(
      icon: icon,
      title: title,
      routeName: routeName,
      isSelected: selected,
      onTap: () => MenuService.navigateIfNotCurrent(
        context,
        routeName,
        currentRoute,
        onClose,
      ),
    );
  }
}

