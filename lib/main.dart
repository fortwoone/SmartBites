import 'package:SmartBites/screens/product_search_page.dart';
import 'package:SmartBites/widgets/recent_shopping_lists_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:SmartBites/screens/product_detail_page.dart';
import 'package:SmartBites/screens/recipes_list.dart';
import 'package:SmartBites/widgets/side_menu.dart';
import 'models/product.dart';
import 'repositories/openfoodfacts_repository.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:SmartBites/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'screens/auth/login_screen.dart';
import 'widgets/app_nav_bar.dart';
import 'screens/recipes_search_screen.dart';
import 'screens/shopping_list.dart';
import 'screens/profile_screen.dart';
import 'utils/color_constants.dart';
import 'widgets/recent_products_widget.dart';
import 'widgets/recent_recipes_widget.dart';
import 'widgets/shopping_list/product_search_item.dart';

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
                '/products': (ctx) => ProductSearchPage(),
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
  String? _error;
  bool _isMenuOpen = false;

  // --- FILTER VARIABLES ---
  String? _selectedNutriscore;
  String? _selectedNova;
  String? _selectedBrand;
  double? _maxCalories;
  String? _ingredientContains;
  String _lastQuery = "";


  Future<void> _search([String? query]) async {
    final q = (query ?? '').trim();
    if (q.isEmpty) {
      _lastQuery = q;
      setState(() => _error = loc.enter_product_name);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _results = [];
    });

    try {
      final results = await widget.repository.fetchProductsByName(q);
      final barcodes = results.map((p) => p.barcode).toList();
      await widget.repository.preloadPrices(barcodes);

      // --- APPLY FILTERING BEFORE DISPLAY ---
      final filtered = results.where((p) {

        if (_selectedNutriscore != null && p.nutriscoreGrade?.toLowerCase() != _selectedNutriscore) {
          return false;
        }

        if (_selectedNova != null && p.novaGroup != _selectedNova) return false;

        if (_selectedBrand != null && !(p.brands ?? '').toLowerCase().contains(_selectedBrand!)) {
          return false;
        }

        if (_ingredientContains != null && !(p.ingredientsText ?? '').toLowerCase().contains(_ingredientContains!)) {
          return false;
        }

        if (_maxCalories != null) {
          final kcal = p.nutriments?['energy-kcal_100g']?.toDouble();
          if (kcal == null || kcal > _maxCalories!) return false;
        }

        return true;
      }).toList();

      setState(() => _results = filtered);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  void _toggleMenu() {
    _sideMenuKey.currentState?.toggle();
  }

  void _searchAgain() => _search(_lastQuery);

  @override
  Widget build(BuildContext context) {
    bool isSearching = _loading || _results.isNotEmpty;

    return Scaffold(
      appBar: AppNavBar(
        title: AppLocalizations.of(context)!.products,
        showSearch: true,
        onSearchSubmitted: _search,
        showSquareButtons: true,
        backgroundColor: primaryPeach,
        rightRoute: '/next',
        onMenuPressed: _toggleMenu,
        isMenuOpen: _isMenuOpen,
        onSearchClosed: () {
          setState(() {
            _results = [];
            _error = null;
          });
        },
      ),
      body: Stack(
        children: [
          Column(
            children: [
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(_error!, style: const TextStyle(color: Colors.red)),
                ),
              Expanded(
                child: isSearching ? _buildSearchResultsView() : _buildDashboardView(),
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
    final loc = AppLocalizations.of(context)!;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // --- FILTER UI BAR ---
        if (_results.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Nutriscore dropdown
                  SizedBox(
                    width: 120,
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: const Text("Nutriscore"),
                      value: _selectedNutriscore,
                      items: ["a", "b", "c", "d", "e"]
                          .map((g) =>
                          DropdownMenuItem(value: g, child: Text(g.toUpperCase())))
                          .toList(),
                      onChanged: (v) => setState(() {
                        _selectedNutriscore = v;
                        _searchAgain();
                      }),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // NOVA dropdown
                  SizedBox(
                    width: 120,
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: const Text("NOVA"),
                      value: _selectedNova,
                      items: ["1", "2", "3", "4"]
                          .map((n) => DropdownMenuItem(value: n, child: Text("Group $n")))
                          .toList(),
                      onChanged: (v) => setState(() {
                        _selectedNova = v;
                        _searchAgain();
                      }),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Brand dropdown
                  SizedBox(
                    width: 150,
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: Text(loc.brandOnly),
                      value: _selectedBrand,
                      items: _results
                          .map((p) => (p.brands ?? "").toLowerCase())
                          .toSet()
                          .where((b) => b.isNotEmpty)
                          .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                          .toList(),
                      onChanged: (v) => setState(() {
                        _selectedBrand = v;
                        _searchAgain();
                      }),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Max kcal text field
                  SizedBox(
                    width: 120,
                    child: TextField(
                      decoration: const InputDecoration(hintText: "Max kcal"),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => setState(() {
                        _maxCalories = double.tryParse(v);
                        _searchAgain();
                      }),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Ingredient text field
                  SizedBox(
                    width: 150,
                    child: TextField(
                      decoration: const InputDecoration(hintText: "Ingredient"),
                      onChanged: (v) => setState(() {
                        _ingredientContains = v.toLowerCase();
                        _searchAgain();
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // --- RESULTS LIST ---
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 10, left: 16, right: 16),
            itemCount: _results.length,
            itemBuilder: (context, index) {
              final p = _results[index];
              return ProductSearchItem(
                product: p,
                repository: widget.repository,
                onTap: () {
                  if (p.barcode.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(loc.no_barcode_available)),
                    );
                    return;
                  }
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProductDetailPage(
                          barcode: p.barcode, repository: widget.repository),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );


  }

}
