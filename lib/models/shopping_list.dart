// ==============================================================================
// MODÈLE : ShoppingList
// ==============================================================================
class ShoppingList {
  final int? id;
  final String name;
  final String userId;
  final List<String> products;
  final Map<String, int> quantities;
  final Map<String, double> prices;

  // Constructeur
  ShoppingList({
    this.id,
    required this.name,
    required this.userId,
    this.products = const [],
    this.quantities = const {},
    Map<String, double>? prices,
  }) : prices = prices ?? {};

  // ---------------------------------------------------------------------------
  // FACTORY : Crée une instance de ShoppingList depuis JSON
  // ---------------------------------------------------------------------------
  factory ShoppingList.fromJson(Map<String, dynamic> json) {
    // Products
    List<String> products = [];
    if (json['products'] is List) {
      for (var p in json['products']) {
        products.add(p.toString());
      }
    }

    // Quantities
    Map<String, int> quantities = {};
    if (json['quantities'] is Map) {
      (json['quantities'] as Map).forEach((key, value) {
        quantities[key.toString()] =
        value is int ? value : int.tryParse(value.toString()) ?? 1;
      });
    }

    // Prices
    Map<String, double> prices = {};
    if (json['prices'] is Map) {
      (json['prices'] as Map).forEach((key, value) {
        prices[key.toString()] =
        value is double ? value : double.tryParse(value.toString()) ?? 0.0;
      });
    }

    // Default quantity to 1 if missing
    for (var product in products) {
      if (!quantities.containsKey(product)) {
        quantities[product] = 1;
      }
    }

    return ShoppingList(
      id: json['id'] as int?,
      name: json['name'] as String,
      userId: json['user_id'] as String,
      products: products,
      quantities: quantities,
      prices: prices,
    );
  }

  // ---------------------------------------------------------------------------
  // Convertit l'objet en JSON
  // ---------------------------------------------------------------------------
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'user_id': userId,
      'products': products,
      'quantities': quantities,
    };
  }

  // ---------------------------------------------------------------------------
  // Permet de créer une copie modifiée de l'objet
  // ---------------------------------------------------------------------------
  ShoppingList copyWith({
    int? id,
    String? name,
    String? userId,
    List<String>? products,
    Map<String, int>? quantities,
    Map<String, double>? prices,
  }) {
    return ShoppingList(
      id: id ?? this.id,
      name: name ?? this.name,
      userId: userId ?? this.userId,
      products: products ?? this.products,
      quantities: quantities ?? this.quantities,
      prices: prices ?? this.prices,
    );
  }
}
