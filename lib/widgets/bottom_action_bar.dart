import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:food/l10n/app_localizations.dart';

class BottomActionBar extends StatelessWidget {
  const BottomActionBar({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return BottomAppBar(
      color: Colors.white,
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              tooltip: loc.product_list,
              icon: const Icon(Icons.shopping_cart, color: Colors.green),
              onPressed: () => Navigator.pushNamed(context, '/shopping'),
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
          ],
        ),
      ),
    );
  }
}
