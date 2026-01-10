
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

// ==============================================================================
// REPOSITORY : HistoryRepository
// ==============================================================================
class HistoryRepository {
  final SharedPreferences _prefs;

  HistoryRepository(this._prefs);
  static const String _recentProductsKey = 'recent_products';
  static const int _maxRecentProducts = 50;

  // ---------------------------------------------------------------------------
  // Sauvegarder un produit dans l'historique
  // ---------------------------------------------------------------------------
  Future<void> saveProduct(Product product) async {
    List<Product> products = getHistory();
    products.removeWhere((p) => p.barcode == product.barcode);
    products.insert(0, product);
    if (products.length > _maxRecentProducts) {
      products = products.sublist(0, _maxRecentProducts);
    }
    final jsonList = products.map((p) => p.toJson()).toList();
    await _prefs.setString(_recentProductsKey, jsonEncode(jsonList));
  }

  // ---------------------------------------------------------------------------
  // Récupérer tout l'historique
  // ---------------------------------------------------------------------------
  List<Product> getHistory() {
    final jsonString = _prefs.getString(_recentProductsKey);
    if (jsonString == null) return [];
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // ---------------------------------------------------------------------------
  // Effacer l'historique
  // ---------------------------------------------------------------------------
  Future<void> clearHistory() async {
    await _prefs.remove(_recentProductsKey);
  }
}
