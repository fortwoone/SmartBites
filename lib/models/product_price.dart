// ==============================================================================
// MODÈLE : ProductPrice
// ==============================================================================
class ProductPrice {
  final double price;
  final String currency;
  final String location;
  final DateTime date;
  final String? storeName;

  // Constructeur
  const ProductPrice({
    this.price = 0.0,
    this.currency = 'EUR',
    this.location = '',
    required this.date,
    this.storeName,
  });

  // ---------------------------------------------------------------------------
  // FACTORY : Crée une instance de Product (JSON -> Objet)
  // ---------------------------------------------------------------------------
  factory ProductPrice.fromJson(Map<String, dynamic> json) {
    return ProductPrice(
      price: (json['price'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'EUR',
      location: json['location_name'] ?? '',
      date: _parseDate(json['date'] ?? json['created_t']),
      storeName: json['location'] is Map ? json['location']['display_name'] : null);
  }

  // Convertit l'objet en JSON
  Map<String, dynamic> toJson() {
    return {
      'price': price,
      'currency': currency,
      'location_name': location,
      'date': date.toIso8601String()};
  }

  // Permet de créer une copie modifiée de l'objet
  ProductPrice copyWith({
    double? price,
    String? currency,
    String? location,
    DateTime? date,
    String? storeName,
  }) {
    return ProductPrice(
      price: price ?? this.price,
      currency: currency ?? this.currency,
      location: location ?? this.location,
      date: date ?? this.date,
      storeName: storeName ?? this.storeName);
  }

  DateTime getDateUtc() => date.toUtc();

  static DateTime _parseDate(dynamic d) {
    if (d == null) return DateTime.fromMillisecondsSinceEpoch(0);
    if (d is int) {
      if (d.toString().length == 10) {
        return DateTime.fromMillisecondsSinceEpoch(d * 1000, isUtc: true);
      }
      return DateTime.fromMillisecondsSinceEpoch(d, isUtc: true);
    }
    if (d is String) {
      try {
        return DateTime.parse(d).toUtc();
      } catch (e) {
        // Ignore
      }
      final intVal = int.tryParse(d);
      if (intVal != null) {
        if (intVal.toString().length == 10) {
          return DateTime.fromMillisecondsSinceEpoch(intVal * 1000, isUtc: true);
        }
        return DateTime.fromMillisecondsSinceEpoch(intVal, isUtc: true);
      }
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}
