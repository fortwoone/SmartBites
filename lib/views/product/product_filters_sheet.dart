import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/product_search_filters.dart';

class ProductFiltersSheet extends StatefulWidget {
  final ProductSearchFilters initialFilters;
  final List<String> availableBrands;
  final List<String> availableCategories;

  const ProductFiltersSheet({
    super.key,
    required this.initialFilters,
    required this.availableBrands,
    required this.availableCategories,
  });

  @override
  State<ProductFiltersSheet> createState() => _ProductFiltersSheetState();
}

class _ProductFiltersSheetState extends State<ProductFiltersSheet> {
  late String? brand;
  late String? category;
  late String? nutriScore;

  @override
  void initState() {
    super.initState();
    brand = widget.initialFilters.brand;
    category = widget.initialFilters.category;
    nutriScore = widget.initialFilters.nutriScore;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Padding(
      padding: MediaQuery.of(context).viewInsets.add(
        const EdgeInsets.all(16),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              loc.filters, // localized title
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: brand,
              decoration: InputDecoration(labelText: loc.brand),
              items: [
                DropdownMenuItem(value: null, child: Text(loc.any)),
                ...widget.availableBrands.toSet().toList()  // make unique
                    .map((b) => DropdownMenuItem(value: b, child: Text(b)))
              ],
              onChanged: (v) => setState(() => brand = v),
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: category,
              decoration: InputDecoration(labelText: loc.category),
              items: [null, ...widget.availableCategories].map(
                    (c) => DropdownMenuItem(
                  value: c,
                  child: Text(c ?? loc.any),
                ),
              ).toList(),
              onChanged: (v) => setState(() => category = v),
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: nutriScore,
              decoration: InputDecoration(labelText: "Nutriscore"),
              items: [null, 'A', 'B', 'C', 'D', 'E'].map(
                    (e) => DropdownMenuItem(
                  value: e?.toLowerCase(),
                  child: Text(e ?? loc.any),
                ),
              ).toList(),
              onChanged: (v) => setState(() => nutriScore = v),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  ProductSearchFilters(
                    brand: brand,
                    category: category,
                    nutriScore: nutriScore,
                  ),
                );
              },
              child: Text(loc.apply),
            ),
          ],
        ),
      ),
    );
  }
}
