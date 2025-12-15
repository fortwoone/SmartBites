//dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class OpenFoodFactsRepository {
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

    /// Search products by name (returns an empty list if none).
    /// Uses the OpenFoodFacts search endpoint and maps results to `Product`.
    Future<List<Product>> fetchProductsByName(String query, {int pageSize = 20}) async {
        final encoded = Uri.encodeQueryComponent(query);
        const fields = 'code,product_name,product_name_fr,product_name_en,brands,image_url,image_small_url,ingredients_text,nutriments';
        final uri = Uri.parse('https://world.openfoodfacts.org/cgi/search.pl'
            '?search_terms=$encoded&search_simple=1&action=process&json=1&page_size=$pageSize'
            '&fields=$fields',
        );

        final response = await client.get(uri).timeout(const Duration(seconds: 15));
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

