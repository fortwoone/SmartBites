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
        return Scaffold(
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