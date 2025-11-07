import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:food/l10n/app_localizations.dart';

class BottomActionBar extends StatelessWidget {
    final String currentRoute; // 👈 route actuelle
    const BottomActionBar({super.key, required this.currentRoute});

    @override
    Widget build(BuildContext context) {
        final loc = AppLocalizations.of(context)!;

        // Petite fonction utilitaire pour éviter la duplication
        void navigateIfNotCurrent(String routeName) {
            if (routeName == currentRoute) return; // 👈 empêche la duplication
            Navigator.pushNamed(context, routeName);
        }

        return BottomAppBar(
            color: Colors.white,
            elevation: 6,
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                        IconButton(
                            tooltip: loc.homePageTitle,
                            icon: const Icon(Icons.house, color: Color(0xFFFFCBA4)),
                            onPressed: () {
                                if (currentRoute != '/home') {
                                    // 👇 supprime tous les écrans précédents avant d’aller sur /home
                                    Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        '/home',
                                            (route) => false,
                                    );
                                }
                            },
                        ),
                        IconButton(
                            tooltip: loc.product_list,
                            icon: const Icon(Icons.shopping_cart, color: Colors.green),
                            onPressed: () => navigateIfNotCurrent('/shopping'),
                        ),
                        IconButton(
                            tooltip: loc.profile,
                            icon: const Icon(Icons.person, color: Colors.blueAccent),
                            onPressed: () => navigateIfNotCurrent('/profile'),
                        ),
                        IconButton(
                            tooltip: loc.disconnect,
                            icon: const Icon(Icons.logout, color: Colors.redAccent),
                            onPressed: () async {
                                await Supabase.instance.client.auth.signOut();
                                if (context.mounted) {
                                    Navigator.pushReplacementNamed(context, '/login');
                                }
                            },
                        ),
                        IconButton(
                            tooltip: loc.recipe_page,
                            icon: Image.asset('lib/ressources/cuisine_icon.png'),
                            onPressed: () => navigateIfNotCurrent('/recipe'),
                        ),
                    ],
                ),
            ),
        );
    }
}
