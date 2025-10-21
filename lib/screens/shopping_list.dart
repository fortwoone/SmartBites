import "dart:math";

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:food/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import "package:food/db_objects/shopping_lst.dart";


class ShoppingListDetail extends StatefulWidget{
    final ShoppingList list;

    const ShoppingListDetail({super.key, required this.list});

    @override
    State<ShoppingListDetail> createState() => _ShoppingListDetailState();
}

class _ShoppingListDetailState extends State<ShoppingListDetail> {
    @override
    Widget build(BuildContext context){
        final loc = AppLocalizations.of(context)!;
        return Scaffold(
            appBar: AppBar(
                title: Text(loc.list + widget.list.name),
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
                )
            ),
            body: Center(
                child: ListView.builder(
                    itemCount: min(10, widget.list.products.length),
                    itemBuilder: (context, index){
                        String product_barcode = widget.list.products[index];
                        return ListTile(title: Text(product_barcode));
                    }
                )
            )
        );
    }
}


class ShoppingListMenu extends StatefulWidget{
    final Session session;

    const ShoppingListMenu({super.key, required this.session});

    @override
    State<ShoppingListMenu> createState() => _ShoppingListMenuState();
}

class _ShoppingListMenuState extends State<ShoppingListMenu> {
    final supabase = Supabase.instance.client;
    late PostgrestFilterBuilder list_query;
    late User user;
    List<ShoppingList> existing_lists = [];
    bool _isLoading = true;

    @override
    void initState(){
        user = widget.session.user;
        list_query = supabase.from("shopping_list").select();
        getUserLists();
    }

    Future<void> getUserLists() async{
        try{
            final lists = await list_query.eq("user_id", user.id);
            setState(
                (){
                    for (var lst in lists){
                        existing_lists.add(ShoppingList.fromMap(lst));
                    }
                    _isLoading = false;
                }
            );
        }
        catch(e){
            setState(
                (){
                    _isLoading = false;
                    debugPrint(e.toString());
                }
            );
        }
    }

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
                child: _isLoading ? CircularProgressIndicator()
                    : ListView.builder(
                        itemCount: min(10, existing_lists.length),
                        itemBuilder: (context, index){
                            ShoppingList lst = existing_lists[index];
                            return ListTile(
                                title: Text(lst.name, style: TextStyle(fontSize: 24)),
                                onTap: (){
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context){
                                                return ShoppingListDetail(list: lst);
                                            }
                                        )
                                    );
                                }
                            );
                        }
                    )
            )
        );
    }
}