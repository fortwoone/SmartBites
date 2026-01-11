import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../l10n/app_localizations.dart';
import '../../models/product.dart';
import '../../viewmodels/history_viewmodel.dart';
import '../../views/product/product_detail_page.dart';  

class RecentProductsWidget extends ConsumerWidget {
  const RecentProductsWidget({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final products = ref.watch(historyViewModelProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            loc.products_recently_viewed,
            style: GoogleFonts.recursive(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold
            ),
          ),
        ),
        products.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(loc.empty_cash),
              )
            : SizedBox(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: products.length,
                  itemBuilder: (context, index) => _ProductCard(product: products[index]),
                ),
              ),
      ],
    );
  }
}

// Widget pour une carte de produit
class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});
  @override
  Widget build(BuildContext context) {
      final loc = AppLocalizations.of(context)!;
      final locale = loc.localeName;
      final name = locale == 'fr' ? (product.frName ?? product.enName ?? product.name ?? 'Inconnu') : (product.enName ?? product.frName ?? product.name ?? 'Unknown');
      return GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
               builder: (_) => ProductDetailPage(
                 product: product,
               ),
            ),
          );
        },
        child: Container(
          width: MediaQuery.of(context).size.width / 3 - 16,
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 4)
            ],
          ),
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: product.imageSmallURL != null
                      ? Image.network(product.imageSmallURL!, fit: BoxFit.cover, width: double.infinity)
                      : const Icon(Icons.fastfood, size: 40),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.recursive(color: Colors.grey.shade600, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
