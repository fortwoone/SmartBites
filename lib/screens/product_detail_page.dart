import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:SmartBites/l10n/app_localizations.dart';
import '../models/product.dart';
import '../repositories/openfoodfacts_repository.dart';
import '../utils/grade_utils.dart';
import '../widgets/product/product_detail_header.dart';
import '../widgets/product_price_widget.dart';
import '../utils/color_constants.dart';
import '../widgets/primary_button.dart';

class ProductDetailPage extends StatelessWidget {
    final String barcode;
    final bool inAddMode;
    final OpenFoodFactsRepository repository;

    ProductDetailPage({
        super.key,
        required this.barcode,
        bool? inAddMode,
        OpenFoodFactsRepository? repository,
    }) : repository = repository ?? OpenFoodFactsRepository(), inAddMode = inAddMode ?? false;

    Widget _buildSectionTitle(String title) {
        return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
                title,
                style: GoogleFonts.recursive(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                ),
            ),
        );
    }

    Widget _buildInfoCard(BuildContext context, Product product, AppLocalizations loc) {
        return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                    ),
                ],
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Center(
                        child: Container(
                            width: 60,
                            height: 6,
                            decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(3),
                            ),
                        ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                        product.name ?? loc.unnamed_product,
                        style: GoogleFonts.recursive(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            height: 1.2,
                        ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                        product.brands ?? loc.unknown_brand,
                        style: GoogleFonts.recursive(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                        ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                                const Icon(Icons.qr_code, size: 16, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text(
                                    barcode,
                                    style: GoogleFonts.recursive(
                                        fontSize: 14,
                                        color: Colors.grey.shade700,
                                        letterSpacing: 0.5,
                                    ),
                                ),
                            ],
                        ),
                    ),
                ],
            ),
        );
    }

    Widget _buildIngredients(String? text, AppLocalizations loc) {
        return Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Row(
                        children: [
                            const Icon(Icons.restaurant_menu, color: primaryPeach, size: 20),
                            const SizedBox(width: 8),
                            Text(loc.ingredients, style: GoogleFonts.recursive(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                        text ?? loc.no_ingredient_data,
                        style: GoogleFonts.recursive(
                            fontSize: 14,
                            height: 1.6,
                            color: Colors.black87
                        ),
                    ),
                ],
            ),
        );
    }

    Widget _buildScores(Product product, AppLocalizations loc) {
        return Row(
            children: [
                Expanded(
                    child: Container(
                         margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: Column(
                            children: [
                                Text("Nutri-Score", style: GoogleFonts.recursive(fontWeight: FontWeight.bold, fontSize: 14)),
                                const SizedBox(height: 8),
                                nutriscoreImg(product.nutriscoreGrade!, loc),
                            ],
                        ),
                    ),
                ),
                Expanded(
                    child: Container(
                         margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: Column(
                            children: [
                                Text(loc.nova_group, style: GoogleFonts.recursive(fontWeight: FontWeight.bold, fontSize: 14)),
                                const SizedBox(height: 8),
                                novaImg(product.novaGroup),
                            ],
                        ),
                    ),
                ),
            ],
        );
    }

    Widget _buildNutriments(Map<String, dynamic>? nutriments, AppLocalizations loc) {
        if (nutriments == null || nutriments.isEmpty) {
            return Text(loc.no_nutritional_data, style: GoogleFonts.recursive());
        }

        final Map<String, String> selected = {
            'energy-kcal_100g': loc.energy_kcal_100g,
            'fat_100g': loc.fat_100g,
            'saturated-fat_100g': loc.saturated_fat_100g,
            'carbohydrates_100g': loc.carbohydrates_100g,
            'sugars_100g': loc.sugars_100g,
            'fiber_100g': loc.fiber_100g,
            'proteins_100g': loc.proteins_100g,
            'salt_100g': loc.salt_100g,
        };

        final Map<String, String> units = {
            'energy-kcal_100g': 'kcal',
            'fat_100g': 'g',
            'saturated-fat_100g': 'g',
            'carbohydrates_100g': 'g',
            'sugars_100g': 'g',
            'fiber_100g': 'g',
            'proteins_100g': 'g',
            'salt_100g': 'g',
        };

        String formatValue(dynamic v) {
            if (v == null) return '-';
            if (v is num) {
                if (v % 1 == 0) return v.toInt().toString();
                return v.toStringAsFixed(2);
            }
            final s = v.toString();
            final n = double.tryParse(s);
            if (n != null) {
                if (n % 1 == 0) return n.toInt().toString();
                return n.toStringAsFixed(2);
            }
            return s;
        }

        return Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                     Row(
                        children: [
                            const Icon(Icons.analytics_outlined, color: primaryPeach, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Text(
                                    loc.nutritional_intake,
                                    style: GoogleFonts.recursive(fontWeight: FontWeight.bold, fontSize: 16),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                ),
                            ),
                            const SizedBox(width: 8),
                            Text(loc.ni_units, style: GoogleFonts.recursive(fontSize: 12, color: Colors.grey)),
                        ],
                    ),
                    const Divider(height: 24),
                    ...selected.entries.map((entry) {
                        final raw = nutriments[entry.key];
                        final unit = units[entry.key];
                        final valueText = raw == null ? '-' : '${formatValue(raw)}${unit != null && raw != null ? ' $unit' : ''}';

                        return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Row(
                                children: [
                                    Expanded(
                                        child: Text(
                                            entry.value,
                                            style: GoogleFonts.recursive(color: Colors.grey.shade700, fontSize: 14),
                                        ),
                                    ),
                                    Text(
                                        valueText,
                                        style: GoogleFonts.recursive(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                                    ),
                                ],
                            ),
                        );
                    }),
                ],
            ),
        );
    }

    @override
    Widget build(BuildContext context) {
        final loc = AppLocalizations.of(context)!;
        
        return Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            body: FutureBuilder<Product?>(
                future: repository.fetchProductByBarcode(barcode),
                builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: primaryPeach));
                    }

                    if (snapshot.hasError) {
                        return Center(
                            child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                        const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                                        const SizedBox(height: 16),
                                        Text('Erreur lors du chargement.\n${snapshot.error}', 
                                            textAlign: TextAlign.center, 
                                            style: GoogleFonts.recursive(color: Colors.redAccent)
                                        ),
                                        const SizedBox(height: 16),
                                        ElevatedButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: Text("Retour", style: GoogleFonts.recursive()),
                                        )
                                    ],
                                ),
                            ),
                        );
                    }

                    final product = snapshot.data;
                    if (product == null) {
                        return Center(
                            child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text('Produit non trouvé.', style: GoogleFonts.recursive(fontSize: 18, color: Colors.grey)),
                            ),
                        );
                    }

                    return Stack(
                        children: [
                            CustomScrollView(
                                slivers: [
                                    ProductDetailHeader(
                                        imageUrl: product.imageURL,
                                        onBack: () => Navigator.pop(context),
                                    ),
                                    SliverToBoxAdapter(
                                        child: Transform.translate(
                                            offset: const Offset(0, -20),
                                            child: Column(
                                                children: [
                                                    _buildInfoCard(context, product, loc),
                                                    Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 20),
                                                        child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                                const SizedBox(height: 12),
                                                                ProductPriceWidget(
                                                                    barcode: barcode,
                                                                    repository: repository,
                                                                    compact: false,
                                                                ),
                                                                const SizedBox(height: 20),
                                                                _buildSectionTitle("Composition"),
                                                                _buildIngredients(product.ingredientsText, loc),
                                                                const SizedBox(height: 20),
                                                                _buildSectionTitle("Scores"),
                                                                _buildScores(product, loc),
                                                                const SizedBox(height: 20),
                                                                _buildSectionTitle("Nutrition"),
                                                                _buildNutriments(product.nutriments, loc),
                                                                const SizedBox(height: 100),
                                                            ],
                                                        ),
                                                    )
                                                ],
                                            ),
                                        ),
                                    ),
                                ],
                            ),
                            
                            if (inAddMode)
                                Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                        padding: const EdgeInsets.all(24),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            boxShadow: [
                                                BoxShadow(
                                                    color: Colors.black.withOpacity(0.05),
                                                    blurRadius: 20,
                                                    offset: const Offset(0, -5),
                                                )
                                            ]
                                        ),
                                        child: PrimaryButton(
                                            onPressed: (){
                                                Navigator.pop(context, product);
                                            },
                                            label: loc.add_this_product,
                                            icon: Icons.add_shopping_cart,
                                        ),
                                    ),
                                )
                        ],
                    );
                },
            ),
        );
    }
}
