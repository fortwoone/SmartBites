import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../l10n/app_localizations.dart';
import '../../utils/color_constants.dart';
import '../../viewmodels/product_search_viewmodel.dart';
import '../../viewmodels/history_viewmodel.dart';
import '../../widgets/product/product_search_item.dart';
import 'product_detail_page.dart';

class ProductSearchPage extends ConsumerStatefulWidget {
  final bool inAddMode;
  const ProductSearchPage({super.key, this.inAddMode = false});

  @override
  ConsumerState<ProductSearchPage> createState() => _ProductSearchPageState();
}

class _ProductSearchPageState extends ConsumerState<ProductSearchPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
       ref.read(productSearchViewModelProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _performSearch() {
     ref.read(productSearchViewModelProvider.notifier).search(_searchCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final searchAsync = ref.watch(productSearchViewModelProvider);
    final notifier = ref.read(productSearchViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Off-white background
      appBar: AppBar(
        title: Text(loc.search_product, style: GoogleFonts.recursive(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchCtrl,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: loc.hint_product_example,
                prefixIcon: const Icon(Icons.search, color:  AppColors.primary),
                suffixIcon: IconButton(
                   icon: const Icon(Icons.clear), 
                   onPressed: () {
                      _searchCtrl.clear();
                      notifier.clear();
                   },
                ),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
              onSubmitted: (_) => _performSearch(),
            ),
          ),
        ),
      ),
      body: searchAsync.when(
        data: (products) {
          if (products.isEmpty && _searchCtrl.text.isNotEmpty) {
             return Center(child: Text(loc.no_results_now, style: GoogleFonts.recursive(color: Colors.grey)));
          } else if (products.isEmpty) {
             return Center(child: Column(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 Icon(Icons.search, size: 80, color: Colors.grey[300]),
                 Text("Recherchez un produit...", style: GoogleFonts.recursive(color: Colors.grey))
               ],
             ));
          }
          
          return ListView.builder(
            controller: _scrollCtrl,
            padding: const EdgeInsets.all(16),
            itemCount: products.length + (notifier.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == products.length) {
                 return notifier.isLoadingMore 
                    ? const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()))
                    : const SizedBox(height: 50); // Spacer or manual load more
              }
              final product = products[index];
              return ProductSearchItem(
                product: product,
                onTap: () {
                   // Save to history
                   ref.read(historyViewModelProvider.notifier).addToHistory(product);
                   
                   if (widget.inAddMode) {
                      Navigator.pop(context, product);
                   } else {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailPage(product: product)));
                   }
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text("${loc.error}: $e")),
      ),
    );
  }
}
