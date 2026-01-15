import 'package:flutter_test/flutter_test.dart';
import 'package:smartbites/models/shopping_list.dart';

void main() {
  group('ShoppingList Logic Tests', () {
    test('fromJson should add default quantity of 1 for missing products in quantities map', () {
      final json = {
        'id': 1,
        'name': 'Weekly Groceries',
        'user_id': 'user123',
        'products': ['prod1', 'prod2'],
        'quantities': {
          'prod1': 5,
          // prod2 is missing here
        },
      };

      final list = ShoppingList.fromJson(json);

      expect(list.quantities['prod1'], 5);
      expect(list.quantities['prod2'], 1);
    });

    test('fromJson should parse string quantities as integers', () {
      final json = {
        'id': 1,
        'name': 'Weekly Groceries',
        'user_id': 'user123',
        'products': ['prod1'],
        'quantities': {
          'prod1': '3',
        },
      };

      final list = ShoppingList.fromJson(json);

      expect(list.quantities['prod1'], 3);
    });

    test('fromJson should use default 1 for invalid string quantities', () {
      final json = {
        'id': 1,
        'name': 'Weekly Groceries',
        'user_id': 'user123',
        'products': ['prod1'],
        'quantities': {
          'prod1': 'abc',
        },
      };

      final list = ShoppingList.fromJson(json);

      expect(list.quantities['prod1'], 1);
    });

    test('fromJson should handle empty quantities map', () {
      final json = {
        'id': 1,
        'name': 'Weekly Groceries',
        'user_id': 'user123',
        'products': ['prod1', 'prod2'],
        'quantities': {},
      };

      final list = ShoppingList.fromJson(json);

      expect(list.quantities['prod1'], 1);
      expect(list.quantities['prod2'], 1);
    });
  });
}
