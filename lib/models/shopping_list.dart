// ==============================================================================
// MODÈLE : ShoppingList
// ==============================================================================
class ShoppingList {
  final int? id;
  final String name;
  final String userId;
  final List<String> products;
  final Map<String, int> quantities;

  // Constructeur
  const ShoppingList({
    this.id,
    required this.name,
    required this.userId,
    this.products = const [],
    this.quantities = const {},
  });

  // ---------------------------------------------------------------------------
  // FACTORY : Crée une instance de Product (JSON -> Objet)
  // ---------------------------------------------------------------------------
  factory ShoppingList.fromJson(Map<String, dynamic> json) {
    List<String> products = [];
    if (json['products'] is List) {
      for (var p in json['products']) {
        products.add(p.toString());
      }
    }
    Map<String, int> quantities = {};
    if (json['quantities'] is Map) {
      (json['quantities'] as Map).forEach((key, value) {
        if (value is int) {
          quantities[key.toString()] = value;
        } else {
          quantities[key.toString()] = int.tryParse(value.toString()) ?? 1;
        }
      });
    }

    for (var product in products) {
      if (!quantities.containsKey(product)) {
        quantities[product] = 1;
      }
    }
    return ShoppingList(id: json['id'] as int?, name: json['name'] as String, userId: json['user_id'] as String, products: products, quantities: quantities);
  }

  // Convertit l'objet en JSON
  Map<String, dynamic> toJson() {
    return {'id': id,
      'name': name,
      'user_id': userId,
      'products': products,
      'quantities': quantities};
  }

  // Permet de créer une copie modifiée de l'objet
  ShoppingList copyWith({
    int? id,
    String? name,
    String? userId,
    List<String>? products,
    Map<String, int>? quantities,
  }) {
    return ShoppingList(id: id ?? this.id,
      name: name ?? this.name,
      userId: userId ?? this.userId,
      products: products ?? this.products,
      quantities: quantities ?? this.quantities);
  }
}
