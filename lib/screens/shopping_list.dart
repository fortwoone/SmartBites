import 'package:flutter/material.dart';
import 'package:food/l10n/app_localizations.dart';
import 'package:food/models/product.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import "package:food/db_objects/shopping_lst.dart";
import "package:food/db_objects/cached_product.dart";
import 'package:food/screens/product_search_page.dart';
import 'package:food/screens/product_detail_page.dart';
import 'package:food/widgets/product_price_widget.dart';
import 'package:food/repositories/openfoodfacts_repository.dart';


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
            // Si c’est un produit texte (ajout manuel), on crée une "fausse" entrée
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

    double _calculateTotal() {
        double total = 0.0;
        for (var price in productPrices.values) {
            total += price;
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
                ? const Center(child: CircularProgressIndicator())
                : (widget.list.products.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.shopping_cart_outlined, size: 72, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            const Text(
                              'Votre panier est vide',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Ajoutez des produits en appuyant sur +',
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

                                return ListTile(
                                  leading: cached.img_small_url.trim().isEmpty
                                      ? const SizedBox(width: 56, height: 56)
                                      : Image.network(
                                          cached.img_small_url,
                                          width: 56,
                                          height: 56,
                                          fit: BoxFit.cover,
                                        ),
                                  title: Text(
                                    loc.localeName.startsWith('fr')
                                        ? cached.fr_name
                                        : cached.en_name,
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(cached.brands),
                                      const SizedBox(height: 4),
                                      ProductPriceWidget(
                                        barcode: barcode,
                                        compact: true,
                                      ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () async {
                                      final result = await askDeleteProduct(context);
                                      if (result == true) {
                                        List<String> updated = List.from(widget.list.products);
                                        updated.removeAt(index);
                                        await supabase
                                            .from("shopping_list")
                                            .update({"products": updated})
                                            .eq("id", widget.list.id!);
                                        setState(() {
                                          widget.list.products = updated;
                                          cachedProducts.remove(barcode);
                                          productPrices.remove(barcode);
                                        });
                                      }
                                    },
                                  ),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductDetailPage(
                                        barcode: barcode,
                                        inAddMode: false,
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
                  await supabase
                      .from("shopping_list")
                      .update({"products": widget.list.products})
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
      appBar: AppBar(
        title: Text(loc.shopping_lists),
        automaticallyImplyLeading: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              colors: [
                Color.fromARGB(255, 0x10, 0xCA, 0x2C),
                Color.fromARGB(255, 0x32, 0xD2, 0x72),
              ],
            ),
          ),
        ),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
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
                      builder: (context) => ShoppingListDetail(list: lst, user: user),
                    ),
                  );
                  if (result == true) {
                    await supabase.from("shopping_list").delete().eq("id", lst.id!);
                    setState(() => existing_lists.removeAt(index));
                  }
                },
              ),
            );
          },

        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await askListName(context);
          if (result != null && result.isNotEmpty) {
            if (!_listNameAvailableForUser(result)) {
              if (!context.mounted) return;
              await showNameTaken(context);
              return;
            }

            ShoppingList added_lst = ShoppingList(
              name: result,
              user_id: user.id,
              products: [],
            );
            final inserted = await supabase
                .from("shopping_list")
                .insert(added_lst.toMap())
                .select();
            added_lst.id = inserted[0]["id"];
            setState(() => existing_lists.add(added_lst));
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
