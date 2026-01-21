// models/product_search_filters.dart
class ProductSearchFilters {
  final String? brand;
  final String? category;
  final String? nutriScore; // A, B, C, D, E
  final String? sortBy;

  const ProductSearchFilters({
    this.brand,
    this.category,
    this.nutriScore,
    this.sortBy,
  });

  ProductSearchFilters copyWith({
    String? brand,
    String? category,
    String? nutriScore,
    String? priceSort,
    String? sortBy,
  }) {
    return ProductSearchFilters(
      brand: brand ?? this.brand,
      category: category ?? this.category,
      nutriScore: nutriScore ?? this.nutriScore,
      sortBy: sortBy ?? this.sortBy
    );
  }

  bool get isEmpty => brand == null && category == null && nutriScore == null && sortBy == null;

  bool get hasApiFilters => brand != null || category != null || nutriScore != null || sortBy != null;
}
