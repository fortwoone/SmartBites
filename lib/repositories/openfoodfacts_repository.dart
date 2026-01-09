import 'dart:convert';
import 'package:SmartBites/models/product_price.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class OpenFoodFactsRepository {
    static final OpenFoodFactsRepository _instance = OpenFoodFactsRepository._internal();
    factory OpenFoodFactsRepository() => _instance;
    OpenFoodFactsRepository._internal() : client = http.Client();

    static const String baseUrl = 'https://world.openfoodfacts.org/api/v2';
    static const String pricesUrl = 'https://prices.openfoodfacts.org/api/v1';
    final http.Client client;

    final Map<String, ProductPrice?> _priceCache = {};
    final Map<String, Product?> _productCache = {};

    Future<Product?> fetchProductByBarcode(String barcode) async {
        if (_productCache.containsKey(barcode)) {
            return _productCache[barcode];
        }

        final uri = Uri.parse('https://world.openfoodfacts.org/api/v0/product/$barcode.json');
        final response = await client.get(uri).timeout(const Duration(seconds: 10));

        if (response.statusCode != 200) {
            throw Exception('Network error: ${response.statusCode}');
        }

        final Map<String, dynamic> body = json.decode(response.body) as Map<String, dynamic>;
        final status = body['status'];
        if (status == 1) {
            final productJson = body['product'] as Map<String, dynamic>;
            final product = Product.fromJson(barcode, productJson);
            _productCache[barcode] = product;
            return product;
        } else {
            _productCache[barcode] = null;
            return null;
        }
    }

    Future<List<ProductPrice>> getProductPrices(String barcode) async {
        try {
            final response = await http.get(
                Uri.parse('$pricesUrl/prices?product_code=$barcode&page_size=5'),
            ).timeout(const Duration(seconds: 10));

            if (response.statusCode == 200) {
                final data = json.decode(response.body);
                final items = data['items'] as List<dynamic>? ?? [];

                return items
                    .map((item) => ProductPrice.fromJson(item))
                    .toList()
                    ..sort((a, b) => b.date.compareTo(a.date));
            }
            return [];
        } catch (e) {
            return [];
        }
    }

    Future<void> preloadPrices(List<String> barcodes) async {
        final chunks = <List<String>>[];
        for (var i = 0; i < barcodes.length; i += 5) {
            chunks.add(barcodes.sublist(i, i + 5 > barcodes.length ? barcodes.length : i + 5));
        }
        for (final chunk in chunks) {
            await Future.wait(chunk.map((code) => getLatestPrice(code)));
        }
    }

    Future<ProductPrice?> getLatestPrice(String barcode) async {
        if (_priceCache.containsKey(barcode)) {
            return _priceCache[barcode];
        }

        final prices = await getProductPrices(barcode);
        final latest = prices.isEmpty ? null : prices.first;
        _priceCache[barcode] = latest;
        return latest;
    }

    Future<List<Product>> fetchProductsByName(String query, {int pageSize = 50, int page = 1}) async {
        final encoded = Uri.encodeQueryComponent(query);
        const fields = 'code,product_name,product_name_fr,product_name_en,brands,image_url,image_small_url,ingredients_text,nutriments';
        final uri = Uri.parse('https://fr.openfoodfacts.org/cgi/search.pl'
            '?search_terms=$encoded&search_simple=1&action=process&json=1&page_size=$pageSize&page=$page'
            '&fields=$fields'
            '&tagtype_0=countries&tag_contains_0=contains&tag_0=france',
        );

        final response = await client.get(uri).timeout(const Duration(seconds: 15));
        if (response.statusCode != 200) {
            throw Exception('Network error: ${response.statusCode}');
        }

        final Map<String, dynamic> body = json.decode(response.body) as Map<String, dynamic>;
        final productsJson = (body['products'] as List<dynamic>?) ?? <dynamic>[];

        final lowerQuery = query.toLowerCase();

        return productsJson.map((p) {
                final productJson = p as Map<String, dynamic>;
                final code = (productJson['code'] as String?) ?? '';
                final product = Product.fromJson(code, productJson);
                _productCache[code] = product;
                return product;
            })
            .where((p) {
                final name = (p.name ?? '').toLowerCase();
                return name.contains(lowerQuery);
            }).toList();
    }

    void clearCache() {
        _priceCache.clear();
        _productCache.clear();
    }

    void invalidateProduct(String barcode) {
        _productCache.remove(barcode);
        _priceCache.remove(barcode);
    }
}

