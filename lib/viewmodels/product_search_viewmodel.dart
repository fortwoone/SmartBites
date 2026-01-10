import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../providers/app_providers.dart';

// ==============================================================================
// VIEW MODEL : ProductSearchViewModel
// ==============================================================================
final productSearchViewModelProvider = AsyncNotifierProvider<ProductSearchViewModel, List<Product>>(() {
  return ProductSearchViewModel();
});

class ProductSearchViewModel extends AsyncNotifier<List<Product>> {
  @override
  FutureOr<List<Product>> build() {
    return [];
  }
  // ---------------------------------------------------------------------------
  // Recherche
  // ---------------------------------------------------------------------------
  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = const AsyncData([]);
      return;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(openFoodFactsRepositoryProvider);
      return await repository.searchProducts(query);
    });
  }
  // ---------------------------------------------------------------------------
  // Clear
  // ---------------------------------------------------------------------------
  void clear() {
    state = const AsyncData([]);
  }
}
