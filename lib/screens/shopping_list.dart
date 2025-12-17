import 'package:flutter/material.dart';
import "package:SmartBites/db_objects/shopping_lst.dart";
import "package:SmartBites/db_objects/cached_product.dart";
import 'package:SmartBites/screens/product_search_page.dart';
import 'package:SmartBites/screens/product_detail_page.dart';
import 'package:SmartBites/widgets/product_price_widget.dart';
import 'package:SmartBites/repositories/openfoodfacts_repository.dart';
import 'package:SmartBites/widgets/loading_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


import '../l10n/app_localizations.dart';
import '../models/product.dart';
import '../widgets/side_menu.dart';


class ShoppingListDetail extends StatefulWidget {
    final ShoppingList list;
    final User? user;

    ShoppingListDetail({super.key, required this.list, this.user});

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

            // Sinon, récupération habituelle depuis Supabase
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
                title: Text(loc.confirm),
                content: Text(loc.delete_list),
                actions: [
                    ElevatedButton(
                        child: Text(loc.no),
                        onPressed: () => Navigator.pop(context, false),
                    ),
                    ElevatedButton(
                        child: Text(loc.yes),
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
                title: Text(loc.confirm),
                content: Text(loc.delete_product),
                actions: [
                    ElevatedButton(
                        child: Text(loc.no),
                        onPressed: () => Navigator.pop(context, false),
                    ),
                    ElevatedButton(
                        child: Text(loc.yes),
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
            backgroundColor: const Color(0xFFF8F9FA),
            appBar: AppBar(
              title: Text("${loc.list} ${widget.list.name}"),
              actions: [
                  IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                          final result = await askDeleteList(context);
                          if (!context.mounted){
                              return;
                          }
                          if (result == true) {
                              Navigator.pop(context, true);
                          }
                      },
                  ),
              ],
              elevation: 0,
              centerTitle: true,
              iconTheme: const IconThemeData(color: Colors.white),
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF10CA2C),
                      Color(0xFF32D272),
                    ],
                  ),
                ),
              ),
            ),
          body: _isLoading
              ? LoadingWidget(message: loc.loading)
              : (widget.list.products.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.shopping_cart_outlined, size: 72, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              loc.empty_list,
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              loc.add_product,
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          Expanded(
                            child: ListView.separated(
                              itemCount: widget.list.products.length,
                              separatorBuilder: (context, index) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                String barcode = widget.list.products[index];
                                CachedProduct cached = cachedProducts[barcode]!;
                                int quantity = widget.list.quantities[barcode] ?? 1;

                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  elevation: 1,
                                  child: InkWell(
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ProductDetailPage(
                                          barcode: barcode,
                                          inAddMode: false,
                                        ),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          // Image du produit
                                          cached.img_small_url.trim().isEmpty
                                              ? Container(
                                                  width: 56,
                                                  height: 56,
                                                  color: Colors.grey[200],
                                                  child: const Icon(Icons.shopping_bag, color: Colors.grey),
                                                )
                                              : Image.network(
                                                  cached.img_small_url,
                                                  width: 56,
                                                  height: 56,
                                                  fit: BoxFit.cover,
                                                ),
                                          const SizedBox(width: 12),
                                          // Informations du produit
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  loc.localeName.startsWith('fr')
                                                      ? cached.fr_name
                                                      : cached.en_name,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 14,
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                if (cached.brands.isNotEmpty) ...[
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    cached.brands,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ],
                                                const SizedBox(height: 4),
                                                ProductPriceWidget(
                                                  barcode: barcode,
                                                  compact: true,
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Contrôles de quantité
                                          Column(
                                            children: [
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(Icons.remove_circle_outline),
                                                    iconSize: 24,
                                                    color: Colors.red[400],
                                                    onPressed: () {
                                                      if (quantity > 1) {
                                                        _updateQuantity(barcode, quantity - 1);
                                                      }
                                                    },
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[100],
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Text(
                                                      '$quantity',
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(Icons.add_circle_outline),
                                                    iconSize: 24,
                                                    color: Colors.green[400],
                                                    onPressed: () {
                                                      _updateQuantity(barcode, quantity + 1);
                                                    },
                                                  ),
                                                ],
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete_outline),
                                                iconSize: 20,
                                                color: Colors.red,
                                                onPressed: () async {
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
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          SafeArea(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color.fromRGBO(158, 158, 158, 0.3),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: const Offset(0, -3),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 80.0, 16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total (EUR):',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${_calculateTotal().toStringAsFixed(2)} €',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )),
            floatingActionButton: FloatingActionButton(
              backgroundColor: const Color(0xFFFFB899),
              child: const Icon(Icons.add, color: Colors.white),
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
                  widget.list.quantities[result.barcode] = 1; // Initialiser la quantité à 1

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
                  } catch (e) {
                    // Ignore
                  }

                  setState(() => cachedProducts[cached.barcode] = cached);
                }
              },
            ),
          );

    }
}

