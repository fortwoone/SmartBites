import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/product_price.dart';

// ==============================================================================
// REPOSITORY : OpenFoodFactsRepository
// ==============================================================================
class OpenFoodFactsRepository {
  static const String _pricesUrl = 'https://prices.openfoodfacts.org/api/v1';
  final http.Client _client;
  final Map<String, ProductPrice?> _priceCache = {};
  final Map<String, Product?> _productCache = {};

  OpenFoodFactsRepository({http.Client? client}) : _client = client ?? http.Client();
  static final OpenFoodFactsRepository instance = OpenFoodFactsRepository();

  // ---------------------------------------------------------------------------
  // Récupére un produit avec le code-barres
  // ---------------------------------------------------------------------------
  Future<Product?> getProduct(String barcode) async {
    if (_productCache.containsKey(barcode)) {
      return _productCache[barcode];
    }
    try {
      final uri = Uri.parse('https://world.openfoodfacts.org/api/v0/product/$barcode.json');
      final response = await _client.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) {
        throw Exception('Erreur réseau OFF : ${response.statusCode}');
      }
      final Map<String, dynamic> body = json.decode(response.body) as Map<String, dynamic>;
      if (body['status'] == 1) {
        final productJson = body['product'] as Map<String, dynamic>;
        productJson['barcode'] = barcode;
        final product = Product.fromJson(productJson);
        _productCache[barcode] = product;
        return product;
      } else {
        _productCache[barcode] = null;
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Recherche de produits par Nom
  // ---------------------------------------------------------------------------
  Future<List<Product>> searchProducts(String query, {int page = 1, int pageSize = 25}) async {
    try {
      final encodedQuery = Uri.encodeQueryComponent(query);
      const fields = 'code,product_name,product_name_fr,product_name_en,brands,image_url,image_small_url,ingredients_text,nutriments,nutriscore_grade,nova_group';
      
      final uri = Uri.parse('https://fr.openfoodfacts.org/cgi/search.pl'
          '?search_terms=$encodedQuery&search_simple=1&action=process&json=1'
          '&page_size=$pageSize&page=$page'
          '&fields=$fields'
          '&tagtype_0=countries&tag_contains_0=contains&tag_0=france');

      final response = await _client.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Erreur recherche OFF : ${response.statusCode}');
      }

      final Map<String, dynamic> body = json.decode(response.body) as Map<String, dynamic>;
      final productsList = (body['products'] as List<dynamic>?) ?? [];

      return productsList.map((jsonItem) {
        final p = jsonItem as Map<String, dynamic>;
        final barcode = p['code'] as String? ?? '';
        final product = Product.fromJson({...p, 'barcode': barcode});
        if (barcode.isNotEmpty) {
          _productCache[barcode] = product;
        }
        return product;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // ---------------------------------------------------------------------------
  // Récupérer les prix (Open Prices)
  // ---------------------------------------------------------------------------
  Future<List<ProductPrice>> getPrices(String barcode) async {
    try {
      final uri = Uri.parse('$_pricesUrl/prices?product_code=$barcode&page_size=10');
      final response = await _client.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List<dynamic>? ?? [];
        return items.map((item) => ProductPrice.fromJson(item)).toList()..sort((a, b) => b.date.compareTo(a.date));
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // ---------------------------------------------------------------------------
  // Gestion du Cache
  // ---------------------------------------------------------------------------
  void clearCache() {
    _productCache.clear();
    _priceCache.clear();
  }
}
