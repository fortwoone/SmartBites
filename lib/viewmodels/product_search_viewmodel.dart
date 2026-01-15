import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
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
        state = AsyncData([...state.value!, ...newResults]);
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
    state = const AsyncData([]);
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
