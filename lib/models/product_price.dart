class ProductPrice {
  final double price;
  final String currency;
  final String location;
  final DateTime date;
  final String? storeName;

  ProductPrice({
    required this.price,
    required this.currency,
    required this.location,
    required this.date,
    this.storeName,
  });

  factory ProductPrice.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic d) {
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
          // ignnorer
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

    return ProductPrice(
      price: (json['price'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'EUR',
      location: json['location_name'] ?? '',
      date: parseDate(json['date'] ?? json['created_t']),
      storeName: json['location']?['display_name'],
    );
  }

  /// Returns the date converted to Europe/Paris timezone and formatted.
  /// Requires the caller to use `intl` and optionally `timezone` packages for locale-aware formatting.
  DateTime getDateUtc() => date.toUtc();
}
