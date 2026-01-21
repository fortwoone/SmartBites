import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../l10n/app_localizations.dart';
import '../../models/product.dart';
import '../../viewmodels/history_viewmodel.dart';
import '../../views/product/product_detail_page.dart';  
import 'dashboard_section_header.dart';

class RecentProductsWidget extends ConsumerWidget {
  const RecentProductsWidget({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final products = ref.watch(historyViewModelProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashboardSectionHeader(
           title: loc.products_recently_viewed,
        ),
        products.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(loc.empty_cash, style: GoogleFonts.inter(color: Colors.grey)),
              )
            : SizedBox(
                height: 160,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: products.length,
                  separatorBuilder: (_,__) => const SizedBox(width: 12),
                  itemBuilder: (context, index) => _ProductCard(product: products[index]),
                ),
              ),
      ],
    );
  }
}

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
          width: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04), 
                blurRadius: 10,
                offset: const Offset(0, 4)
              )
            ],
            border: Border.all(color: Colors.grey.withOpacity(0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                     color: const Color(0xFFF8F8F8),
                     borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: product.imageSmallURL != null
                      ? Image.network(product.imageSmallURL!, fit: BoxFit.contain)
                      : const Icon(Icons.fastfood, size: 30, color: Colors.grey),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Colors.black87
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
  }
}
