import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';
import '../repositories/openfoodfacts_repository.dart';
import '../screens/product_detail_page.dart';
import '../models/product.dart';
import '../utils/color_constants.dart';
import '../widgets/recipe/recipe_background.dart';
import '../widgets/shopping_list/product_search_item.dart';
import '../widgets/product_skeleton.dart';
import '../widgets/error_retry_widget.dart';
import '../utils/local_cache_service.dart';

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
  bool _loadingMore = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;

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
      _currentPage = 1;
      _hasMore = true;
    });

    try {
      final results = await widget.repository.fetchProductsByName(query, page: 1);
      final barcodes = results.map((p) => p.barcode).toList();
      await widget.repository.preloadPrices(barcodes);

      _hasMore = results.length >= 50;
      setState(() => _results = results);
    } catch (e) {
      setState(() => _error = 'error');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore) return;

    setState(() => _loadingMore = true);

    try {
      final nextPage = _currentPage + 1;
      final results = await widget.repository.fetchProductsByName(_controller.text.trim(), page: nextPage);
      
      final barcodes = results.map((p) => p.barcode).toList();
      await widget.repository.preloadPrices(barcodes);

      _hasMore = results.length >= 50;
      _currentPage = nextPage;
      setState(() => _results.addAll(results));
    } catch (_) {
    } finally {
      setState(() => _loadingMore = false);
    }
  }

  Future<void> _refresh() async {
    widget.repository.clearCache();
    await _search();
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
                              color: Colors.black.withValues(alpha: 0.05),
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
                          color: Colors.black.withValues(alpha: 0.05),
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
                Expanded(child: _buildContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return const ProductSkeletonList();
    }
    
    if (_error != null) {
      return SearchErrorWidget(onRetry: _search);
    }
    
    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.withValues(alpha: 0.3)),
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
      );
    }

    return RefreshIndicator(
      color: primaryPeach,
      onRefresh: _refresh,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        itemCount: _results.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _results.length) {
            return _buildLoadMoreButton();
          }
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
              final cacheService = await LocalCacheService.getInstance();
              await cacheService.saveRecentProduct(p);
              if (!context.mounted) return;
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
    );
  }

  Widget _buildLoadMoreButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: _loadingMore
            ? const CircularProgressIndicator(color: primaryPeach)
            : TextButton.icon(
                onPressed: _loadMore,
                icon: const Icon(Icons.add_circle_outline, color: primaryPeach),
                label: Text(
                  'Charger plus',
                  style: TextStyle(color: primaryPeach, fontWeight: FontWeight.w600),
                ),
              ),
      ),
    );
  }
}
