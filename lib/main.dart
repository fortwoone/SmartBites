//dart
import 'package:flutter/material.dart';
import 'pages/product_search_page.dart';
import 'repositories/openfoodfacts_repository.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = OpenFoodFactsRepository();
    return MaterialApp(
      title: 'Product test',
      theme: ThemeData(useMaterial3: true),
      home: ProductSearchPage(repository: repo),
    );
  }
}
