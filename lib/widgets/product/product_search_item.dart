
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/product.dart';
import '../../utils/grade_utils.dart';
import '../../l10n/app_localizations.dart';
import 'product_price_card.dart';

class ProductSearchItem extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  const ProductSearchItem({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 80,
                height: 80,
                color: Colors.grey[100],
                child: product.imageSmallURL != null
                    ? Image.network(
                        product.imageSmallURL!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, color: Colors.grey),
                      )
                    : const Icon(Icons.image_not_supported, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name ?? "Nom inconnu",
                    style: GoogleFonts.recursive(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (product.brands != null)
                    Text(
                      product.brands!,
                      style: GoogleFonts.recursive(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                       if (product.nutriscoreGrade != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: SizedBox(height: 20, child: nutriscoreImg(product.nutriscoreGrade!, loc)),
                          ),
                       ProductPriceCard(barcode: product.barcode, compact: true),
                    ],
                  )
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
