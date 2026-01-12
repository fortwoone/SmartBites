// ==============================================================================
// MODÈLE : Product
// ==============================================================================
class Product {
  final String barcode;
  final String? name;
  final String? frName;
  final String? enName;
  final String? brands;
  final String? ingredientsText;
  final String? imageURL;
  final String? imageSmallURL;
  final Map<String, dynamic>? nutriments;
  final String? nutriscoreGrade;
  final String novaGroup;

  // Constructeur
  const Product({
    required this.barcode,
    this.name,
    this.frName,
    this.enName,
    this.brands,
    this.ingredientsText,
    this.imageURL,
    this.imageSmallURL,
    this.nutriments,
    this.nutriscoreGrade,
    this.novaGroup = 'unknown',
  });

  // ---------------------------------------------------------------------------
  // FACTORY : Crée une instance de Product (JSON -> Objet)
  // ---------------------------------------------------------------------------
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(barcode: json['barcode'] as String? ?? '',
      name: json['product_name'] as String?,
      frName: json['product_name_fr'] as String?,
      enName: json['product_name_en'] as String?,
      brands: json['brands'] as String?,
      ingredientsText: json['ingredients_text'] as String?,
      imageURL: json['image_url'] as String?,
      imageSmallURL: json['image_small_url'] as String?,
      nutriments: json['nutriments'] is Map ? Map<String, dynamic>.from(json['nutriments']) : null,
      nutriscoreGrade: json['nutriscore_grade'] as String?,
      novaGroup: _parseNovaGroup(json['nova_group']));
  }

  // Convertit l'objet en JSON
  Map<String, dynamic> toJson() {
    return {'barcode': barcode,
      'product_name': name,
      'product_name_fr': frName,
      'product_name_en': enName,
      'brands': brands,
      'ingredients_text': ingredientsText,
      'image_url': imageURL,
      'image_small_url': imageSmallURL,
      'nutriments': nutriments,
      'nutriscore_grade': nutriscoreGrade,
      'nova_group': novaGroup };
  }

  // Permet de créer une copie modifiée de l'objet
  Product copyWith({
    String? barcode,
    String? name,
    String? frName,
    String? enName,
    String? brands,
    String? ingredientsText,
    String? imageURL,
    String? imageSmallURL,
    Map<String, dynamic>? nutriments,
    String? nutriscoreGrade,
    String? novaGroup,
  }) {
    return Product(barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      frName: frName ?? this.frName,
      enName: enName ?? this.enName,
      brands: brands ?? this.brands,
      ingredientsText: ingredientsText ?? this.ingredientsText,
      imageURL: imageURL ?? this.imageURL,
      imageSmallURL: imageSmallURL ?? this.imageSmallURL,
      nutriments: nutriments ?? this.nutriments,
      nutriscoreGrade: nutriscoreGrade ?? this.nutriscoreGrade,
      novaGroup: novaGroup ?? this.novaGroup );
  }

  // normaliser le groupe NOVA (int -> String)
  static String _parseNovaGroup(dynamic value) {
    if (value is int) {
      return value.toString();
    }
    return value as String? ?? 'unknown';
  }
}
