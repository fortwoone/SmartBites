import 'package:flutter/material.dart';
import "package:SmartBites/db_objects/shopping_lst.dart";
import "package:SmartBites/db_objects/cached_product.dart";
import 'package:SmartBites/screens/product_search_page.dart';
import 'package:SmartBites/screens/product_detail_page.dart';
import 'package:SmartBites/repositories/openfoodfacts_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';
import '../models/product.dart';
import '../utils/color_constants.dart';
import '../widgets/side_menu.dart';
import '../widgets/recipe/recipe_background.dart';
import '../widgets/shopping_list/shopping_list_header.dart';
import '../widgets/shopping_list/shopping_list_card.dart';
import '../widgets/shopping_list/shopping_list_item.dart';
import '../widgets/primary_button.dart';


class ShoppingListDetail extends StatefulWidget {
    final ShoppingList list;
    final User? user;

    const ShoppingListDetail({super.key, required this.list, this.user});

    @override
    State<ShoppingListDetail> createState() => _ShoppingListDetailState();
}

class _ShoppingListDetailState extends State<ShoppingListDetail> {
    bool _isLoading = true;
    Map<String, CachedProduct> cachedProducts = {};
    Map<String, double> productPrices = {};
    final supabase = Supabase.instance.client;

    @override
    void initState() {
        super.initState();
        _getCachedProductData();
    }

    Future<void> _getCachedProductData() async {
        for (String barcode in widget.list.products) {
            if (barcode.startsWith("TEXT:")) {
                final name = barcode.substring(5);
                cachedProducts[barcode] = CachedProduct(
                    barcode: barcode,
                    img_small_url: "",
                    brands: "",
                    fr_name: name,
                    en_name: name,
                );
              continue;
            }

            final result = await supabase.rpc(
                "get_cache_entry",
                params: {"p_barcode": barcode},
            );
            if (result != null) {
                cachedProducts[barcode] = CachedProduct.fromMap(result);
            }
            await _loadPrices();
        }
        setState(() => _isLoading = false);
    }

    Future<void> _loadPrices() async {
        final repository = OpenFoodFactsRepository();
        for (String barcode in widget.list.products) {
            try {
                final price = await repository.getLatestPrice(barcode);
                if (price != null && price.currency.toUpperCase() == 'EUR') {
                    productPrices[barcode] = price.price;
                }
            } catch (e) {
                // Ignore
            }
        }
    }

    Future<void> _updateQuantity(String barcode, int newQuantity) async {
        if (newQuantity <= 0) return;

        setState(() {
            widget.list.quantities[barcode] = newQuantity;
        });

        await supabase
            .from("shopping_list")
            .update({"quantities": widget.list.quantities})
            .eq("id", widget.list.id!);
    }

    double _calculateTotal() {
        double total = 0.0;
        for (var entry in productPrices.entries) {
            final barcode = entry.key;
            final price = entry.value;
            final quantity = widget.list.quantities[barcode] ?? 1;
            total += price * quantity;
        }
        return total;
    }

