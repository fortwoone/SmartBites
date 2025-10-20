import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:food/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ShoppingListMenu extends StatefulWidget{
    @override
    State<ShoppingListMenu> createState() => _ShoppingListMenuState();
}

class _ShoppingListMenuState extends State<ShoppingListMenu> {
    final supabase = Supabase.instance.client;

    @override
    Widget build(BuildContext context) {
        final loc = AppLocalizations.of(context)!;
        return Scaffold(
            appBar: AppBar(
                title: Text(loc.shopping_lists),
                automaticallyImplyLeading: false,
                flexibleSpace: Container(
                    decoration: const BoxDecoration(
                        gradient: LinearGradient(
                            begin:Alignment.topLeft,
                            colors: [
                              Color.fromARGB(255, 0x10, 0xCA, 0x2C),
                              Color.fromARGB(255, 0x32, 0xD2, 0x72),
                            ]
                        )
                    ),
                ),
            ),
            body: Center(
                child: Text(
                    "DUMMY",
                    style: TextStyle(
                        fontSize: 32
                    )
                )
            )
        );
    }
}