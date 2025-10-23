import "dart:math";

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:food/l10n/app_localizations.dart';
import 'package:food/models/product.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import "package:food/db_objects/shopping_lst.dart";
import "package:food/db_objects/cached_product.dart";
import 'package:food/screens/product_search_page.dart';
import 'package:food/screens/product_detail_page.dart';


class ShoppingListDetail extends StatefulWidget{
    ShoppingList list;
    User? user;

    ShoppingListDetail({super.key, required this.list, this.user});

    @override
    State<ShoppingListDetail> createState() => _ShoppingListDetailState();
}

class _ShoppingListDetailState extends State<ShoppingListDetail> {
    bool _isLoading = true;
    Map<String, CachedProduct> cachedProducts = {};
    final supabase = Supabase.instance.client;

    @override
    void initState(){
        super.initState();
        _isLoading = true;
        _getCachedProductData();
    }

    Future<void> _getCachedProductData() async{
        Map<String, dynamic>? result;
        for (String barcode in widget.list.products){
            result = await supabase.rpc(
                "get_cache_entry",
                params: {
                    "p_barcode": barcode
                }
            );
            if (result != null){
                cachedProducts[barcode] = CachedProduct.fromMap(result);
            }
        }
        setState(
            (){
                _isLoading = false;
            }
        );
    }

    Future<bool?> askDeleteList(BuildContext context) async{
        final loc = AppLocalizations.of(context)!;

        return showDialog(
            context: context,
            builder: (context){
                return AlertDialog(
                    title: Text(loc.confirm),
                    content: Text(loc.delete_list),
                    actions: [
                        ElevatedButton(
                            child: Text(loc.no),
                            onPressed: () => Navigator.pop(context, false)
                        ),
                        ElevatedButton(
                            child: Text(loc.yes),
                            onPressed: () => Navigator.pop(context, true)
                        )
                    ]
                );
            }
        );
    }

    Future<bool?> askDeleteProduct(BuildContext context) async{
        final loc = AppLocalizations.of(context)!;

        return showDialog(
            context: context,
            builder: (context){
                return AlertDialog(
                    title: Text(loc.confirm),
                    content: Text(loc.delete_product),
                    actions: [
                        ElevatedButton(
                            child: Text(loc.no),
                            onPressed: () => Navigator.pop(context)
                        ),
                        ElevatedButton(
                            child: Text(loc.yes),
                            onPressed: () => Navigator.pop(context, true)
                        )
                    ]
                );
            }
        );
    }

