//dart
import 'dart:convert';
import 'package:food/models/product_price.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class OpenFoodFactsRepository {
    static const String baseUrl = 'https://world.openfoodfacts.org/api/v2';
    static const String pricesUrl = 'https://prices.openfoodfacts.org/api/v1';
    final http.Client client;

    OpenFoodFactsRepository({http.Client? client}) : client = client ?? http.Client();

    /// Returns `Product` when found, `null` when product not found.
    /// Throws an exception on network / parsing errors.
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
                Uri.parse('$pricesUrl/prices?product_code=$barcode&page_size=10'),
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

    Future<ProductPrice?> getLatestPrice(String barcode) async {
        final prices = await getProductPrices(barcode);
        return prices.isEmpty ? null : prices.first;
    }

    /// Search products by name (returns an empty list if none).
    /// Uses the OpenFoodFacts search endpoint and maps results to `Product`.
    Future<List<Product>> fetchProductsByName(String query, {int pageSize = 30}) async {
        final encoded = Uri.encodeQueryComponent(query);
        final uri = Uri.parse('https://world.openfoodfacts.org/cgi/search.pl'
            '?search_terms=$encoded&search_simple=1&action=process&json=1&page_size=$pageSize'
            '&tagtype_0=product_name&tag_contains_0=contains&tag_0=$encoded',
        );

        final response = await client.get(uri).timeout(const Duration(seconds: 30));
        if (response.statusCode != 200) {
            throw Exception('Network error: ${response.statusCode}');
        }

        final Map<String, dynamic> body = json.decode(response.body) as Map<String, dynamic>;
        final productsJson = (body['products'] as List<dynamic>?) ?? <dynamic>[];

        return productsJson.map((p) {
            final productJson = p as Map<String, dynamic>;
            final code = (productJson['code'] as String?) ?? '';
            return Product.fromJson(code, productJson);
        }).toList();
    }
}
