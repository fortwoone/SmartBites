
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:SmartBites/screens/product_detail_screen.dart';
import 'package:SmartBites/repositories/openfoodfacts_repository.dart';

import '../l10n/app_localizations.dart';

class RecentProductsWidget extends StatefulWidget {
  const RecentProductsWidget({super.key});

  @override
  State<RecentProductsWidget> createState() => _RecentProductsWidgetState();
}

class _RecentProductsWidgetState extends State<RecentProductsWidget> {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchRecentProducts() async {
    // Récupère 3 produits ajoutés à la table cached_products
    final response = await supabase
        .from('cached_products')
        .select()
        .limit(3);

    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            loc.products_recently_viewed,
            style: GoogleFonts.recursive(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchRecentProducts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            final products = snapshot.data ?? [];

            if (products.isEmpty) {
              return Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(loc.empty_cash),
              );
            }

            final locale = Localizations.localeOf(context).languageCode;

            return SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final item = products[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ProductDetailPage(
                              barcode: item['barcode'],
                              repository: OpenFoodFactsRepository()
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
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 4)
                        ],
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              child: item['img_small_url'] != null
                                  ? Image.network(item['img_small_url'], fit: BoxFit.cover, width: double.infinity)
                                  : const Icon(Icons.fastfood, size: 40),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              locale == 'fr'
                              ? (item['fr_name'] ?? item['en_name'] ?? 'Inconnu')
                                  : (item['en_name'] ?? item['fr_name'] ?? 'Unknown'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.recursive(color: Colors.grey.shade600, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}