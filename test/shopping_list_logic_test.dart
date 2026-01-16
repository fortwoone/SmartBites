import 'package:flutter_test/flutter_test.dart';
import 'package:smartbites/models/shopping_list.dart';

void main() {
  group('Logique de la liste de courses', () {
    test('fromJson ajoute 1 aux produits sans quantité', () {
      final json = {
        'id': 1,
        'name': 'Weekly Groceries',
        'user_id': 'user123',
        'products': ['prod1', 'prod2'],
        'quantities': {
          'prod1': 5,
          // prod2 est volontairement absent ici pour tester la valeur par défaut
        },
      };

      final list = ShoppingList.fromJson(json);

      expect(list.quantities['prod1'], 5);
      expect(list.quantities['prod2'], 1);
    });

    // On garde le test qui vérifie qu'une quantité fournie est utilisée
    test('fromJson utilise la quantité fournie pour prod2', () {
      final json = {
        'id': 2,
        'name': 'Single List',
        'user_id': 'user123',
        'products': ['prod1', 'prod2'],
        'quantities': {
          'prod1': 2,
          'prod2': 7,
        },
      };

      final list = ShoppingList.fromJson(json);

      expect(list.quantities['prod1'], 2);
      expect(list.quantities['prod2'], 7);
    });

    test('fromJson convertit les quantités chaîne en entiers', () {
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

  });
}
