import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../providers/app_providers.dart';

// ==============================================================================
// VIEW MODEL : HistoryViewModel
// ==============================================================================
final historyViewModelProvider = NotifierProvider<HistoryViewModel, List<Product>>(() {
  return HistoryViewModel();
});

class HistoryViewModel extends Notifier<List<Product>> {
  @override
  List<Product> build() {
    return ref.watch(historyRepositoryProvider).getHistory();
  }

  // ---------------------------------------------------------------------------
  // Ajouter un produit à l'historique
  // ---------------------------------------------------------------------------
  Future<void> addToHistory(Product product) async {
    final repo = ref.read(historyRepositoryProvider);
    await repo.saveProduct(product);
    state = repo.getHistory();
  }

  // ---------------------------------------------------------------------------
  // Effacer l'historique
  // ---------------------------------------------------------------------------
  Future<void> clearHistory() async {
     final repo = ref.read(historyRepositoryProvider);
     await repo.clearHistory();
     state = [];
  }
}
