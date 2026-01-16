import 'package:flutter_test/flutter_test.dart';
import 'package:smartbites/models/product_price.dart';

void main() {
  group('Logique des prix produit', () {
    test('fromJson lit le prix, la devise et le lieu', () {
      final json = {
        'price': 2.5,
        'currency': 'EUR',
        'location_name': 'Test Store',
      };

      final productPrice = ProductPrice.fromJson(json);

      expect(productPrice.price, 2.5);
      expect(productPrice.currency, 'EUR');
      expect(productPrice.location, 'Test Store');
      expect(productPrice.storeName, isNull);
    });

    test('fromJson gère l\'absence de devise et de lieu', () {
      final json = {
        'price': 1.99,
      };

      final productPrice = ProductPrice.fromJson(json);

      expect(productPrice.price, 1.99);
      expect(productPrice.currency, 'EUR');
      expect(productPrice.location, '');
      expect(productPrice.storeName, isNull);
    });
  });
}
