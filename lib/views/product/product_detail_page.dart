import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../l10n/app_localizations.dart';
import '../../models/product.dart';
import '../../utils/grade_utils.dart';
import '../../utils/color_constants.dart';
import '../../widgets/product/product_detail_header.dart';
import '../../widgets/product/product_price_card.dart';
import '../../viewmodels/shopping_list_viewmodel.dart';

class ProductDetailPage extends ConsumerWidget {
  final Product product;
  const ProductDetailPage({super.key, required this.product});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
       backgroundColor: const Color(0xFFF8F9FA),
       body: Stack(
         children: [
           CustomScrollView(
             slivers: [
               ProductDetailHeader(imageUrl: product.imageURL, onBack: () => Navigator.pop(context)),
               SliverToBoxAdapter(
                 child: Transform.translate(
                   offset: const Offset(0, -20),
                   child: Column(
                     children: [
                       _buildTitleCard(context, product, loc),
                       Padding(
                         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             ProductPriceCard(barcode: product.barcode),
                             const SizedBox(height: 24),
                             _buildSectionTitle(loc.composition),
                             _buildIngredients(product.ingredientsText, loc),
                             const SizedBox(height: 24),
                             _buildSectionTitle(loc.scores),
                             _buildScores(product, loc),
                             const SizedBox(height: 24),
                             _buildSectionTitle(loc.nutrition),
                             _buildNutriments(product.nutriments, loc),
                             const SizedBox(height: 100),
                           ],
                         ),
                       )
                     ],
                   ),
                 ),
               )
             ],
           ),
           Positioned(
             bottom: 24,
             left: 20,
             right: 20,
             child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                   backgroundColor: AppColors.primary,
                   padding: const EdgeInsets.all(16),
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                   elevation: 4
                ),
                onPressed: () => _addToShoppingList(context, ref, loc),
                icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
                label: Text(loc.add_to_grocery_list, style: GoogleFonts.recursive(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
             ),
           )
         ],
       ),
    );
  }

  // Afficher le modal pour ajouter à une liste de courses
  void _addToShoppingList(BuildContext context, WidgetRef ref, AppLocalizations loc) {
      final lists = ref.read(shoppingListViewModelProvider).value ?? [];
      showModalBottomSheet(
         context: context,
         shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
         builder: (context) {
             return Container(
                 padding: const EdgeInsets.all(20),
                 child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Text("Ajouter à une liste", style: GoogleFonts.recursive(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        if (lists.isEmpty)
                           Center(child: TextButton(onPressed: ()=>Navigator.pop(context), child: const Text("Aucune liste, créez-en une d'abord"))),
                        ...lists.map((list) => ListTile(
                            title: Text(list.name),
                            trailing: const Icon(Icons.add),
                            onTap: () {
                                _addProductToList(ref, list.id!, list, product);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.success)));
                            },
                        )),
                    ],
                 ),
             );
         }
      );
  }

  // Ajouter le produit à une liste de courses
  void _addProductToList(WidgetRef ref, int listId, dynamic oldList, Product product) {
      final currentList = oldList;
      final updatedProducts = List<String>.from(currentList.products)..add(product.barcode);
      final updatedQuantities = Map<String, int>.from(currentList.quantities);
      updatedQuantities[product.barcode] = (updatedQuantities[product.barcode] ?? 0) + 1;
      final updatedList = currentList.copyWith(products: updatedProducts, quantities: updatedQuantities);
      ref.read(shoppingListViewModelProvider.notifier).updateList(updatedList);
  }

  // Widget pour la carte de titre du produit
  Widget _buildTitleCard(BuildContext context, Product product, AppLocalizations loc) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
           color: Colors.white,
           borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0,-5))]
        ),
        child: Column(
           children: [
               Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
               const SizedBox(height: 20),
               Text(product.name ?? loc.unnamed_product, textAlign: TextAlign.center, style: GoogleFonts.recursive(fontSize: 24, fontWeight: FontWeight.bold)),
               const SizedBox(height: 8),
               Text(product.brands ?? loc.unknown_brand, style: GoogleFonts.recursive(color: Colors.grey, fontSize: 16)),
               const SizedBox(height: 16),
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                    child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                            const Icon(Icons.qr_code, size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(product.barcode, style: GoogleFonts.recursive(color: Colors.grey[700])),
                        ],
                    ),
                ),
           ],
        ),
      );
  }

  // Widget pour les titres de section
  Widget _buildSectionTitle(String title) {
     return Text(title, style: GoogleFonts.recursive(fontSize: 20, fontWeight: FontWeight.bold));
  }

  // Widget pour les ingrédients
  Widget _buildIngredients(String? text, AppLocalizations loc) {
      return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[200]!)),
          child: Text(text ?? loc.no_ingredient_data, style: GoogleFonts.recursive(height: 1.5)),
      );
  }

  // Widget pour les scores Nutri-Score et Nova
  Widget _buildScores(Product product, AppLocalizations loc) {
      return Row(
          children: [
              Expanded(
                 child: Container(
                     padding: const EdgeInsets.all(12),
                     decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[200]!)),
                     child: Column(children: [
                         Text(loc.nutri_score, style: GoogleFonts.recursive(fontWeight: FontWeight.bold)),
                         const SizedBox(height: 8),
                         nutriscoreImg(product.nutriscoreGrade ?? 'unknown', loc)
                     ]),
                 ),
              ),
              const SizedBox(width: 16),
              Expanded(
                 child: Container(
                     padding: const EdgeInsets.all(12),
                     decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[200]!)),
                     child: Column(children: [
                         Text(loc.nova_group, style: GoogleFonts.recursive(fontWeight: FontWeight.bold)),
                         const SizedBox(height: 8),
                         novaImg(product.novaGroup)
                     ]),
                 ),
              ),
          ],
      );
  }

  // Widget pour les informations nutritionnelles
  Widget _buildNutriments(Map<String, dynamic>? nutriments, AppLocalizations loc) {
     if (nutriments == null || nutriments.isEmpty) {
       return Text(loc.no_nutritional_data);
     }
     return Container(
         padding: const EdgeInsets.all(16),
         decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[200]!)),
         child: Column(
             children: [
                  _nutrimentRow(loc.energy_kcal_100g, nutriments['energy-kcal_100g'], 'kcal'),
                  _nutrimentRow(loc.fat_100g, nutriments['fat_100g'], 'g'),
                  _nutrimentRow(loc.sugars_100g, nutriments['sugars_100g'], 'g'),
                  _nutrimentRow(loc.salt_100g, nutriments['salt_100g'], 'g'),
             ],
         ),
     );
  }

  // Widget pour une ligne de nutriment
  Widget _nutrimentRow(String label, dynamic value, String unit) {
      final valStr = value != null ? value.toString() : "-";
      return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                  Text(label, style: GoogleFonts.recursive(color: Colors.grey[700])),
                  Text("$valStr $unit", style: GoogleFonts.recursive(fontWeight: FontWeight.bold)),
              ],
          ),
      );
  }
}
