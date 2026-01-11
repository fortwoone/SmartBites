import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../l10n/app_localizations.dart';
import '../../models/shopping_list.dart';
import '../../models/product.dart';
import '../../utils/color_constants.dart';
import '../../viewmodels/shopping_list_viewmodel.dart';
import '../../providers/app_providers.dart';
import '../../old/screens/product_search_page.dart';

class ShoppingListDetailPage extends ConsumerStatefulWidget {
  final int listId;
  final ShoppingList initialList;

  const ShoppingListDetailPage({super.key, required this.listId, required this.initialList});

  @override
  ConsumerState<ShoppingListDetailPage> createState() => _ShoppingListDetailPageState();
}

class _ShoppingListDetailPageState extends ConsumerState<ShoppingListDetailPage> {
  final Map<String, Product> _productDetails = {};
  bool _isLoadingProducts = false;
  @override
  void initState() {
    super.initState();
    _loadProductDetails();
  }

  // Charger les détails des produits de la liste
  Future<void> _loadProductDetails() async {
    final lists = ref.read(shoppingListViewModelProvider).value;
    final currentList = lists?.firstWhere((l) => l.id == widget.listId, orElse: () => widget.initialList);
    if (currentList == null || currentList.products.isEmpty) return;
    final repo = ref.read(openFoodFactsRepositoryProvider);
    final missingBarcodes = currentList.products.where((b) => !_productDetails.containsKey(b)).toList();
    if (missingBarcodes.isEmpty) return;
    setState(() => _isLoadingProducts = true);
    try {
        for (final barcode in missingBarcodes) {
           if (barcode.startsWith("TEXT:")) {
               continue;
           }
           try {
             final product = await repo.getProduct(barcode);
             if (product != null) {
                if (mounted) {
                   setState(() {
                      _productDetails[barcode] = product;
                   });
                }
             }
           } catch (e) {
               // Ignore
           }
        }
    } finally {
        if (mounted) setState(() => _isLoadingProducts = false);
    }
  }
  
  // Appelé quand on revient de la recherche
  void _onProductAdded(Product product) {
     if (!_productDetails.containsKey(product.barcode)) {
        setState(() {
           _productDetails[product.barcode] = product;
        });
     }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final shoppingListsAsync = ref.watch(shoppingListViewModelProvider);
    final currentList = shoppingListsAsync.value?.firstWhere(
      (l) => l.id == widget.listId, 
      orElse: () => widget.initialList
    );

    if (currentList == null) {
       return Scaffold(body: Center(child: Text(loc.error)));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(currentList.name, style: GoogleFonts.recursive(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
            if (_isLoadingProducts) const LinearProgressIndicator(color: AppColors.primary),
            Expanded(
              child: currentList.products.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                         const Icon(Icons.add_shopping_cart, size: 64, color: Colors.grey),
                         const SizedBox(height: 16),
                         Text(loc.empty_list, style: GoogleFonts.recursive(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: currentList.products.length,
                  itemBuilder: (context, index) {
                      final barcode = currentList.products[index];
                      final quantity = currentList.quantities[barcode] ?? 1;
                      final product = _productDetails[barcode];
                      
                      return _ShoppingListItem(
                          barcode: barcode,
                          product: product,
                          quantity: quantity,
                          onIncrement: () => _updateQuantity(currentList, barcode, quantity + 1),
                          onDecrement: () => _updateQuantity(currentList, barcode, quantity - 1),
                          onDelete: () => _removeProduct(currentList, barcode),
                      );
                  },
              ),
            ),
             _buildBottomBar(context, loc, currentList),
        ],
      ),
    );
  }

  // Barre inférieure avec le bouton d'ajout
  Widget _buildBottomBar(BuildContext context, AppLocalizations loc, ShoppingList list) {
       return Container(
         padding: const EdgeInsets.all(20),
         decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
               BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10, offset: const Offset(0, -5))
            ]
         ),
         child: SafeArea(
           child: PrimaryButton(
              label: loc.add_product,
              icon: Icons.add,
              onPressed: () async {
                  final result = await Navigator.push(
                     context,
                     MaterialPageRoute(builder: (_) => ProductSearchPage(inAddMode: true)),
                  );
                  
                  if (result != null && result is Product) {
                       _onProductAdded(result);
                       _addProductToList(list, result);
                  }
              },
           ),
         ),
       );
  }

  // Met à jour la quantité d'un produit dans la liste
  void _updateQuantity(ShoppingList list, String barcode, int newQty) {
      if (newQty < 1) return;
      final updatedQuantities = Map<String, int>.from(list.quantities);
      updatedQuantities[barcode] = newQty;
      
      final updatedList = list.copyWith(quantities: updatedQuantities);
      ref.read(shoppingListViewModelProvider.notifier).updateList(updatedList);
  }

  // Supprime un produit de la liste
  void _removeProduct(ShoppingList list, String barcode) {
      final updatedProducts = List<String>.from(list.products)..remove(barcode);
      final updatedQuantities = Map<String, int>.from(list.quantities)..remove(barcode);
      
      final updatedList = list.copyWith(products: updatedProducts, quantities: updatedQuantities);
      ref.read(shoppingListViewModelProvider.notifier).updateList(updatedList);
  }

  // Ajoute un produit à la liste
  void _addProductToList(ShoppingList list, Product product) {
      if (list.products.contains(product.barcode)) {
           _updateQuantity(list, product.barcode, (list.quantities[product.barcode] ?? 0) + 1);
           return;
      }
      final updatedProducts = List<String>.from(list.products)..add(product.barcode);
      final updatedQuantities = Map<String, int>.from(list.quantities);
      updatedQuantities[product.barcode] = 1;
      final updatedList = list.copyWith(products: updatedProducts, quantities: updatedQuantities);
      ref.read(shoppingListViewModelProvider.notifier).updateList(updatedList);
  }
}

