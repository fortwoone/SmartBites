// A page that displays detailed information about a product
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/product.dart';
import '../repositories/openfoodfacts_repository.dart';
import "package:food/widgets/grade_utils.dart";

class ProductDetailPage extends StatelessWidget {
    final String barcode;
    final OpenFoodFactsRepository repository;

    // Constructor with required barcode and optional repository
    ProductDetailPage({
      super.key,
      required this.barcode,
      OpenFoodFactsRepository? repository,
    }) : repository = repository ?? OpenFoodFactsRepository();

    // Widget to display product image and error handling
    Widget _buildImage(String? url) {
      final borderRadius = BorderRadius.circular(12);
      if (url == null || url.isEmpty) {
        return ClipRRect(
          borderRadius: borderRadius,
          child: Container(
            height: 220,
            color: Colors.grey.shade200,
            child: const Center(
              child: Icon(Icons.photo, size: 64, color: Colors.grey),
            ),
          ),
        );
      }

      return ClipRRect(
        borderRadius: borderRadius,
        child: Container(
          color: Colors.grey.shade100,
          padding: const EdgeInsets.all(8), // keep space from rounded edges
          child: AspectRatio(
            aspectRatio: 16 / 9, // fixed display ratio to avoid heavy cropping
            child: Image.network(
              url,
              fit: BoxFit.contain, // avoid cropping, respect whole image
              alignment: Alignment.center,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  color: Colors.grey.shade100,
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
            ),
          ),
        ),
      );
    }

    // Card displaying basic product info: name, brand, barcode
    Widget _buildInfoCard(BuildContext context, Product product, AppLocalizations loc) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 12),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(product.name ?? loc.unnamed_product,
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 6),
            Text(product.brands ?? loc.unknown_brand,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700])),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.qr_code, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Text(barcode, style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ]),
          ]),
        ),
      );
    }

    // Widget to display ingredients text
    Widget _buildIngredients(String? text, AppLocalizations loc) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(loc.ingredients, style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(text ?? loc.no_ingredient_data, style: const TextStyle(height: 1.25)),
      ]);
    }

    // Widget to display nutriments in a structured format
    Widget _buildNutriments(Map<String, dynamic>? nutriments, AppLocalizations loc) {
        if (nutriments == null || nutriments.isEmpty) {
            return Text(loc.no_nutritional_data);
        }

        // Define which nutriments to show and their labels (order matters)
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

        // Units to append for the selected nutriments
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
              // show integer if whole number, otherwise show as double with max 2 decimals
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

        // Header row: shows that values are "per 100g / 100ml"
        final header = Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
                children: [
                    Text(
                        loc.nutritional_intake,
                        style: TextStyle(fontWeight: FontWeight.bold)
                    ),
                    const Expanded(child: SizedBox()), // Spacer
                    Text(
                        loc.ni_units,
                        style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                ],
            ),
        );

        final rows = selected.entries.map((entry) {
            final raw = nutriments[entry.key];
            final unit = units[entry.key];
            final valueText = raw == null ? '-' : '${formatValue(raw)}${unit != null && raw != null ? ' $unit' : ''}';

            return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                    children: [
                        Expanded(
                            child: Text(
                                entry.value,
                                style: const TextStyle(color: Colors.black87),
                                overflow: TextOverflow.ellipsis,
                            ),
                        ),
                        const SizedBox(width: 8),
                        Text(valueText, style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                ),
            );
        }).toList();

        return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
                header,
                ...rows,
            ],
        );
    }

    @override
    Widget build(BuildContext context) {
        final loc = AppLocalizations.of(context)!;
        return Scaffold(
            appBar: AppBar(
                title: Text(loc.product_details),
            ),
            body: FutureBuilder<Product?>(
                future: repository.fetchProductByBarcode(barcode),
                builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                        return Center(
                            child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text('Error loading product.\n${snapshot.error}', textAlign: TextAlign.center),
                            ),
                        );
                    }

                    final product = snapshot.data;
                    if (product == null) {
                        return const Center(
                            child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text('Product not found.'),
                            ),
                        );
                    }

                    return ListView(
                        padding: const EdgeInsets.all(16.0),
                        children: [
                            _buildImage(product.imageURL),
                            _buildInfoCard(context, product, loc),
                            const SizedBox(height: 6),
                            _buildIngredients(product.ingredientsText, loc),
                            const SizedBox(height: 12),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children:[
                                    Text("Nutri-Score", style: const TextStyle(fontWeight: FontWeight.w600)),
                                    nutriscoreImg(product.nutriscoreGrade!, loc)
                                ]
                            ),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children:[
                                  Text(loc.nova_group, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  novaImg(product.novaGroup)
                                ]
                            ),
                            const SizedBox(height: 12),
                            _buildNutriments(product.nutriments, loc),
                            const SizedBox(height: 20),
                        ],
                    );
                },
            ),
        );
    }
}
