// ==============================================================================
// MODÈLE : Product
// ==============================================================================
class Product {
  final String barcode;
  final String? name;
  final String? frName;
  final String? enName;
  final String? brands;
  final String? brandsFr;
  final String? brandsEn;
  final String? ingredientsText;
  final String? imageURL;
  final String? imageSmallURL;
  final Map<String, dynamic>? nutriments;
  final String? nutriscoreGrade;
  final String novaGroup;
  final List<String> categories;

  const Product({
    required this.barcode,
    this.name,
    this.frName,
    this.enName,
    this.brands,
    this.brandsFr,
    this.brandsEn,
    this.ingredientsText,
    this.imageURL,
    this.imageSmallURL,
    this.nutriments,
    this.nutriscoreGrade,
    this.novaGroup = 'unknown',
    this.categories = const [],
  });

  // ---------------------------------------------------------------------------
  // FACTORY : Crée une instance de Product (JSON -> Objet)
  // ---------------------------------------------------------------------------
  factory Product.fromJson(Map<String, dynamic> json) {
    String? brandsRaw = json['brands'] as String?;
    String? brandsFr = json['brands_fr'] as String?;
    String? brandsEn = json['brands_en'] as String?;

    List<String> cleanBrands(String? raw) {
      if (raw == null || raw.isEmpty) return [];
      final parts = raw.split(',').map((b) => b.trim().toLowerCase()).toSet().toList();
      return parts.map((b) => b[0].toUpperCase() + b.substring(1)).toList();
    }

    final rawCategories = json['categories_tags'] ?? json['categories'] ?? <String>[];
    List<String> categoriesList = [];
    if (rawCategories is List) {
      categoriesList = rawCategories.map((e) {
        final s = e.toString().trim();
        return s.contains(':') ? s.split(':')[1] : s;
      }).toSet().toList();
    } else if (rawCategories is String) {
      categoriesList = rawCategories.split(',').map((e) => e.trim()).toSet().toList();
    }

    return Product(
      barcode: json['barcode'] as String? ?? '',
      name: json['product_name'] as String?,
      frName: json['product_name_fr'] as String?,
      enName: json['product_name_en'] as String?,
      brands: cleanBrands(brandsRaw).join(', '),
      brandsFr: cleanBrands(brandsFr).join(', '),
      brandsEn: cleanBrands(brandsEn).join(', '),
      ingredientsText: json['ingredients_text'] as String?,
      imageURL: json['image_url'] as String?,
      imageSmallURL: json['image_small_url'] as String?,
      nutriments: json['nutriments'] is Map
          ? Map<String, dynamic>.from(json['nutriments'])
          : null,
      nutriscoreGrade: json['nutriscore_grade'] as String?,
      novaGroup: _parseNovaGroup(json['nova_group']),
      categories: categoriesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'barcode': barcode,
      'product_name': name,
      'product_name_fr': frName,
      'product_name_en': enName,
      'brands': brands,
      'ingredients_text': ingredientsText,
      'image_url': imageURL,
      'image_small_url': imageSmallURL,
      'nutriments': nutriments,
      'nutriscore_grade': nutriscoreGrade,
      'nova_group': novaGroup,
    };
  }

  // ---------------------------------------------------------------------------
  // Copy With
  // ---------------------------------------------------------------------------
  Product copyWith({
    String? barcode,
    String? name,
    String? frName,
    String? enName,
    String? brands,
    String? brandsFr,
    String? brandsEn,
    String? ingredientsText,
    String? imageURL,
    String? imageSmallURL,
    Map<String, dynamic>? nutriments,
    String? nutriscoreGrade,
    String? novaGroup,
    List<String>? categories,
  }) {
    return Product(
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      frName: frName ?? this.frName,
      enName: enName ?? this.enName,
      brands: brands ?? this.brands,
      brandsFr: brandsFr ?? this.brandsFr,
      brandsEn: brandsEn ?? this.brandsEn,
      ingredientsText: ingredientsText ?? this.ingredientsText,
      imageURL: imageURL ?? this.imageURL,
      imageSmallURL: imageSmallURL ?? this.imageSmallURL,
      nutriments: nutriments ?? this.nutriments,
      nutriscoreGrade: nutriscoreGrade ?? this.nutriscoreGrade,
      novaGroup: novaGroup ?? this.novaGroup,
      categories: categories ?? this.categories,
    );
  }

  // ---------------------------------------------------------------------------
  // Nova group normalization
  // ---------------------------------------------------------------------------
  static String _parseNovaGroup(dynamic value) {
    if (value is int) return value.toString();
    return value as String? ?? 'unknown';
  }
}
