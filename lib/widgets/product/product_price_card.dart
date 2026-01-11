import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/product_price.dart';
import '../../providers/app_providers.dart';
import '../../utils/color_constants.dart';

class ProductPriceCard extends ConsumerStatefulWidget {
  final String barcode;
  final bool compact;
  const ProductPriceCard({
    super.key,
    required this.barcode,
    this.compact = false,
  });
  @override
  ConsumerState<ProductPriceCard> createState() => _ProductPriceCardState();
}

class _ProductPriceCardState extends ConsumerState<ProductPriceCard> {
  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(openFoodFactsRepositoryProvider);
    
    return FutureBuilder<ProductPrice?>(
        future: repo.getPrices(widget.barcode).then((prices) => prices.isNotEmpty ? prices.first : null),
        builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(height: 50, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
            }
            if (snapshot.hasError || snapshot.data == null) {
                return const SizedBox.shrink();
            }
            
            final price = snapshot.data!;
            
            if (widget.compact) {
                return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                    child: Text("${price.price.toStringAsFixed(2)} €", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                );
            }
            
            return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                         BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
                    ]
                ),
                child: Row(
                    children: [
                        const Icon(Icons.euro, color: AppColors.primary, size: 28),
                        const SizedBox(width: 16),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Text("Prix : ", style: GoogleFonts.recursive(color: Colors.grey, fontSize: 12)),
                                Text("${price.price.toStringAsFixed(2)} €", style: GoogleFonts.recursive(fontWeight: FontWeight.bold, fontSize: 24)),
                            ],
                        ),
                        const Spacer(),
                    ],
                ),
            );
        },
    );
  }
}
