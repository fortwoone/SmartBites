import 'package:flutter/material.dart';
import '../widgets/side_menu.dart'; // Adjust path to your project

class ProductDetailPagetest extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailPagetest({super.key, required this.product});

  @override
  State<ProductDetailPagetest> createState() => _ProductDetailPagetestState();
}

class _ProductDetailPagetestState extends State<ProductDetailPagetest> {
  final GlobalKey<SideMenuState> _menuKey = GlobalKey<SideMenuState>();
  bool _isMenuOpen = false;

  void _toggleMenu() {
    _menuKey.currentState?.toggle();
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.product['product_name'] ?? 'Unnamed product';
    final brand = widget.product['brand_name'] ?? '';
    final price = widget.product['Price'] != null
        ? '${widget.product['Price']} ${widget.product['product_currency'] ?? ''}'
        : 'Price not available';
    final description = widget.product['product_ingredients'] ?? '';
    final productUrl = widget.product['product_link'] ?? '';

    return Scaffold(
      body: Stack(
        children: [
          // Main page content
          Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(_isMenuOpen ? Icons.close_rounded : Icons.menu_rounded),
                onPressed: _toggleMenu,
              ),
              title: Text(name),
              backgroundColor: Colors.deepOrangeAccent.shade100,
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  if (brand.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text('Brand: $brand', style: const TextStyle(fontSize: 16)),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text('Price: $price', style: const TextStyle(fontSize: 16, color: Colors.green)),
                  ),
                  if (description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Text(description, style: const TextStyle(fontSize: 16)),
                    ),
                  if (productUrl.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: GestureDetector(
                        onTap: () {
                          // TODO: Use url_launcher to open URL
                        },
                        child: Text(
                          'View product online',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            decoration: TextDecoration.underline,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),


            floatingActionButton: FloatingActionButton(
              onPressed: () {

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Floating button pressed!')),
                );
              },
              backgroundColor: Colors.deepOrangeAccent.shade100,
              child: const Icon(Icons.add),
            ),
          ),

          // Side menu overlay
          SideMenu(
            key: _menuKey,
            currentRoute: '/product_detail', // adjust as needed
            onOpenChanged: (isOpen) {
              setState(() => _isMenuOpen = isOpen);
            },
          ),
        ],
      ),
    );
  }
}
