
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

    Product({
        required this.barcode,
        this.name,
        this.frName,
        this.enName,
        this.brands,
        this.ingredientsText,
        this.nutriments,
        this.imageURL,
        this.imageSmallURL,
        this.nutriscoreGrade,
        this.novaGroup = "unknown"
    });

    factory Product.fromJson(String barcode, Map<String, dynamic> json) {
        return Product(
            barcode: barcode,
            name: json['product_name'] as String?,
            frName: json["product_name_fr"] as String?,
            enName: json["product_name_en"] as String?,
            brands: json['brands'] as String?,
            imageURL: json['image_url'] as String?,
            imageSmallURL: json["image_small_url"] as String?,
            ingredientsText: json['ingredients_text'] as String?,
            nutriments: json['nutriments'] is Map ? Map<String, dynamic>.from(json['nutriments']) : null,
            nutriscoreGrade: json["nutriscore_grade"] as String?,
            novaGroup: json["nova_group"] is int ? json["nova_group"].toString() : "unknown"
        );
    }
}