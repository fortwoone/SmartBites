import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';
import '../repositories/openfoodfacts_repository.dart';
import '../screens/product_detail_page.dart';
import '../models/product.dart';
import '../utils/color_constants.dart';
import '../widgets/recipe/recipe_background.dart';
import '../widgets/shopping_list/product_search_item.dart';

class ProductSearchPage extends StatefulWidget {
  final OpenFoodFactsRepository repository;
  final bool inAddMode;

  ProductSearchPage({super.key, OpenFoodFactsRepository? repository, bool? inAddMode})
      : repository = repository ?? OpenFoodFactsRepository(),
        inAddMode = inAddMode ?? false;

  @override
  State<ProductSearchPage> createState() => _ProductSearchPageState();
}

class _ProductSearchPageState extends State<ProductSearchPage> {
  final TextEditingController _controller = TextEditingController();
  late final loc = AppLocalizations.of(context)!;

  List<Product> _results = [];
  bool _loading = false;
  String? _error;

  Future<void> _search() async {
    final query = _controller.text.trim();
    if (query.isEmpty) {
      setState(() => _error = loc.enter_product_error);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _results = [];
    });

    try {
      final results = await widget.repository.fetchProductsByName(query);
      final barcodes = results.map((p) => p.barcode).toList();
      await widget.repository.preloadPrices(barcodes);

      setState(() => _results = results);
    } catch (e) {
      setState(() => _error = loc.error_search);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const RecipeBackground(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black87),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        loc.search_product,
                        style: GoogleFonts.recursive(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            textInputAction: TextInputAction.search,
                            style: GoogleFonts.recursive(fontSize: 16),
                            decoration: InputDecoration(
                              hintText: loc.hint_product_example,
                              hintStyle: GoogleFonts.recursive(
                                color: Colors.grey[400],
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            ),
                            onSubmitted: (_) => _search(),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: primaryPeach,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.search, color: Colors.white),
                            onPressed: _search,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_loading)
                  const Expanded(child: Center(child: CircularProgressIndicator(color: primaryPeach)))
                else if (_error != null)
                  Expanded(
                      child: Center(
                          child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.recursive(color: Colors.redAccent, fontSize: 16),
                    ),
                  )))
                else if (_results.isEmpty)
                   Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.withOpacity(0.3)),
                            const SizedBox(height: 16),
                             Text(
                              loc.no_results_now,
                              style: GoogleFonts.recursive(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                else
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final p = _results[index];
                        return ProductSearchItem(
                          product: p,
                          repository: widget.repository,
                          onTap: () async {
                            final code = p.barcode;
                            if (code.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(loc.no_barcode_available)),
                              );
                              return;
                            }
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductDetailPage(
                                  barcode: code,
                                  repository: widget.repository,
                                  inAddMode: widget.inAddMode,
                                ),
                              ),
                            );
                            if (!context.mounted) return;
                            if (widget.inAddMode && result != null) {
                              Navigator.pop(context, result);
                            }
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
