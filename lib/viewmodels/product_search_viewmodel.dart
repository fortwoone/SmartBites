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
  String _currentQuery = "";
  bool _isLoadingMore = false;

  ProductSearchFilters _filters = const ProductSearchFilters();

  ProductSearchFilters get filters => _filters;

  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;


  @override
  FutureOr<List<Product>> build() {
    return [];
  }
  
  // ---------------------------------------------------------------------------
  // Recherche avec filtres
  // ---------------------------------------------------------------------------
  Future<void> search(
      String query, {
        ProductSearchFilters? filters,
        required String locale, // pass locale here
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
      final repository = ref.read(openFoodFactsRepositoryProvider);
      final results = await repository.searchProducts(
        query,
        page: _page,
        filters: _filters,
        locale: locale, // pass locale to repository
      );

      _hasMore = results.length >= 20;
      return results;
    });
  }




  // ---------------------------------------------------------------------------
  // Charger plus
  // ---------------------------------------------------------------------------
  Future<void> loadMore({required String locale}) async {
    if (_isLoadingMore || !_hasMore || state.value == null) {
      return;
    }
    _isLoadingMore = true;
    ref.notifyListeners();

    try {
      final repository = ref.read(openFoodFactsRepositoryProvider);
      final newResults = await repository.searchProducts(
        _currentQuery,
        page: _page + 1,
        filters: _filters,
        locale: locale,
      );

      if (newResults.isEmpty) {
        _hasMore = false;
      } else {
        _page++;
        _hasMore = newResults.length >= 20;
        final currentList = state.value ?? [];
        state = AsyncData([...currentList, ...newResults]);
      }
    } catch (e) {
      // ignore
    } finally {
      _isLoadingMore = false;
      ref.notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Clear
  // ---------------------------------------------------------------------------
  void clear() {
    _currentQuery = "";
    _page = 1;
    _hasMore = true;
    state = const AsyncData([]);
  }
}
