class ProductPrice {
  final double price;
  final String currency;
  final String location;
  final String date;
  final String? storeName;

  ProductPrice({
    required this.price,
    required this.currency,
    required this.location,
    required this.date,
    this.storeName,
  });

  factory ProductPrice.fromJson(Map<String, dynamic> json) {
    return ProductPrice(
      price: (json['price'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'EUR',
      location: json['location_name'] ?? '',
      date: json['date'] ?? '',
      storeName: json['location']?['display_name'],
    );
  }
}
