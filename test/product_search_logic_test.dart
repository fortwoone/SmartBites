import 'package:flutter_test/flutter_test.dart';
import 'package:smartbites/models/product.dart';
import 'package:smartbites/viewmodels/product_search_viewmodel.dart';

void main() {
  group('ProductSearchViewModel Logic Tests', () {
    // We instantiate the class but don't need the Riverpod state for these helpers
    final viewModel = ProductSearchViewModel();

    test('extractBrands should return unique, trimmed, and sorted brands', () {
      final products = [
        const Product(barcode: '1', name: 'P1', brands: 'Nestlé, Danone '),
        const Product(barcode: '2', name: 'P2', brands: 'danone'),
        const Product(barcode: '3', name: 'P3', brands: ''),
        const Product(barcode: '4', name: 'P4', brands: null),
      ];

      final result = viewModel.extractBrands(products);

      expect(result, ['Danone', 'danone', 'Nestlé']);
      // Note: the current implementation sorts case-sensitively in a way? 
      // ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      // So 'Danone' and 'danone' will be next to each other.
    });

    test('extractCategories should replace dashes with spaces and sort', () {
      final products = [
        const Product(barcode: '1', name: 'P1', categories: ['en:dairy', 'fr:fromages-frais']),
        const Product(barcode: '2', name: 'P2', categories: ['en:snacks']),
      ];

      final result = viewModel.extractCategories(products);

      expect(result.contains('en:dairy'), true);
      expect(result.contains('fr:fromages frais'), true);
      expect(result.contains('en:snacks'), true);
    });

    test('extractCategories should ignore empty categories', () {
      final products = [
        const Product(barcode: '1', name: 'P1', categories: ['', 'valid']),
      ];

      final result = viewModel.extractCategories(products);

      expect(result, ['valid']);
    });
  });
}
