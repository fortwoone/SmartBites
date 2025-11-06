import 'package:flutter/material.dart';
import '../repositories/openfoodfacts_repository.dart';
import '../screens/product_detail_page.dart';
import '../models/product.dart';
import '../widgets/product_price_widget.dart';

class ProductSearchPage extends StatefulWidget {
    final OpenFoodFactsRepository repository;
    final bool inAddMode;

    ProductSearchPage({super.key, OpenFoodFactsRepository? repository, bool? inAddMode})
    : repository = repository ?? OpenFoodFactsRepository(), inAddMode = inAddMode ?? false;

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
            setState(() => _error = 'Veuillez entrer un nom de produit.');
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

    String _titleFor(Product p) => p.name ?? p.brands ?? 'Produit inconnu';

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: const Text('Chercher un produit')),
            body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                    children: [
                        // Row with TextField and search button next to it
                        Row(
                            children: [
                                Expanded(
                                    child: SizedBox(
                                        height: 56,
                                        child: TextField(
                                            controller: _controller,
                                            textInputAction: TextInputAction.search,
                                            decoration: InputDecoration(
                                                hintText: 'Recherche produit...',
                                                hintStyle: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic),
                                                border: const OutlineInputBorder(
                                                    borderRadius: BorderRadius.only(
                                                        topLeft: Radius.circular(8),
                                                        bottomLeft: Radius.circular(8),
                                                        topRight: Radius.zero,
                                                        bottomRight: Radius.zero,
                                                    ),
                                                    borderSide: BorderSide(
                                                        width: 0,
                                                        style: BorderStyle.none,
                                                    ),
                                                ),
                                                filled: true,
                                                contentPadding: EdgeInsets.all(16),
                                                fillColor: Colors.grey[200],
                                            ),
                                            onSubmitted: (_) => _search(),
                                        ),
                                    ),
                                ),
                                SizedBox(
                                    height: 56,
                                    child: ElevatedButton.icon(
                                        onPressed: _search,
                                        icon: const Icon(Icons.search),
                                        label: const Text('Rechercher'),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                            shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.only(
                                                    topRight: Radius.circular(8),
                                                    bottomRight: Radius.circular(8),
                                                    topLeft: Radius.zero,
                                                    bottomLeft: Radius.zero,
                                                ),
                                            ),
                                            padding: const EdgeInsets.symmetric(horizontal: 8),
                                        ),
                                    ),
                                ),
                            ],
                        ),
                        const SizedBox(height: 12),
                        if (_loading) const Center(child: CircularProgressIndicator()),
                        if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
                        Expanded(
                            child: _results.isEmpty
                                ? const Center(child: Text('Pas de résultats'))
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
                                              subtitle: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(p.brands ?? ''),
                                                  const SizedBox(height: 4),
                                                  ProductPriceWidget(
                                                    barcode: p.barcode,
                                                    repository: widget.repository,
                                                    compact: true,
                                                  ),
                                                ],
                                              ),
                                              onTap: () async {
                                                  final code = p.barcode; // expects Product to expose a barcode field set by fromJson
                                                  if (code.isEmpty) {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                          const SnackBar(content: Text('Pas de code-barres disponible')));
                                                      return;
                                                  }
                                                  final result = await Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (_) => ProductDetailPage(
                                                              barcode: code,
                                                              repository: widget.repository,
                                                              inAddMode: widget.inAddMode
                                                          ),
                                                      ),
                                                  );
                                                  if (!context.mounted){
                                                      return;
                                                  }
                                                  if (widget.inAddMode && result != null){
                                                      Navigator.pop(context, result);
                                                  }
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
