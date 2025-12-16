import 'package:flutter/material.dart';

class ProductDetailPagetest extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductDetailPagetest({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final name = product['product_name'] ?? 'Unnamed product';
    final brand = product['brand_name'] ?? '';
    final price = product['product_price'] != null
        ? '${product['product_price']} ${product['product_currency'] ?? ''}'
        : 'Price not available';
    final description = product['product_ingrediants'] ?? '';
    final productUrl = product['product_link'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        backgroundColor: Colors.deepOrangeAccent.shade100,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            if (brand.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text('Brand: $brand', style: const TextStyle(fontSize: 16)),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text('Price: $price', style: const TextStyle(fontSize: 16, color: Colors.green)),
            ),
            if (description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(description, style: const TextStyle(fontSize: 16)),
              ),
            if (productUrl.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: GestureDetector(
                  onTap: () {
                    // TODO: Use url_launcher to open URL
                  },
                  child: Text(
                    'View product online',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      decoration: TextDecoration.underline,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
