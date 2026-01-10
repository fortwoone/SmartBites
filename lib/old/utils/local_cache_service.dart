import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

class LocalCacheService {
    static const String _recentProductsKey = 'recent_products';
    static const int _maxRecentProducts = 50;
    
    static LocalCacheService? _instance;
    static SharedPreferences? _prefs;
    
    LocalCacheService._();
    
    static Future<LocalCacheService> getInstance() async {
        if (_instance == null) {
            _instance = LocalCacheService._();
            _prefs = await SharedPreferences.getInstance();
        }
        return _instance!;
    }
    
    Future<void> saveRecentProduct(Product product) async {
        final products = await getRecentProducts();
        products.removeWhere((p) => p.barcode == product.barcode);
        products.insert(0, product);
        if (products.length > _maxRecentProducts) {
            products.removeRange(_maxRecentProducts, products.length);
        }
        final jsonList = products.map((p) => _productToJson(p)).toList();
        await _prefs?.setString(_recentProductsKey, jsonEncode(jsonList));
    }
    
    Future<List<Product>> getRecentProducts() async {
        final jsonString = _prefs?.getString(_recentProductsKey);
        if (jsonString == null) return [];
        try {
            final List<dynamic> jsonList = jsonDecode(jsonString);
            return jsonList.map((json) => _productFromJson(json)).toList();
        } catch (e) {
            return [];
        }
    }
    
    Future<void> clearRecentProducts() async {
        await _prefs?.remove(_recentProductsKey);
    }
    
    Map<String, dynamic> _productToJson(Product p) {
        return {
            'barcode': p.barcode,
            'product_name': p.name,
            'product_name_fr': p.frName,
            'product_name_en': p.enName,
            'brands': p.brands,
            'ingredients_text': p.ingredientsText,
            'image_url': p.imageURL,
            'image_small_url': p.imageSmallURL,
            'nutriments': p.nutriments,
            'nutriscore_grade': p.nutriscoreGrade,
            'nova_group': p.novaGroup,
        };
    }
    
    Product _productFromJson(Map<String, dynamic> json) {
        return Product(
            barcode: json['barcode'] ?? '',
            name: json['product_name'],
            frName: json['product_name_fr'],
            enName: json['product_name_en'],
            brands: json['brands'],
            ingredientsText: json['ingredients_text'],
            imageURL: json['image_url'],
            imageSmallURL: json['image_small_url'],
            nutriments: json['nutriments'] is Map ? Map<String, dynamic>.from(json['nutriments']) : null,
            nutriscoreGrade: json['nutriscore_grade'],
            novaGroup: json['nova_group'] ?? 'unknown',
        );
    }
}
