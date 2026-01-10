import 'package:SmartBites/screens/product_detail_page_test.dart';
import 'package:flutter/material.dart';
import '../APIServices/ApiService.dart';
import '../APIServices/AuchanApiService.dart';
import '../APIServices/LeclercApiService.dart';
import '../l10n/app_localizations.dart';
import '../widgets/side_menu.dart';

class ProductSearchPage extends StatefulWidget {
  const ProductSearchPage({super.key});

  @override
  State<ProductSearchPage> createState() => _ProductSearchPageState();
}

class _ProductSearchPageState extends State<ProductSearchPage> {
  ApiService _api = LeclercApiService();
  final _controller = TextEditingController(text: '');
  bool _loading = false;
  List<dynamic> _results = [];
  String? _error;

  String _selectedApi = 'Leclerc';
  final Map<String, ApiService> _apis = {
    'Auchan': AuchanApiService(),
    'Leclerc': LeclercApiService(),
  };

  final GlobalKey<SideMenuState> _menuKey = GlobalKey<SideMenuState>();
  bool _isMenuOpen = false;

  Future<void> _search() async {
    setState(() {
      _loading = true;
      _error = null;
      _results = [];
    });

    try {
      final data = await _api.searchProducts(_controller.text.trim());
      if (!mounted) return;
      setState(() => _results = data);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _toggleMenu() {
    _menuKey.currentState?.toggle();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _search,
        backgroundColor: Colors.deepOrangeAccent.shade200,
        icon: const Icon(Icons.search),
        label: Text(loc.search),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: kToolbarHeight + MediaQuery.of(context).padding.top,
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF10CA2C),
                      Color(0xFF32D272),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _isMenuOpen ? Icons.close_rounded : Icons.menu_rounded,
                        color: Colors.white,
                      ),
                      onPressed: _toggleMenu,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      loc.product_search,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            loc.api,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          DropdownButton<String>(
                            value: _selectedApi,
                            items: _apis.keys
                                .map((name) => DropdownMenuItem(
                              value: name,
                              child: Text(name),
                            ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedApi = value;
                                  _api = _apis[value]!;
                                  _results = [];
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          labelText: loc.product_search,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => _controller.clear(),
                          ),
                        ),
                        onSubmitted: (_) => _search(),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _loading
                            ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.deepOrangeAccent,
                          ),
                        )
                            : _error != null
                            ? Center(child: Text(_error!))
                            : _results.isEmpty
                            ? Center(child: Text(loc.no_results))
                            : ListView.builder(
                          itemCount: _results.length,
                          itemBuilder: (context, index) {
                            final item = _results[index];
                            final productName =
                                item['product_name'] ?? 'Unnamed product';
                            final brand = item['brand_name'] ?? '';
                            final price = item['Price'] != null
                                ? '${item['Price']} ${item['product_currency'] ?? ''}'
                                : 'Price not available';
                            final description = item['ingredients'] ?? '';

                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 3,
                              margin:
                              const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: const CircleAvatar(
                                  backgroundColor: Colors.deepOrangeAccent,
                                  child: Icon(Icons.shopping_cart,
                                      color: Colors.white),
                                ),
                                title: Text(
                                  productName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (brand.isNotEmpty)
                                      Text(
                                        brand,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    if (price.isNotEmpty)
                                      Padding(
                                        padding:
                                        const EdgeInsets.only(top: 4.0),
                                        child: Text(
                                          price,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green),
                                        ),
                                      ),
                                    if (description.isNotEmpty)
                                      Padding(
                                        padding:
                                        const EdgeInsets.only(top: 4.0),
                                        child: Text(
                                          description,
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ProductDetailPagetest(
                                            product: item,
                                          ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SideMenu(key: _menuKey, currentRoute: '/product-search', onOpenChanged: (isOpen) => setState(() => _isMenuOpen = isOpen),),
        ],
      ),
    );
  }
}
