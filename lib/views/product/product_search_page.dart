import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/color_constants.dart';
import '../../viewmodels/product_search_viewmodel.dart';
import '../../viewmodels/history_viewmodel.dart';
import '../../widgets/product/product_search_item.dart';
import 'product_detail_page.dart';
import '../../models/product_search_filters.dart';
import '../../views/product/product_filters_sheet.dart';
import '../../models/product.dart';

class ProductSearchPage extends ConsumerStatefulWidget {
  final bool inAddMode;
  const ProductSearchPage({super.key, this.inAddMode = false});

  @override
  ConsumerState<ProductSearchPage> createState() => _ProductSearchPageState();
}

class _ProductSearchPageState extends ConsumerState<ProductSearchPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  ProductSearchFilters _filters = const ProductSearchFilters();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {

    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      ref.read(productSearchViewModelProvider.notifier).loadMore(locale: locale);
    }
  }
  String get locale => Localizations.localeOf(context).languageCode;


  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _performSearch() {

    ref.read(productSearchViewModelProvider.notifier).search(
      _searchCtrl.text,
      filters: _filters,
      locale:locale,
    );
  }

  Future<void> _openFilters(List<Product> currentProducts) async {
    final locale = Localizations.localeOf(context).languageCode;

    // Extract unique brands (case-insensitive)
    final allBrands = currentProducts
        .map((p) => p.brands)
        .whereType<String>()
        .expand((s) => s.split(','))
        .map((s) => s.trim())
        .map((s) => s.trim())
        .toSet()
        .toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));



    // Extract unique categories for the current locale only
    final allCategories = currentProducts
        .expand((p) => p.categories)  // flatten all categories from products
        .map((c) {
      // Categories are like "en:breakfasts" or "fr:petits-dejeuners"
      if (c.contains(':')) {
        final parts = c.split(':');
        // Keep only if the prefix matches the locale
        return parts[0] == locale ? parts[1] : null;
      }
      return null; // ignore categories without a locale prefix
    })
        .whereType<String>()  // remove nulls
        .toSet()              // remove duplicates
        .toList()
      ..sort();               // sort alphabetically


    final result = await showModalBottomSheet<ProductSearchFilters>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ProductFiltersSheet(
        initialFilters: _filters,
        availableBrands: allBrands,
        availableCategories: allCategories,
      ),
    );


    if (result != null) {
      setState(() => _filters = result);

      if (_searchCtrl.text.isNotEmpty) {
        ref.read(productSearchViewModelProvider.notifier)
            .search(_searchCtrl.text, filters: _filters, locale: locale);
      }
    }
  }




  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final searchAsync = ref.watch(productSearchViewModelProvider);
    final notifier = ref.read(productSearchViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          loc.search_product,
          style: GoogleFonts.recursive(
              fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchCtrl,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: loc.hint_product_example,
                prefixIcon:
                const Icon(Icons.search, color: AppColors.primary),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.filter_alt_outlined,
                        color: _filters.hasApiFilters ? AppColors.primary : Colors.grey,
                      ),
                      onPressed: () {
                        // Get all products currently loaded (all pages)
                        final products = searchAsync.maybeWhen(
                          data: (p) => List<Product>.from(p),
                          orElse: () => <Product>[],
                        );
                        _openFilters(products);
                      },
                      tooltip: "Filters",
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchCtrl.clear();
                        notifier.clear();
                        setState(() => _filters = const ProductSearchFilters());
                      },
                    ),
                  ],
                ),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none),
              ),
              onSubmitted: (_) => _performSearch(),
            ),
          ),
        ),
      ),
      body: searchAsync.when(
        data: (products) {
          if (products.isEmpty && _searchCtrl.text.isNotEmpty) {
            // Reset filters if nothing is found
            if (_filters.hasApiFilters) {
              setState(() => _filters = const ProductSearchFilters());
            }
            return Center(
              child: Text(
                loc.no_results_now, // "No products found"
                style: GoogleFonts.recursive(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            );
          }

          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, size: 80, color: Colors.grey[300]),
                  Text(loc.search_product,
                      style: GoogleFonts.recursive(color: Colors.grey))
                ],
              ),
            );
          }

          // Normal list view for products
          return ListView.builder(
            controller: _scrollCtrl,
            padding: const EdgeInsets.all(16),
            itemCount: products.length + (notifier.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == products.length) {
                return notifier.isLoadingMore
                    ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                )
                    : const SizedBox(height: 50);
              }
              final product = products[index];
              return ProductSearchItem(
                product: product,
                onTap: () {
                  // Save to history
                  ref.read(historyViewModelProvider.notifier).addToHistory(product);

                  if (widget.inAddMode) {
                    Navigator.pop(context, product);
                  } else {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ProductDetailPage(product: product)));
                  }
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text("${loc.error}: $e")),
      ),
    );
  }
}