/// ------------------------------
///     MENU PRINCIPAL DES LISTES
/// ------------------------------
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
      setState(() {
        existing_lists =
            lists.map<ShoppingList>((lst) => ShoppingList.fromMap(lst)).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
      setState(() => _isLoading = false);
    }
  }

  bool _listNameAvailableForUser(String name) {
    return !existing_lists.any((lst) => lst.name == name);
  }

  void _toggleMenu() {
    _menuKey.currentState?.toggle();
  }

  Widget _buildSquareButton({
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

  Future<void> showNameTaken(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(loc.error),
        content: Text(loc.list_name_already_used),
        actions: [
          ElevatedButton(
            child: const Text("OK"),
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
        title: Text(loc.rename),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(labelText: "Nom liste"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: const Text("OK"),
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
        title: Text(loc.new_list),
        content: TextField(controller: lname_ctrl),
        actions: [
          ElevatedButton(
            child: Text(loc.cancel),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("OK"),
            onPressed: () => Navigator.pop(context, lname_ctrl.text),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      body: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 10),
          child: AppBar(
            leading: Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: _buildSquareButton(
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
                      _isMenuOpen ? Icons.close_rounded : Icons.menu_rounded,
                      key: ValueKey(_isMenuOpen),
                      color: Colors.black87,
                    ),
                  ),
                  onPressed: _toggleMenu,
                ),
              ),
            ),
            leadingWidth: 80,
            titleSpacing: 16,
            centerTitle: false,
            title: Text(
              loc.shopping_lists,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 22,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  colors: [
                    Color(0xFF10CA2C),
                    Color(0xFF32D272),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            Center(
              child: _isLoading
                  ? LoadingWidget(message: loc.loading)
                  : ReorderableListView.builder(
                itemCount: existing_lists.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex--;
                    final item = existing_lists.removeAt(oldIndex);
                    existing_lists.insert(newIndex, item);
                  });
                },
                itemBuilder: (context, index) {
                  final lst = existing_lists[index];

                  return Container(
                    key: ValueKey(lst.id),
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFCB992), // peach clair
                          Color(0xFFFCA87E), // peach plus intense
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text(
                        lst.name,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white),
                            tooltip: loc.rename,
                            onPressed: () async {
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
                          ),
                          const Icon(Icons.drag_handle, color: Colors.white),
                        ],
                      ),
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
                    ),
                  );
                },

              ),
            ),

            SideMenu(
              key: _menuKey,
              currentRoute: '/shopping',
              onOpenChanged: (isOpen) {
                setState(() => _isMenuOpen = isOpen);
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await askListName(context);
            if (result != null && result.isNotEmpty) {
              ShoppingList added = ShoppingList(
                name: result,
                user_id: user.id,
                products: [],
                quantities: {}, // Initialiser avec un Map vide
              );
              final inserted = await supabase
                  .from("shopping_list")
                  .insert(added.toMap())
                  .select();
              added.id = inserted[0]["id"];
              setState(() => existing_lists.add(added));
            }
          },
          child: const Icon(Icons.add),
        ),
      ),
    );

  }
}
