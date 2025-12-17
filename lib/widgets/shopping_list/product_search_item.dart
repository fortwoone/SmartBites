import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/product.dart';
import '../../utils/color_constants.dart';
import '../../repositories/openfoodfacts_repository.dart';
import '../product_price_widget.dart';

class ProductSearchItem extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final OpenFoodFactsRepository repository;

  const ProductSearchItem({
    super.key,
    required this.product,
    required this.onTap,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: primaryPeach.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: product.imageURL != null && product.imageURL!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            product.imageURL!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image, color: Colors.grey),
                          ),
                        )
                      : const Icon(Icons.shopping_bag_outlined, color: primaryPeach),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name ?? product.brands ?? 'Produit inconnu',
                        style: GoogleFonts.recursive(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (product.brands != null && product.brands!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          product.brands!,
                          style: GoogleFonts.recursive(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 6),
                      ProductPriceWidget(
                        barcode: product.barcode,
                        repository: repository,
                        compact: true,
                      ),
                    ],
                  ),
                ),
                
                const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
