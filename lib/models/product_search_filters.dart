// models/product_search_filters.dart
class ProductSearchFilters {
  final String? brand;
  final String? category;
  final String? nutriScore; // A, B, C, D, E

  const ProductSearchFilters({
    this.brand,
    this.category,
    this.nutriScore,
  });

  ProductSearchFilters copyWith({
    String? brand,
    String? category,
    String? nutriScore,
    String? priceSort,
  }) {
    return ProductSearchFilters(
      brand: brand ?? this.brand,
      category: category ?? this.category,
      nutriScore: nutriScore ?? this.nutriScore,
    );
  }

  bool get isEmpty => brand == null && category == null && nutriScore == null;

  bool get hasApiFilters => brand != null || category != null || nutriScore != null;
}
