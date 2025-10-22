// dart
// File: lib/models/product.dart
class Product {
  final String barcode;
  final String? name;
  final String? brands;
  final String? ingredientsText;
  final String? imageURL;
  final Map<String, dynamic>? nutriments;

  Product({
    required this.barcode,
    this.name,
    this.brands,
    this.ingredientsText,
    this.nutriments,
    this.imageURL
  });

  factory Product.fromJson(String barcode, Map<String, dynamic> json) {
    return Product(
      barcode: barcode,
      name: json['product_name'] as String?,
      brands: json['brands'] as String?,
      imageURL: json['image_url'] as String?,
      ingredientsText: json['ingredients_text'] as String?,
      nutriments: json['nutriments'] is Map ? Map<String, dynamic>.from(json['nutriments']) : null,
    );
  }
}