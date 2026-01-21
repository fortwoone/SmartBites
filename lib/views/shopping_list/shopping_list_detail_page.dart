import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../l10n/app_localizations.dart';
import '../../models/shopping_list.dart';
import '../../models/product.dart';
import '../../utils/color_constants.dart';
import '../../viewmodels/shopping_list_viewmodel.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common/custom_page_header.dart';
import '../product/product_search_page.dart';

class ShoppingListDetailPage extends ConsumerStatefulWidget {
  final int listId;
  final ShoppingList initialList;

  const ShoppingListDetailPage({
    super.key,
    required this.listId,
    required this.initialList,
  });

  @override
  ConsumerState<ShoppingListDetailPage> createState() =>
      _ShoppingListDetailPageState();
}

class _ShoppingListDetailPageState
    extends ConsumerState<ShoppingListDetailPage> {
  final Map<String, Product> _productDetails = {};
  bool _isLoadingProducts = false;
  final Map<String, double> _productPrices = {};
  final Set<String> _selectedItems = {};
  bool get _isSelectionMode => _selectedItems.isNotEmpty;


  @override
  void initState() {
    super.initState();
    _loadProductDetails();
  }

  // Charger les détails des produits et récupérer les prix
  Future<void> _loadProductDetails() async {
    final lists = ref.read(shoppingListViewModelProvider).value;
    final currentList = lists?.firstWhere(
          (l) => l.id == widget.listId,
      orElse: () => widget.initialList,
    );

    if (currentList == null || currentList.products.isEmpty) return;

    final repo = ref.read(openFoodFactsRepositoryProvider);
    final missingBarcodes = currentList.products
        .where((b) => !_productDetails.containsKey(b))
        .toList();

    if (missingBarcodes.isEmpty) return;

    setState(() => _isLoadingProducts = true);

    try {
      for (final barcode in missingBarcodes) {
        if (barcode.startsWith("TEXT:")) {
          _productPrices[barcode] = 0;
          continue;
        }

        try {
          final product = await repo.getProduct(barcode);
          if (product != null && mounted) {
            _productDetails[barcode] = product;
          }
          final prices = await repo.getPrices(barcode);
          if (prices.isNotEmpty) {
            _productPrices[barcode] = prices.first.price;
          } else {
            _productPrices[barcode] = 0;
          }
        } catch (e) {
          _productPrices[barcode] = 0;
        }
      }
    } finally {
      if (mounted) setState(() => _isLoadingProducts = false);
    }
  }

  Future<void> _onProductAdded(Product product) async {
    if (!_productDetails.containsKey(product.barcode)) {
      setState(() => _productDetails[product.barcode] = product);
    }

     if (!_productPrices.containsKey(product.barcode)) {
        try {
             if (product.barcode.startsWith("TEXT:")) {
               setState(() => _productPrices[product.barcode] = 0.0);
               return;
             }
            
            final repo = ref.read(openFoodFactsRepositoryProvider);
            final prices = await repo.getPrices(product.barcode);
             if (mounted) {
                setState(() {
                    _productPrices[product.barcode] = prices.isNotEmpty ? prices.first.price : 0.0;
                });
             }
        } catch (e) {
             print("Error fetching price for new product: $e");
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final shoppingListsAsync = ref.watch(shoppingListViewModelProvider);
    final currentList = shoppingListsAsync.value?.firstWhere(
            (l) => l.id == widget.listId,
        orElse: () => widget.initialList);

    if (currentList == null) {
      return Scaffold(body: Center(child: Text(loc.error)));
    }

    final totalPrice = _calculateTotal(currentList);
    final sortedProducts = List<String>.from(currentList.products);
    sortedProducts.sort((a, b) {
      final aChecked = currentList.checkedItems.contains(a);
      final bChecked = currentList.checkedItems.contains(b);
      if (aChecked == bChecked) return 0;
      return aChecked ? 1 : -1;
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: Stack(
        children: [
            Column(
              children: [
                const SizedBox(height: 120),
                if (_isLoadingProducts)
                  const LinearProgressIndicator(color: AppColors.primary, backgroundColor: Color(0xFFF8F9FD)),
                
                Expanded(
                  child: currentList.products.isEmpty
                      ? _buildEmptyState(loc)
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 0, bottom: 100, left: 16, right: 16),
                          itemCount: sortedProducts.length,
                          itemBuilder: (context, index) {
                            final barcode = sortedProducts[index];
                            final quantity = currentList.quantities[barcode] ?? 1;
                            final product = _productDetails[barcode];
                            final isChecked = currentList.checkedItems.contains(barcode);

                            return _buildShoppingCard(context, currentList, barcode, product, quantity, isChecked);
                          },
                        ),
                ),
              ],
            ),
           Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _isSelectionMode
                  ? _buildSelectionHeader(currentList)
                  : CustomPageHeader(
                      title: currentList.name,
                      showBackButton: true,
                      onBackTap: () => Navigator.pop(context),
                    ),
            ),
           Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomBar(context, loc, currentList, totalPrice),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations loc) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 5))
                ]
              ),
              child: const Icon(Icons.add_shopping_cart_rounded, size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            Text(
              loc.empty_list,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500
              ),
            ),
          ],
        ),
      );
  }

  Widget _buildShoppingCard(BuildContext context, ShoppingList list, String barcode, Product? product, int quantity, bool isChecked) {
      final isTextProduct = barcode.startsWith("TEXT:");
      final name = isTextProduct
          ? barcode.replaceFirst("TEXT:", "")
          : product != null
          ? (product.frName ?? product.enName ?? product.name ?? "Produit inconnu")
          : "Chargement...";

      final imageUrl = product?.imageSmallURL;
      final price = _productPrices[barcode] ?? 0;
      final totalItemPrice = price * quantity;
      final isSelected = _selectedItems.contains(barcode);

      return Dismissible(
        key: Key(barcode),
        direction: _isSelectionMode ? DismissDirection.none : DismissDirection.endToStart,
        background: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFFE5E5),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          child: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
        ),
        onDismissed: (_) => _removeProduct(list, barcode),
        child: GestureDetector(
          onTap: () {
            if (_isSelectionMode) {
              _toggleSelection(barcode);
            } else {
              _toggleChecked(list, barcode);
            }
          },
          onLongPress: () {
            if (!_isSelectionMode) {
              setState(() => _selectedItems.add(barcode));
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected 
                  ? AppColors.primary.withOpacity(0.08)
                  : isChecked ? Colors.grey.shade50 : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected 
                    ? AppColors.primary.withOpacity(0.3)
                    : isChecked ? Colors.transparent : Colors.grey.shade100,
                width: isSelected ? 2 : 1
              ),
              boxShadow: isChecked ? [
              ] : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2)
                )
              ]
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _toggleSelection(barcode),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? AppColors.primary 
                          : isChecked ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected 
                            ? AppColors.primary 
                            : isChecked ? AppColors.primary : Colors.grey.shade300,
                        width: 2
                      )
                    ),
                    child: (isSelected || isChecked)
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                  ),
                ),
                
                const SizedBox(width: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 56,
                    height: 56,
                    color: Colors.grey.shade50,
                    child: isTextProduct
                      ? const Icon(Icons.shopping_bag_outlined, color: Colors.grey, size: 24)
                      : imageUrl != null 
                        ? Image.network(imageUrl, fit: BoxFit.cover)
                        : const Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 24),
                  ),
                ),

                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isChecked ? Colors.grey.shade400 : Colors.black87,
                          decoration: isChecked ? TextDecoration.lineThrough : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${totalItemPrice.toStringAsFixed(2)} €",
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isChecked ? Colors.grey.shade300 : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isChecked)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _QuantityBtn(icon: Icons.remove, onTap: () => _updateQuantity(list, barcode, quantity - 1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          "$quantity",
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                      ),
                      _QuantityBtn(icon: Icons.add, onTap: () => _updateQuantity(list, barcode, quantity + 1)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }


  // Calcul du prix total
  double _calculateTotal(ShoppingList list) {
    double total = 0;
    for (final barcode in list.products) {
      if (list.checkedItems.contains(barcode)) continue;
      final qty = list.quantities[barcode] ?? 1;
      final price = _productPrices[barcode] ?? 0;
      total += price * qty;
    }
    return total;
  }

  // Barre inférieure avec le bouton d'ajout
  Widget _buildBottomBar(
      BuildContext context, AppLocalizations loc, ShoppingList list, double totalPrice) {
    double total = 0;
    double checkedTotal = 0;
    for (final barcode in list.products) {
      final qty = list.quantities[barcode] ?? 1;
      final price = _productPrices[barcode] ?? 0;
      final t = price * qty;
      total += t;
      if (list.checkedItems.contains(barcode)) checkedTotal += t;
    }

    return ClipRRect(
        child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
                ]
            ),
            child: Row(
                children: [
                Expanded(
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                        Text(
                        "Total",
                        style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 2),
                        Text(
                        "${total.toStringAsFixed(2)} €",
                        style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
                        ),
                    ],
                    ),
                ),
                GestureDetector(
                    onTap: () async {
                        final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => ProductSearchPage(inAddMode: true)));

                        if (result != null && result is Product) {
                            _onProductAdded(result);
                            _addProductToList(list, result);
                        }
                    },
                    child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                                BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))
                            ]
                        ),
                        child: Row(
                            children: [
                            const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(
                                loc.add_product,
                                style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                            ],
                        ),
                    ),
                )
                ],
            ),
      ),
      ),
    );
  }

  void _updateQuantity(ShoppingList list, String barcode, int newQty) {
    if (newQty < 1) return;
    final updatedQuantities = Map<String, int>.from(list.quantities);
    updatedQuantities[barcode] = newQty;

    final updatedList = list.copyWith(quantities: updatedQuantities);
    ref.read(shoppingListViewModelProvider.notifier).updateList(updatedList);
  }

  void _removeProduct(ShoppingList list, String barcode) {
    final updatedProducts = List<String>.from(list.products)..remove(barcode);
    final updatedQuantities = Map<String, int>.from(list.quantities)..remove(barcode);
    final updatedChecked = List<String>.from(list.checkedItems)..remove(barcode); // Also remove from checked

    final updatedList =
    list.copyWith(products: updatedProducts, quantities: updatedQuantities, checkedItems: updatedChecked);
    ref.read(shoppingListViewModelProvider.notifier).updateList(updatedList);
  }

  void _addProductToList(ShoppingList list, Product product) {
    if (list.products.contains(product.barcode)) {
      _updateQuantity(list, product.barcode,
          (list.quantities[product.barcode] ?? 0) + 1);
      return;
    }
    final updatedProducts = List<String>.from(list.products)..add(product.barcode);
    final updatedQuantities = Map<String, int>.from(list.quantities);
    updatedQuantities[product.barcode] = 1;

    final updatedList =
    list.copyWith(products: updatedProducts, quantities: updatedQuantities);
    ref.read(shoppingListViewModelProvider.notifier).updateList(updatedList);
  }

  void _toggleChecked(ShoppingList list, String barcode) {
      final isChecked = list.checkedItems.contains(barcode);
      final updatedChecked = List<String>.from(list.checkedItems);
      
      if (isChecked) {
          updatedChecked.remove(barcode);
      } else {
          updatedChecked.add(barcode);
      }

      final updatedList = list.copyWith(checkedItems: updatedChecked);
      ref.read(shoppingListViewModelProvider.notifier).updateList(updatedList);
  }

  // ---------------------------------------------------------------------------
  // SELECTION MODE METHODS
  // ---------------------------------------------------------------------------
  
  void _toggleSelection(String barcode) {
    setState(() {
      if (_selectedItems.contains(barcode)) {
        _selectedItems.remove(barcode);
      } else {
        _selectedItems.add(barcode);
      }
    });
  }

  void _deleteSelectedItems(ShoppingList list) {
    if (_selectedItems.isEmpty) return;
    
    final updatedProducts = List<String>.from(list.products)
      ..removeWhere((b) => _selectedItems.contains(b));
    final updatedQuantities = Map<String, int>.from(list.quantities)
      ..removeWhere((key, _) => _selectedItems.contains(key));
    final updatedChecked = List<String>.from(list.checkedItems)
      ..removeWhere((b) => _selectedItems.contains(b));
    
    for (final barcode in _selectedItems) {
      _productPrices.remove(barcode);
      _productDetails.remove(barcode);
    }

    final updatedList = list.copyWith(
      products: updatedProducts, 
      quantities: updatedQuantities, 
      checkedItems: updatedChecked
    );
    ref.read(shoppingListViewModelProvider.notifier).updateList(updatedList);
    
    setState(() => _selectedItems.clear());
  }

  Widget _buildSelectionHeader(ShoppingList list) {
    final loc = AppLocalizations.of(context)!;
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 8,
            bottom: 16,
            left: 16,
            right: 16,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            children: [
              // Cancel Button
              GestureDetector(
                onTap: () => setState(() => _selectedItems.clear()),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.close_rounded, size: 22, color: Colors.black87),
                ),
              ),
              
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  "${_selectedItems.length} sélectionné${_selectedItems.length > 1 ? 's' : ''}",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),

              GestureDetector(
                onTap: () {
                  setState(() {
                    if (_selectedItems.length == list.products.length) {
                      _selectedItems.clear();
                    } else {
                      _selectedItems.addAll(list.products);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _selectedItems.length == list.products.length 
                      ? Icons.deselect_rounded 
                      : Icons.select_all_rounded, 
                    size: 22, 
                    color: Colors.black87
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _deleteSelectedItems(list),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.error.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.white),
                      const SizedBox(width: 6),
                      Text(
                        loc.delete,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuantityBtn extends StatelessWidget {
    final IconData icon;
    final VoidCallback onTap;

    const _QuantityBtn({required this.icon, required this.onTap});

    @override
    Widget build(BuildContext context) {
        return GestureDetector(
            onTap: onTap,
            child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 1))
                    ]
                ),
                child: Icon(icon, size: 16, color: Colors.black87),
            ),
        );
    }
}


