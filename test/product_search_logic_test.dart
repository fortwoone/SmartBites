import 'package:flutter_test/flutter_test.dart';
import 'package:smartbites/models/product.dart';
import 'package:smartbites/viewmodels/product_search_viewmodel.dart';

void main() {
  group('Logique de recherche de produits', () {
    final viewModel = ProductSearchViewModel();

    test('extractBrands retourne des marques uniques et triées', () {
      final products = [
        const Product(barcode: '1', name: 'P1', brands: 'Nestlé, Danone '),
        const Product(barcode: '2', name: 'P2', brands: 'danone'),
      ];

      final result = viewModel.extractBrands(products);

      expect(result, ['Danone', 'danone', 'Nestlé']);
    });

    test('extractCategories remplace les tirets par des espaces et enlève les vides', () {
      final products = [
        const Product(barcode: '1', name: 'P1', categories: ['en:dairy', 'fr:fromages-frais', '']),
      ];

      final result = viewModel.extractCategories(products);
      expect(result.contains('fr:fromages frais'), true);
      expect(result.contains('en:dairy'), true);
      expect(result.contains(''), false);
    });
  });
}
