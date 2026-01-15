import 'package:flutter_test/flutter_test.dart';
import 'package:smartbites/models/recipe.dart';

void main() {
  group('Recipe Logic Tests', () {
    test('totalTime calculation should sum prepTime and bakingTime', () {
      const recipe = Recipe(
        userId: 'user1',
        name: 'Pasta',
        prepTime: 15,
        bakingTime: 20,
        instructions: 'Cook it.',
      );

      expect(recipe.totalTime, 35);
    });

    test('totalTime should handle zero values', () {
      const recipe = Recipe(
        userId: 'user1',
        name: 'Salad',
        prepTime: 0,
        bakingTime: 0,
        instructions: 'Mix it.',
      );

      expect(recipe.totalTime, 0);
    });
  });
}