    Future<bool?> askDeleteList(BuildContext context) async {
        final loc = AppLocalizations.of(context)!;
        return showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
                title: Text(loc.confirm, style: GoogleFonts.recursive(fontWeight: FontWeight.bold)),
                content: Text(loc.delete_list, style: GoogleFonts.recursive()),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                actions: [
                    TextButton(
                        child: Text(loc.no, style: GoogleFonts.recursive()),
                        onPressed: () => Navigator.pop(context, false),
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        child: Text(loc.yes, style: GoogleFonts.recursive(color: Colors.white)),
                        onPressed: () => Navigator.pop(context, true),
                    ),
                ],
            ),
        );
    }

    Future<bool?> askDeleteProduct(BuildContext context) async {
        final loc = AppLocalizations.of(context)!;
        return showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
                title: Text(loc.confirm, style: GoogleFonts.recursive(fontWeight: FontWeight.bold)),
                content: Text(loc.delete_product, style: GoogleFonts.recursive()),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                actions: [
                    TextButton(
                        child: Text(loc.no, style: GoogleFonts.recursive()),
                        onPressed: () => Navigator.pop(context, false),
                    ),
                    ElevatedButton(
                         style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        child: Text(loc.yes, style: GoogleFonts.recursive(color: Colors.white)),
                        onPressed: () => Navigator.pop(context, true),
                    ),
                ],
            ),
        );
    }

    Future<Product?> askAddProduct(BuildContext context) async {
        return Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ProductSearchPage(inAddMode: true),
            ),
        );
    }

    @override
    Widget build(BuildContext context) {
        final loc = AppLocalizations.of(context)!;

        return Scaffold(
            body: Stack(
                children: [
                    const RecipeBackground(),
                    SafeArea(
                        child: Column(
                            children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                       Container(
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(12),
                                                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 4))],
                                            ),
                                            child: IconButton(
                                                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
                                                onPressed: () => Navigator.pop(context),
                                            ),
                                        ),
                                        Text(widget.list.name, style: GoogleFonts.recursive(fontSize: 22, fontWeight: FontWeight.bold)),
                                        Container(
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(12),
                                                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 4))],
                                            ),
                                            child: IconButton(
                                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                                onPressed: () async {
                                                    final result = await askDeleteList(context);
                                                    if (!context.mounted) return;
                                                    if (result == true) Navigator.pop(context, true);
                                                },
                                            ),
                                        ),
                                    ],
                                  ),
                                ),
                                
                                Expanded(
                                    child: _isLoading
                                    ? const Center(child: CircularProgressIndicator(color: primaryPeach))
                                    : widget.list.products.isEmpty
                                        ? Center(
                                            child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                                Icon(Icons.shopping_cart_outlined, size: 72, color: Colors.grey[400]),
                                                const SizedBox(height: 16),
                                                Text(
                                                loc.empty_list,
                                                style: GoogleFonts.recursive(fontSize: 18, color: Colors.grey),
                                                ),
                                            ],
                                            ),
                                        )
                                        : ListView.builder(
                                            padding: const EdgeInsets.all(16),
                                            itemCount: widget.list.products.length,
                                            itemBuilder: (context, index) {
                                                String barcode = widget.list.products[index];
                                                CachedProduct cached = cachedProducts[barcode]!;
                                                int quantity = widget.list.quantities[barcode] ?? 1;

                                                return ShoppingListItem(
                                                    barcode: barcode,
                                                    cached: cached,
                                                    quantity: quantity,
                                                    onTap: () => Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) => ProductDetailPage(
                                                            barcode: barcode,
                                                            inAddMode: false,
                                                            ),
                                                        ),
                                                    ),
                                                    onIncrement: () => _updateQuantity(barcode, quantity + 1),
                                                    onDecrement: () {
                                                        if (quantity > 1) _updateQuantity(barcode, quantity - 1);
                                                    },
                                                    onDelete: () async {
                                                        final result = await askDeleteProduct(context);
                                                        if (result == true) {
                                                            List<String> updated = List.from(widget.list.products);
                                                            updated.removeAt(index);
                                                            widget.list.quantities.remove(barcode);
                                                            await supabase
                                                                .from("shopping_list")
                                                                .update({
                                                                    "products": updated,
                                                                    "quantities": widget.list.quantities
                                                                })
                                                                .eq("id", widget.list.id!);
                                                            setState(() {
                                                                widget.list.products = updated;
                                                                cachedProducts.remove(barcode);
                                                                productPrices.remove(barcode);
                                                            });
                                                        }
                                                    },
                                                    isFrench: loc.localeName.startsWith('fr'),
                                                );
                                            },
                                        ),
                                ),
                               Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                                        boxShadow: [
                                            BoxShadow(
                                                color: Colors.grey.withAlpha(20),
                                                blurRadius: 20,
                                                offset: const Offset(0, -5),
                                            )
                                        ]
                                    ),
                                    child: SafeArea(
                                        child: Column(
                                            children: [
                                                Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                        Text("Total (EUR)", style: GoogleFonts.recursive(fontSize: 18, color: Colors.grey.shade600)),
                                                        Text(
                                                            '${_calculateTotal().toStringAsFixed(2)} €',
                                                            style: GoogleFonts.recursive(
                                                                fontSize: 24,
                                                                fontWeight: FontWeight.bold,
                                                                color: primaryPeach,
                                                            ),
                                                        ),
                                                    ],
                                                ),
                                                const SizedBox(height: 16),
                                                PrimaryButton(
                                                    onPressed: () async {
                                                        final result = await askAddProduct(context);
                                                        if (result != null) {
                                                                CachedProduct cached = CachedProduct(
                                                                    barcode: result.barcode,
                                                                    img_small_url: result.imageSmallURL ?? "",
                                                                    brands: result.brands ?? "",
                                                                    fr_name: result.frName ?? result.name!,
                                                                    en_name: result.enName ?? result.name!,
                                                                );
                                            
                                                                await supabase.rpc("add_entry_to_cache", params: {
                                                                    "product_barcode": cached.barcode,
                                                                    "p_img_small_url": cached.img_small_url,
                                                                    "p_brands": cached.brands,
                                                                    "p_fr_name": cached.fr_name,
                                                                    "p_en_name": cached.en_name,
                                                                });
                                            
                                                                widget.list.products.add(result.barcode);
                                                                widget.list.quantities[result.barcode] = 1; 
                                            
                                                                await supabase
                                                                    .from("shopping_list")
                                                                    .update({
                                                                        "products": widget.list.products,
                                                                        "quantities": widget.list.quantities
                                                                    })
                                                                    .eq("id", widget.list.id!);
                                            
                                                                final repository = OpenFoodFactsRepository();
                                                                try {
                                                                    final price = await repository.getLatestPrice(result.barcode);
                                                                    if (price != null && price.currency.toUpperCase() == 'EUR') {
                                                                    productPrices[result.barcode] = price.price;
                                                                    }
                                                                } catch (e) { /* Ignore */ }
                                            
                                                                setState(() => cachedProducts[cached.barcode] = cached);
                                                        }
                                                    },
                                                    label: loc.add_product,
                                                    icon: Icons.add,
                                                )
                                            ],
                                        ),
                                    ),
                                )
                            ],
                        ),
                    ),
                ],
            )
        );
    }
}