class _ShoppingListItem extends StatelessWidget {
    final String barcode;
    final Product? product;
    final int quantity;
    final VoidCallback onIncrement;
    final VoidCallback onDecrement;
    final VoidCallback onDelete;

    const _ShoppingListItem({
        required this.barcode,
        required this.product,
        required this.quantity,
        required this.onIncrement,
        required this.onDecrement,
        required this.onDelete
    });

    @override
    Widget build(BuildContext context) {
         final name = product != null 
             ? (product!.frName ?? product!.enName ?? product!.name ?? "Produit inconnu")
             : "Chargement... ($barcode)";
         
         final imageUrl = product?.imageSmallURL;

         return Dismissible(
            key: Key(barcode),
            direction: DismissDirection.endToStart,
            background: Container(
               color: Colors.redAccent,
               alignment: Alignment.centerRight,
               padding: const EdgeInsets.only(right: 20),
               child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (_) => onDelete(),
            child: Card(
               margin: const EdgeInsets.symmetric(vertical: 6),
               elevation: 2,
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
               child: Padding(
                 padding: const EdgeInsets.all(8.0),
                 child: Row(
                    children: [
                       ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: imageUrl != null
                              ? Image.network(imageUrl, width: 60, height: 60, fit: BoxFit.cover,
                                  errorBuilder: (_,__,___) => Container(width: 60, height: 60, color: Colors.grey[200], child: const Icon(Icons.image_not_supported)))
                              : Container(width: 60, height: 60, color: Colors.grey[200], child: const CircularProgressIndicator(strokeWidth: 2)),
                       ),
                       const SizedBox(width: 12),
                       Expanded(
                           child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                   Text(name, style: GoogleFonts.recursive(fontWeight: FontWeight.w600, fontSize: 16), maxLines: 2, overflow: TextOverflow.ellipsis),
                                   if (product?.brands != null)
                                       Text(product!.brands!, style: GoogleFonts.recursive(color: Colors.grey, fontSize: 12)),
                               ],
                           ),
                       ),
                       Row(
                          children: [
                             IconButton(onPressed: onDecrement, icon: const Icon(Icons.remove_circle_outline, color: AppColors.primary)),
                             Text("$quantity", style: GoogleFonts.recursive(fontWeight: FontWeight.bold, fontSize: 16)),
                             IconButton(onPressed: onIncrement, icon: const Icon(Icons.add_circle_outline, color: AppColors.primary)),
                          ],
                       )
                    ],
                 ),
               ),
            ),
         );
    }
}
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final IconData? icon;
  const PrimaryButton({super.key, required this.label, required this.onPressed, this.isLoading = false, this.icon});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
      child: isLoading
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[Icon(icon, color: Colors.white), const SizedBox(width: 8)],
                Text(
                  label,
                  style: GoogleFonts.recursive(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
    );
  }
}
