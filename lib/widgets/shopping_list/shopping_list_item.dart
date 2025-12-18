import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../db_objects/cached_product.dart';
import '../../utils/color_constants.dart';
import '../../widgets/product_price_widget.dart';

class ShoppingListItem extends StatelessWidget {
  final String barcode;
  final CachedProduct cached;
  final int quantity;
  final VoidCallback onTap;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onDelete;
  final bool isFrench;

  const ShoppingListItem({
    super.key,
    required this.barcode,
    required this.cached,
    required this.quantity,
    required this.onTap,
    required this.onIncrement,
    required this.onDecrement,
    required this.onDelete,
    required this.isFrench,
  });

  String get _displayName {
    if (isFrench) {
      if (cached.fr_name.isNotEmpty) return cached.fr_name;
      if (cached.en_name.isNotEmpty) return cached.en_name;
      return "Produit sans nom";
    } else {
      if (cached.en_name.isNotEmpty) return cached.en_name;
      if (cached.fr_name.isNotEmpty) return cached.fr_name;
      return "Unnamed product";
    }
  }

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
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: cached.img_small_url.trim().isEmpty
                      ? const Icon(Icons.shopping_bag, color: primaryPeach)
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            cached.img_small_url,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image, color: Colors.grey),
                          ),
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _displayName,
                        style: GoogleFonts.recursive(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (cached.brands.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          cached.brands,
                          style: GoogleFonts.recursive(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      ProductPriceWidget(barcode: barcode, compact: true),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildQuantityBtn(Icons.remove, onDecrement, color: Colors.grey),
                         Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                           child: Text(
                             '$quantity',
                             style: GoogleFonts.recursive(
                               fontSize: 16,
                               fontWeight: FontWeight.bold,
                             ),
                           ),
                         ),
                        _buildQuantityBtn(Icons.add, onIncrement, color: primaryPeach),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuantityBtn(IconData icon, VoidCallback onPressed, {Color color = Colors.black}) {
      return InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: color),
          ),
      );
  }
}
