import 'package:SmartBites/screens/api_search_test_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:SmartBites/screens/product_detail_screen.dart';
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
import 'package:SmartBites/widgets/recent_products_widget.dart';

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
    List<Product> _results = [];
    bool _loading = false;
    String? _error;
    bool _isMenuOpen = false;
    Future<void> _search([String? query]) async {
        final q = (query ?? '').trim();
        if (q.isEmpty) {
            setState(() => _error = 'Veuillez entrer un nom de produit.');
            return;
        }

        setState(() {
            _loading = true;
            _error = null;
            _results = [];
        });

        try {
            final results = await widget.repository.fetchProductsByName(q);
            setState(() => _results = results);
        } catch (e) {
            setState(() => _error = e.toString());
        } finally {
            setState(() => _loading = false);
        }
    }
    void _onSearchSubmitted(String q) => _search(q);

    void _toggleMenu() {
        _sideMenuKey.currentState?.toggle();
    }

    String _titleFor(Product p) => p.name ?? p.brands ?? 'Produit inconnu';

    @override
    Widget build(BuildContext context) {
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
                    });
                },
            ),
          body: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  if (!_loading && _results.isEmpty)
                    const RecentProductsWidget(),

                  if (_loading)
                    const Center(child: CircularProgressIndicator()),

                  if (_error != null)
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),

                  Expanded(
                    child: _results.isEmpty
                        ? const Center(
                      child: Text('Recherchez un produit pour commencer'),
                    )
                        : ListView.separated(
                      itemCount: _results.length,
                      separatorBuilder: (_, __) =>
                      const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final p = _results[index];
                        return ListTile(
                          leading: p.imageURL != null
                              ? Image.network(
                            p.imageURL!,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                          )
                              : const SizedBox(
                            width: 56,
                            height: 56,
                          ),
                          title: Text(_titleFor(p)),
                          subtitle: Text(p.brands ?? ''),
                          onTap: () {
                            final code = p.barcode;
                            if (code.isEmpty) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Pas de code-barres disponible',
                                  ),
                                ),
                              );
                              return;
                            }
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ProductDetailPage(
                                  barcode: code,
                                  repository: widget.repository,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              SideMenu(
                key: _sideMenuKey,
                currentRoute: '/home',
                onOpenChanged: (isOpen) {
                  setState(() => _isMenuOpen = isOpen);
                },
              ),
            ],
          ),

        );
    }
}

