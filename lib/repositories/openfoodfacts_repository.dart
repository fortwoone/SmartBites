import 'dart:convert';
import 'package:SmartBites/models/product_price.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class OpenFoodFactsRepository {
    static const String baseUrl = 'https://world.openfoodfacts.org/api/v2';
    static const String pricesUrl = 'https://prices.openfoodfacts.org/api/v1';
    final http.Client client;

    final Map<String, ProductPrice?> _priceCache = {};

    OpenFoodFactsRepository({http.Client? client}) : client = client ?? http.Client();
    Future<Product?> fetchProductByBarcode(String barcode) async {
        final uri = Uri.parse('https://world.openfoodfacts.org/api/v0/product/$barcode.json');
        final response = await client.get(uri).timeout(const Duration(seconds: 60));

        if (response.statusCode != 200) {
            throw Exception('Network error: ${response.statusCode}');
        }

        final Map<String, dynamic> body = json.decode(response.body) as Map<String, dynamic>;
        final status = body['status'];
        if (status == 1) {
            final productJson = body['product'] as Map<String, dynamic>;
            return Product.fromJson(barcode, productJson);
        } else {
            // status != 1 => product not found
            return null;
        }
    }

    Future<List<ProductPrice>> getProductPrices(String barcode) async {
        try {
            final response = await http.get(
                Uri.parse('$pricesUrl/prices?product_code=$barcode&page_size=5'),
            );

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
            print('Erreur lors de la récupération des prix: $e');
            return [];
        }
    }

    Future<void> preloadPrices(List<String> barcodes) async {
         await Future.wait(barcodes.map((code) => getLatestPrice(code)));
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

    /// Search products by name (returns an empty list if none).
    /// Uses the OpenFoodFacts search endpoint and maps results to `Product`.
    Future<List<Product>> fetchProductsByName(String query, {int pageSize = 50}) async {
        final encoded = Uri.encodeQueryComponent(query);
        const fields = 'code,product_name,product_name_fr,product_name_en,brands,image_url,image_small_url,ingredients_text,nutriments';
        final uri = Uri.parse('https://fr.openfoodfacts.org/cgi/search.pl'
            '?search_terms=$encoded&search_simple=1&action=process&json=1&page_size=$pageSize'
            '&fields=$fields'
            '&tagtype_0=countries&tag_contains_0=contains&tag_0=france',
        );

        final response = await client.get(uri).timeout(const Duration(seconds: 360));
        if (response.statusCode != 200) {
            throw Exception('Network error: ${response.statusCode}');
        }

        final Map<String, dynamic> body = json.decode(response.body) as Map<String, dynamic>;
        final productsJson = (body['products'] as List<dynamic>?) ?? <dynamic>[];

        final lowerQuery = query.toLowerCase();

        return productsJson.map((p) {
                final productJson = p as Map<String, dynamic>;
                final code = (productJson['code'] as String?) ?? '';
                return Product.fromJson(code, productJson);
            })
            .where((p) {
                final name = (p.name ?? '').toLowerCase();
                return name.contains(lowerQuery);
            }).toList();
    }
}

