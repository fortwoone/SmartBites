import 'package:flutter_test/flutter_test.dart';
import 'package:smartbites/models/product_price.dart';

void main() {
  group('ProductPrice Logic Tests', () {
    test('should parse 10-digit Unix timestamp (seconds)', () {
      final json = {
        'price': 2.5,
        'currency': 'EUR',
        'location_name': 'Test Store',
        'date': 1705334400, // 2024-01-15T16:00:00Z approx
      };
      
      final productPrice = ProductPrice.fromJson(json);
      
      expect(productPrice.date.year, 2024);
      expect(productPrice.date.month, 1);
      expect(productPrice.date.day, 15);
    });

    test('should parse 13-digit Unix timestamp (milliseconds)', () {
      final json = {
        'price': 2.5,
        'date': 1705334400000, 
      };
      
      final productPrice = ProductPrice.fromJson(json);
      
      expect(productPrice.date.year, 2024);
    });

    test('should parse ISO 8601 string date', () {
      final json = {
        'price': 2.5,
        'date': '2024-01-15T16:00:00Z',
      };
      
      final productPrice = ProductPrice.fromJson(json);
      
      expect(productPrice.date.year, 2024);
      expect(productPrice.date.month, 1);
    });

    test('should return epoch 0 for invalid date', () {
      final json = {
        'price': 2.5,
        'date': 'invalid-date',
      };
      
      final productPrice = ProductPrice.fromJson(json);
      
      expect(productPrice.date.millisecondsSinceEpoch, 0);
    });

    test('should return epoch 0 for null date', () {
      final json = {
        'price': 2.5,
        'date': null,
      };
      
      final productPrice = ProductPrice.fromJson(json);
      
      expect(productPrice.date.millisecondsSinceEpoch, 0);
    });
  });
}