class ShoppingListMenu extends StatefulWidget {
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
  final GlobalKey<SideMenuState> _menuKey = GlobalKey<SideMenuState>();
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    user = widget.session.user;
    list_query = supabase.from("shopping_list").select();
    getUserLists();
  }

  Future<void> getUserLists() async {
    try {
      final lists = await list_query.eq("user_id", user.id);
      if(!mounted) return;
      setState(() {
        existing_lists =
            lists.map<ShoppingList>((lst) => ShoppingList.fromMap(lst)).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
      if(mounted) setState(() => _isLoading = false);
    }
  }

  bool _listNameAvailableForUser(String name) {
    return !existing_lists.any((lst) => lst.name == name);
  }

  void _toggleMenu() {
    _menuKey.currentState?.toggle();
  }

  Future<void> showNameTaken(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(loc.error, style: GoogleFonts.recursive(fontWeight: FontWeight.bold)),
        content: Text(loc.list_name_already_used, style: GoogleFonts.recursive()),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryPeach, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: const Text("OK", style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<String?> _askRenameList(
      BuildContext context, String currentName) async {
    final loc = AppLocalizations.of(context)!;
    final ctrl = TextEditingController(text: currentName);

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.rename, style: GoogleFonts.recursive(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(labelText: "Nom liste", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          style: GoogleFonts.recursive(),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.cancel, style: GoogleFonts.recursive()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryPeach, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: const Text("OK", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<String?> askListName(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;
    lname_ctrl.clear();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.new_list, style: GoogleFonts.recursive(fontWeight: FontWeight.bold)),
        content: TextField(
            controller: lname_ctrl, 
            style: GoogleFonts.recursive(),
            decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            child: Text(loc.cancel, style: GoogleFonts.recursive()),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryPeach, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: const Text("OK", style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.pop(context, lname_ctrl.text),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final topPadding = MediaQuery.of(context).padding.top + 80;

    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: ShoppingListHeader(
            isMenuOpen: _isMenuOpen,
            onToggleMenu: _toggleMenu,
            onAddList: () async {
                final result = await askListName(context);
                if (result != null && result.isNotEmpty) {
                    ShoppingList added = ShoppingList(
                        name: result,
                        user_id: user.id,
                        products: [],
                        quantities: {},
                    );
                    final inserted = await supabase
                        .from("shopping_list")
                        .insert(added.toMap())
                        .select();
                    added.id = inserted[0]["id"];
                    setState(() => existing_lists.add(added));
                }
            },
        ),
        body: Stack(
          children: [
            const RecipeBackground(),

            Padding(
              padding: EdgeInsets.only(top: topPadding),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: primaryPeach))
                  : existing_lists.isEmpty
                      ? Center(child: Text("Aucune liste. Créez-en une !", style: GoogleFonts.recursive(color: Colors.grey)))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: existing_lists.length,
                          itemBuilder: (context, index) {
                              final lst = existing_lists[index];
                              return ShoppingListCard(
                                  list: lst,
                                  onTap: () async {
                                      final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => ShoppingListDetail(list: lst, user: user),
                                          ),
                                      );
                                      if (result == true) {
                                          await supabase
                                              .from("shopping_list")
                                              .delete()
                                              .eq("id", lst.id!);
                                          setState(() => existing_lists.removeAt(index));
                                      }
                                  },
                                  onEdit: () async {
                                      final newName = await _askRenameList(context, lst.name);
                                          if (newName != null && newName.isNotEmpty) {
                                              if (!_listNameAvailableForUser(newName)) {
                                                  await showNameTaken(context);
                                                  return;
                                              }
                                              await supabase
                                                  .from('shopping_list')
                                                  .update({'name': newName})
                                                  .eq('id', lst.id!);
                                              setState(() => lst.name = newName);
                                          }
                                  },
                                  onDelete: () async {
                                       final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                              title: Text(loc.confirm, style: GoogleFonts.recursive(fontWeight: FontWeight.bold)),
                                              content: Text(loc.delete_list, style: GoogleFonts.recursive()),
                                              actions: [
                                                  TextButton(onPressed: ()=>Navigator.pop(context, false), child: Text(loc.cancel)),
                                                  ElevatedButton(onPressed: ()=>Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: Text(loc.delete, style: const TextStyle(color: Colors.white))),
                                              ],
                                          )
                                       );
                                       if(confirm == true) {
                                            await supabase
                                              .from("shopping_list")
                                              .delete()
                                              .eq("id", lst.id!);
                                          setState(() => existing_lists.removeAt(index));
                                       }
                                  },
                              );
                          },
                      ),
            ),

            Padding(
               padding: EdgeInsets.only(top: topPadding),
               child: MediaQuery.removePadding(
                 context: context,
                 removeTop: true,
                 child: SideMenu(
                    key: _menuKey,
                    currentRoute: '/shopping',
                    onOpenChanged: (isOpen) {
                      setState(() => _isMenuOpen = isOpen);
                    },
                  ),
               ),
            ),
          ],
        ),
    );
  }
}
