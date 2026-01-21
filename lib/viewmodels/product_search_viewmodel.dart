import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../models/product_price.dart';
import '../providers/app_providers.dart';
import '../models/product_search_filters.dart';

// ==============================================================================
// VIEW MODEL : ProductSearchViewModel
// ==============================================================================
final productSearchViewModelProvider = AsyncNotifierProvider<ProductSearchViewModel, List<Product>>(() {
  return ProductSearchViewModel();
});

class ProductSearchViewModel extends AsyncNotifier<List<Product>> {
  int _page = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  String _currentQuery = "";

  ProductSearchFilters _filters = const ProductSearchFilters();

  // Cache to store prices for products (barcode -> list of prices)
  final Map<String, List<ProductPrice>> _pricesCache = {};

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
  ProductSearchFilters get filters => _filters;

  @override
  FutureOr<List<Product>> build() => [];

  // ---------------------------------------------------------------------------
  Future<void> search(
      String query, {
        ProductSearchFilters? filters,
        required String locale,
      }) async {
    if (query.trim().isEmpty) {
      state = const AsyncData([]);
      return;
    }

    _currentQuery = query;
    _filters = filters ?? _filters;
    _page = 1;
    _hasMore = true;

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repo = ref.read(openFoodFactsRepositoryProvider);
      final results = await repo.searchProducts(
        query,
        page: _page,
        filters: _filters,
        locale: locale,
      );
      _hasMore = results.length >= 20;

      // Fetch prices for sorting if needed
      if (_filters.sortBy != null && _filters.sortBy!.startsWith('price_')) {
        await _fetchPricesForProducts(results);
        return _applySorting(results, _filters.sortBy);
      }

      return results;
    });
  }

  // ---------------------------------------------------------------------------
  Future<void> loadMore({required String locale}) async {
    if (_isLoadingMore || !_hasMore || state.value == null) return;

    _isLoadingMore = true;
    ref.notifyListeners();

    try {
      final repo = ref.read(openFoodFactsRepositoryProvider);
      final newResults = await repo.searchProducts(
        _currentQuery,
        page: _page + 1,
        filters: _filters,
        locale: locale,
      );

      if (newResults.isEmpty) {
        _hasMore = false;
      } else {
        _page++;

        // Fetch prices for new products if sorting by price
        if (_filters.sortBy != null && _filters.sortBy!.startsWith('price_')) {
          await _fetchPricesForProducts(newResults);
          // Combine results and re-sort the entire list
          final combined = [...state.value!, ...newResults];
          state = AsyncData(_applySorting(combined, _filters.sortBy));
        } else {
          state = AsyncData([...state.value!, ...newResults]);
        }
      }
    } finally {
      _isLoadingMore = false;
      ref.notifyListeners();
    }
  }

  void clear() {
    _currentQuery = "";
    _page = 1;
    _hasMore = true;
    _filters = const ProductSearchFilters();
    _pricesCache.clear();
    state = const AsyncData([]);
  }

  // ---------------------------------------------------------------------------
  // PRICE FETCHING
  // ---------------------------------------------------------------------------

  /// Fetch prices for a list of products and store in cache
  Future<void> _fetchPricesForProducts(List<Product> products) async {
    final priceRepo = ref.read(priceRepositoryProvider);

    for (final product in products) {
      // Skip if already in cache
      if (_pricesCache.containsKey(product.barcode)) {
        continue;
      }

      try {
        // Fetch prices for this product
        final prices = await priceRepo.getPrices(product.barcode);
        _pricesCache[product.barcode] = prices;
      } catch (e) {
        // If fetching fails, store empty list to avoid retrying
        _pricesCache[product.barcode] = [];
      }
    }
  }

  // ---------------------------------------------------------------------------
  // SORTING
  // ---------------------------------------------------------------------------

  List<Product> _applySorting(List<Product> products, String? sortBy) {
    if (sortBy == null || products.isEmpty) return products;

    final sorted = List<Product>.from(products);

    switch (sortBy) {
      case 'price_asc':
        sorted.sort((a, b) {
          final priceA = _getLatestPrice(a.barcode);
          final priceB = _getLatestPrice(b.barcode);
          return priceA.compareTo(priceB);
        });
        break;
      case 'price_desc':
        sorted.sort((a, b) {
          final priceA = _getLatestPrice(a.barcode);
          final priceB = _getLatestPrice(b.barcode);
          return priceB.compareTo(priceA);
        });
        break;
    }

    return sorted;
  }

  /// Get the most recent price from cache for a product barcode
  /// Returns infinity for products without prices (they'll be sorted to the end)
  double _getLatestPrice(String barcode) {
    final prices = _pricesCache[barcode];

    if (prices == null || prices.isEmpty) {
      return double.infinity;
    }

    // Get the most recent price
    final sortedPrices = List<ProductPrice>.from(prices)
      ..sort((a, b) => b.date.compareTo(a.date));

    return sortedPrices.first.price;
  }

  /// Get prices for a specific product (for UI usage)
  List<ProductPrice>? getPricesForProduct(String barcode) {
    return _pricesCache[barcode];
  }

  // ---------------------------------------------------------------------------
  // FILTER HELPERS (UI SAFE)
  // ---------------------------------------------------------------------------

  List<String> extractBrands(List<Product> products) {
    return products
        .map((p) => p.brands)
        .whereType<String>()
        .expand((b) => b.split(','))
        .map((b) => b.trim())
        .where((b) => b.isNotEmpty)
        .toSet()
        .toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  }

  List<String> extractCategories(List<Product> products) {
    return products
        .expand((p) => p.categories)
        .where((c) => c.isNotEmpty)
        .map((c) => c.replaceAll('-', ' '))
        .toSet()
        .toList()
      ..sort();
  }
}