    Future<Product?> askAddProduct(BuildContext context) async{
        final loc = AppLocalizations.of(context)!;

        return Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ProductSearchPage(inAddMode: true)
            )
        );
    }

    @override
    Widget build(BuildContext context){
        final loc = AppLocalizations.of(context)!;
        return Scaffold(
            appBar: AppBar(
                title: Text(loc.list + widget.list.name),
                actions: [
                    IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async{
                            final bool? result = await askDeleteList(context);
                            if (!context.mounted){
                                return;
                            }
                            if (result != null){
                                if (result){
                                    Navigator.pop(context, true);
                                }
                            }
                            else{
                                debugPrint("Result was null");
                            }
                        }
                    )
                ],
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
                child: _isLoading? const CircularProgressIndicator()
                : ListView.builder(
                    itemCount: widget.list.products.length,
                    itemBuilder: (context, index){
                        String product_barcode = widget.list.products[index];
                        CachedProduct cached_entry = cachedProducts[product_barcode]!;

                        return ListTile(
                            leading: (cached_entry.img_small_url.trim().isEmpty)
                            ? const SizedBox(width: 56, height: 56)
                            : Image.network(
                                cached_entry.img_small_url,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover
                            ),
                            title: Text(
                                loc.localeName.startsWith('fr')
                                ? cached_entry.fr_name
                                : cached_entry.en_name
                            ),
                            subtitle: Text(cached_entry.brands),
                            trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () async{
                                    final result = await askDeleteProduct(context);
                                    if (!context.mounted){
                                        return;
                                    }

                                    if (result != null){
                                        if (result){
                                            // D'abord on retire le produit de la liste
                                            List<String> computed_products = List<String>.from(widget.list.products);
                                            computed_products.removeAt(index);
                                            // On applique les changements à la BD
                                            await supabase.from(
                                                "shopping_list"
                                            ).update(
                                                {"products": computed_products}
                                            ).eq("id", widget.list.id!);
                                            setState(
                                                (){
                                                    widget.list.products = computed_products;
                                                    cachedProducts.remove(product_barcode);
                                                }
                                            );
                                        }
                                    }
                                }
                            ),
                            onTap: (){
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ProductDetailPage(
                                            barcode: product_barcode,
                                            inAddMode: false
                                        )
                                    )
                                );
                            }
                        );
                    }
                )
            ),
            floatingActionButton: FloatingActionButton(
                child: const Icon(Icons.add),
                onPressed: () async{
                    final result = await askAddProduct(context);
                    if (!context.mounted){
                        return;
                    }

                    if (result != null){
                        CachedProduct cached = CachedProduct(
                            barcode: result.barcode,
                            img_small_url: result.imageSmallURL ?? "",
                            brands: result.brands ?? "",
                            fr_name: result.frName ?? result.name!,
                            en_name: result.enName ?? result.name!
                        );

                        final bool wasAddedToCache = await supabase.rpc(
                            "add_entry_to_cache",
                            params: {
                                "product_barcode": cached.barcode,
                                "p_img_small_url": cached.img_small_url,
                                "p_brands": cached.brands,
                                "p_fr_name": cached.fr_name,
                                "p_en_name": cached.en_name
                            }
                        );

                        widget.list.products.add(result.barcode);
                        // On applique les changements à la BD
                        final _ = await supabase.from(
                            "shopping_list"
                        ).update(
                            {"products": widget.list.products}
                        ).eq("id", widget.list.id!).select();
                        setState(
                            (){
                                _isLoading = false;
                                cachedProducts[cached.barcode] = cached;
                            }
                        );
                    }
                }
            ),
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
    TextEditingController lname_ctrl = TextEditingController();

    @override
    void initState(){
    super.initState();
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

    bool _listNameAvailableForUser(String name){
        for (ShoppingList lst in existing_lists){
            if (lst.name == name){
                return false;
            }
        }
        return true;
    }

    Future<void> showNameTaken(BuildContext context) async{
        final loc = AppLocalizations.of(context)!;

        return showDialog(
            context: context,
            builder: (context){
                return AlertDialog(
                    title: Text(loc.error),
                    content: Text(loc.list_name_already_used),
                    actions: [
                        ElevatedButton(
                            child: Text("OK"),
                            onPressed: () => Navigator.pop(context)
                        ),
                    ]
                );
            }
        );
    }

    Future<String?> askListName(BuildContext context) async{
        final loc = AppLocalizations.of(context)!;

        return showDialog(
            context: context,
            builder: (context){
                return AlertDialog(
                    title: Text(loc.new_list),
                    content: TextField(
                        controller: lname_ctrl
                    ),
                    actions: [
                        ElevatedButton(
                            child: Text(loc.cancel),
                            onPressed: () => Navigator.pop(context)
                        ),
                        ElevatedButton(
                            child: Text("OK"),
                            onPressed: () => Navigator.pop(context, lname_ctrl.text)
                        )
                    ]
                );
            }
        );
    }

    @override
    Widget build(BuildContext context) {
        final loc = AppLocalizations.of(context)!;
        return Scaffold(
            appBar: AppBar(
                title: Text(loc.shopping_lists),
                automaticallyImplyLeading: true,
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
                                onTap: () async{
                                    final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context){
                                                return ShoppingListDetail(list: lst, user: user);
                                            }
                                        )
                                    );
                                    if (result != null){
                                        if (result){
                                            await supabase.from(
                                                "shopping_list"
                                            ).delete().eq("id", lst.id!);
                                            setState(
                                                (){
                                                    existing_lists.removeAt(index);
                                                }
                                            );
                                        }
                                    }
                                    else{
                                        debugPrint("Result was null");
                                    }
                                }
                            );
                        }
                    )
            ),
            floatingActionButton: FloatingActionButton(
                onPressed: () async{
                    final result = await askListName(context);
                    if (result != null){
                        if (!_listNameAvailableForUser(result)){
                            if (!context.mounted) {
                                return;
                            }
                            await showNameTaken(context);
                            return;
                        }

                        ShoppingList added_lst = ShoppingList(
                            name: result.toString(),
                            user_id: user.id,
                            products: []
                        );
                        List<Map<String, dynamic>> inserted = await supabase.from(
                            "shopping_list"
                        ).insert(added_lst.toMap()).select();
                        added_lst.id = inserted[0]["id"];
                        setState(
                            (){
                                existing_lists.add(added_lst);
                            }
                        );
                    }
                },
                child: const Icon(Icons.add)
            ),
        );
    }
}