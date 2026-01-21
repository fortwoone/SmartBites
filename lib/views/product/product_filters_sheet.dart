import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../l10n/app_localizations.dart';
import '../../models/product_search_filters.dart';
import '../../utils/color_constants.dart';

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
  String? brand;
  String? category;
  String? nutriScore;
  String? sortBy;

  @override
  void initState() {
    super.initState();

    brand = widget.availableBrands.contains(widget.initialFilters.brand)
        ? widget.initialFilters.brand
        : null;

    category = widget.availableCategories.contains(widget.initialFilters.category)
        ? widget.initialFilters.category
        : null;

    nutriScore = widget.initialFilters.nutriScore;
    sortBy = widget.initialFilters.sortBy; // Initialize sortBy
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Text(
                loc.filters,
                style: GoogleFonts.recursive(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 24),

            _buildDropdown(
              label: loc.brand,
              value: brand,
              items: widget.availableBrands,
              anyLabel: loc.any,
              onChanged: (v) => setState(() => brand = v),
            ),

            const SizedBox(height: 16),

            _buildDropdown(
              label: loc.category,
              value: category,
              items: widget.availableCategories,
              anyLabel: loc.any,
              onChanged: (v) => setState(() => category = v),
            ),

            const SizedBox(height: 16),

            _buildDropdown(
              label: "NutriScore",
              value: nutriScore,
              items: const ['a', 'b', 'c', 'd', 'e'],
              displayUppercase: true,
              anyLabel: loc.any,
              onChanged: (v) => setState(() => nutriScore = v),
            ),

            const SizedBox(height: 16),

            // Sort by price dropdown
            _buildDropdown(
              label: loc.price_order,
              value: sortBy,
              items: const ['price_asc', 'price_desc'],
              anyLabel: loc.any,
              displayLabels: {
                'price_asc': loc.lowest_to_highest,
                'price_desc': loc.highest_to_lowest,
              },
              onChanged: (v) => setState(() => sortBy = v),
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(
                    context,
                    ProductSearchFilters(
                      brand: brand,
                      category: category,
                      nutriScore: nutriScore,
                      sortBy: sortBy, // Include sortBy in the result
                    ),
                  );
                },
                child: Text(
                  loc.apply,
                  style: GoogleFonts.recursive(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required String anyLabel,
    required ValueChanged<String?> onChanged,
    bool displayUppercase = false,
    Map<String, String>? displayLabels, // Add optional display labels
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      menuMaxHeight: 280,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.recursive(),
        filled: true,
        fillColor: Colors.grey.withAlpha(15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      items: [
        DropdownMenuItem(
          value: null,
          child: Text(
            anyLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.recursive(),
          ),
        ),
        ...items.map(
              (e) => DropdownMenuItem(
            value: e,
            child: Text(
              displayLabels?[e] ?? (displayUppercase ? e.toUpperCase() : e),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.recursive(),
            ),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }
}