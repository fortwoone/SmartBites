//dart
import 'package:flutter/material.dart';
import '../repositories/openfoodfacts_repository.dart';
import 'product_detail_page.dart';
import '../models/product.dart';

class ProductSearchPage extends StatefulWidget {
  final OpenFoodFactsRepository repository;

  ProductSearchPage({super.key, OpenFoodFactsRepository? repository})
      : repository = repository ?? OpenFoodFactsRepository();

  @override
  State<ProductSearchPage> createState() => _ProductSearchPageState();
}

class _ProductSearchPageState extends State<ProductSearchPage> {
  final TextEditingController _controller = TextEditingController();
  List<Product> _results = [];
  bool _loading = false;
  String? _error;

  Future<void> _search() async {
    final query = _controller.text.trim();
    if (query.isEmpty) {
      setState(() => _error = 'Please enter a product name');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _results = [];
    });

    try {
      final results = await widget.repository.fetchProductsByName(query);
      setState(() => _results = results);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _titleFor(Product p) => p.name ?? p.brands ?? 'Unknown product';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search products by name')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                labelText: 'Product name',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
              onSubmitted: (_) => _search(),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _search,
                icon: const Icon(Icons.search),
                label: const Text('Search'),
              ),
            ),
            const SizedBox(height: 12),
            if (_loading) const Center(child: CircularProgressIndicator()),
            if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
            Expanded(
              child: _results.isEmpty
                  ? const Center(child: Text('No results'))
                  : ListView.separated(
                itemCount: _results.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final p = _results[index];
                  return ListTile(
                    leading: p.imageURL != null
                        ? Image.network(p.imageURL!, width: 56, height: 56, fit: BoxFit.cover)
                        : const SizedBox(width: 56, height: 56),
                    title: Text(_titleFor(p)),
                    subtitle: Text(p.brands ?? ''),
                    onTap: () {
                      final code = p.barcode ?? ''; // expects Product to expose a barcode field set by fromJson
                      if (code.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('No barcode available for this product')));
                        return;
                      }
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ProductDetailPage(barcode: code, repository: widget.repository),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
