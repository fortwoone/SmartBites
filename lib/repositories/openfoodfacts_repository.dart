import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/product_price.dart';
import '../models/product_search_filters.dart';

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
  Future<List<Product>> searchProducts(
      String query, {
        int page = 1,
        int pageSize = 25,
        ProductSearchFilters? filters,
        required String locale, // pass 'en' or 'fr'
      }) async {
    try {
      final encodedQuery = Uri.encodeQueryComponent(query);

      const fields =
          'code,product_name,product_name_fr,product_name_en,brands,'
          'image_url,image_small_url,ingredients_text,nutriments,'
          'nutriscore_grade,nova_group,categories_tags';

      final Map<String, String> params = {
        'search_terms': encodedQuery,
        'search_simple': '1',
        'action': 'process',
        'json': '1',
        'page_size': pageSize.toString(),
        'page': page.toString(),
        'fields': fields,
        // keep your France filter
        'tagtype_0': 'countries',
        'tag_contains_0': 'contains',
        'tag_0': 'france',
      };

      int tagIndex = 1;

      if (filters?.brand != null && filters!.brand!.isNotEmpty) {
        params['tagtype_$tagIndex'] = 'brands';
        params['tag_contains_$tagIndex'] = 'contains';
        params['tag_$tagIndex'] = filters.brand!;
        tagIndex++;
      }

      if (filters?.category != null && filters!.category!.isNotEmpty) {
        params['tagtype_$tagIndex'] = 'categories';
        params['tag_contains_$tagIndex'] = 'contains';
        params['tag_$tagIndex'] = filters.category!;
        tagIndex++;
      }

      if (filters?.nutriScore != null && filters!.nutriScore!.isNotEmpty) {
        params['tagtype_$tagIndex'] = 'nutriscore_grade';
        params['tag_contains_$tagIndex'] = 'contains';
        params['tag_$tagIndex'] = filters.nutriScore!.toLowerCase();
        tagIndex++;
      }

      final uri = Uri.https(
        'fr.openfoodfacts.org',
        '/cgi/search.pl',
        params,
      );

      final response = await _client.get(uri).timeout(
          const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Erreur recherche OFF : ${response.statusCode}');
      }

      final Map<String, dynamic> body = json.decode(response.body) as Map<
          String,
          dynamic>;
      final productsList = (body['products'] as List<dynamic>?) ?? [];

      return productsList.map((jsonItem) {
        final p = jsonItem as Map<String, dynamic>;
        final barcode = p['code'] as String? ?? '';

        // Filter categories by locale
        List<String> categories = [];
        final rawCategories = p['categories_tags'] ?? <String>[];
        if (rawCategories is List) {
          categories = rawCategories
              .whereType<String>()
              .where((c) =>
              c.startsWith('$locale:')) // keep only locale-specific categories
              .toList();
        }

        // Brands: normalize capitalization
        String? brands = p['brands'] as String?;
        if (brands != null) {
          brands = brands
              .split(',')
              .map((b) => b.trim())
              .map((b) => b.toLowerCase())
              .map((b) => b[0].toUpperCase() + b.substring(1))
              .join(', ');
        }

        final product = Product.fromJson({
          ...p,
          'barcode': barcode,
          'categories_tags': categories,
          'brands': brands,
        });

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
