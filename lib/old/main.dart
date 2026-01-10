import 'package:SmartBites/screens/api_search_test_page.dart';
import 'package:SmartBites/widgets/recent_shopping_lists_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:SmartBites/screens/product_detail_page.dart';
import 'package:SmartBites/screens/recipes_list.dart';
import 'package:SmartBites/widgets/side_menu.dart';
import '../models/product.dart';
import '../repositories/openfoodfacts_repository.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:SmartBites/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import '../screens/auth/login_screen.dart';
import '../widgets/app_nav_bar.dart';
import '../screens/recipes_search_screen.dart';
import '../screens/shopping_list.dart';
import '../screens/profile_screen.dart';
import '../utils/color_constants.dart';
import '../widgets/recent_products_widget.dart';
import '../widgets/recent_recipes_widget.dart';
import '../widgets/shopping_list/product_search_item.dart';
import '../widgets/product_skeleton.dart';
import '../widgets/error_retry_widget.dart';
import '../utils/local_cache_service.dart';

Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();

    await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
    ]);

    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Paris'));

    await Supabase.initialize(
        url: 'https://ftuijeorywnqjgmqbcfk.supabase.co',
        anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ0dWlqZW9yeXducWpnbXFiY2ZrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA5MDQ4MDcsImV4cCI6MjA3NjQ4MDgwN30._iADlHpMD_9_5Y_tUnuaayvPwBEW2Dqg4osxUo7ox9U',
    );

    await LocalCacheService.getInstance();

    final session = Supabase.instance.client.auth.currentSession;

    runApp(MyApp(

        initialRoute: session != null ? '/home' : '/login',
    ));
}

class MyApp extends StatelessWidget {
    final String initialRoute;

    const MyApp({super.key, required this.initialRoute});

    @override
    Widget build(BuildContext context) {

        return MaterialApp(
            title: 'SmartBites',
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
            ],
            theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            ),
            debugShowCheckedModeBanner: false,

            initialRoute: initialRoute,
            routes: {
                '/home': (ctx) =>  HomeScreen(),
                '/login': (ctx) => const LoginScreen(),
                '/profile': (ctx) => const ProfileScreen(),
                '/next': (ctx) => const RecipesSearchScreen(),
                '/recipe': (ctx) => const RecipeListPage(),
                '/testapis': (ctx) => const ProductSearchPage(),
                '/shopping': (ctx) {
                    final session = Supabase.instance.client.auth.currentSession;
                    if (session == null) {
                        return const LoginScreen();
                    }
                    return ShoppingListMenu(session: session);
                },
            },
        );
    }
}

class HomeScreen extends StatefulWidget {
    final OpenFoodFactsRepository repository;

    HomeScreen({super.key, OpenFoodFactsRepository? repository})
        : repository = repository ?? OpenFoodFactsRepository();


    @override
    State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
    final GlobalKey<SideMenuState> _sideMenuKey = GlobalKey<SideMenuState>();
    late final loc = AppLocalizations.of(context)!;

    List<Product> _results = [];
    bool _loading = false;
    bool _loadingMore = false;
    String? _error;
    bool _isMenuOpen = false;
    String _currentQuery = '';
    int _currentPage = 1;
    bool _hasMore = true;

    Future<void> _search([String? query]) async {
        final q = (query ?? _currentQuery).trim();
        if (q.isEmpty) {
            setState(() => _error = loc.enter_product_name);
            return;
        }

        setState(() {
            _loading = true;
            _error = null;
            _results = [];
            _currentQuery = q;
            _currentPage = 1;
            _hasMore = true;
        });

        try {
            final results = await widget.repository.fetchProductsByName(q, page: 1);
            
            final barcodes = results.map((p) => p.barcode).toList();
            await widget.repository.preloadPrices(barcodes);

            _hasMore = results.length >= 50;
            setState(() => _results = results);
        } catch (e) {
            setState(() => _error = 'error');
        } finally {
            setState(() => _loading = false);
        }
    }

    Future<void> _loadMore() async {
        if (_loadingMore || !_hasMore) return;

        setState(() => _loadingMore = true);

        try {
            final nextPage = _currentPage + 1;
            final results = await widget.repository.fetchProductsByName(_currentQuery, page: nextPage);
            
            final barcodes = results.map((p) => p.barcode).toList();
            await widget.repository.preloadPrices(barcodes);

            _hasMore = results.length >= 50;
            _currentPage = nextPage;
            setState(() => _results.addAll(results));
        } catch (_) {
        } finally {
            setState(() => _loadingMore = false);
        }
    }

    Future<void> _refresh() async {
        widget.repository.clearCache();
        await _search(_currentQuery);
    }

    void _onSearchSubmitted(String q) => _search(q);

    void _toggleMenu() {
        _sideMenuKey.currentState?.toggle();
    }

    @override
    Widget build(BuildContext context) {
      bool isSearching = _loading || _results.isNotEmpty || _error != null;

      return Scaffold(
        appBar: AppNavBar(
          title: AppLocalizations.of(context)!.products,
          showSearch: true,
          onSearchSubmitted: _onSearchSubmitted,
          showSquareButtons: true,
          backgroundColor: primaryPeach,
          rightRoute: '/next',
          onMenuPressed: _toggleMenu,
          isMenuOpen: _isMenuOpen,
          onSearchClosed: () {
            setState(() {
              _results = [];
              _error = null;
              _currentQuery = '';
            });
          },
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: isSearching
                      ? _buildSearchResultsView()
                      : _buildDashboardView(),
                ),
              ],
            ),
            SideMenu(
              key: _sideMenuKey,
              currentRoute: '/home',
              onOpenChanged: (isOpen) => setState(() => _isMenuOpen = isOpen),
            ),
          ],
        ),
      );
    }

  Widget _buildDashboardView() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SizedBox(height: 12),
          RecentProductsWidget(),
          SizedBox(height: 16),
          RecentRecipesWidget(),
          SizedBox(height: 16),
          RecentShoppingListsWidget(),
          SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSearchResultsView() {
    if (_loading) {
      return const ProductSkeletonList();
    }

    if (_error != null) {
      return SearchErrorWidget(onRetry: () => _search(_currentQuery));
    }

    return RefreshIndicator(
      color: primaryPeach,
      onRefresh: _refresh,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 10, left: 16, right: 16),
        itemCount: _results.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _results.length) {
            return _buildLoadMoreButton();
          }
          final p = _results[index];
          return ProductSearchItem(
            product: p,
            repository: widget.repository,
            onTap: () async {
              if (p.barcode.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(loc.no_barcode_available)),
                );
                return;
              }
              final cacheService = await LocalCacheService.getInstance();
              await cacheService.saveRecentProduct(p);
              if (!context.mounted) return;
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProductDetailPage(barcode: p.barcode, repository: widget.repository),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: _loadingMore
            ? const CircularProgressIndicator(color: primaryPeach)
            : TextButton.icon(
                onPressed: _loadMore,
                icon: const Icon(Icons.add_circle_outline, color: primaryPeach),
                label: Text(
                  'Charger plus',
                  style: TextStyle(color: primaryPeach, fontWeight: FontWeight.w600),
                ),
              ),
      ),
    );
  }
}
