//dart
import 'package:flutter/material.dart';
import 'pages/product_search_page.dart';
import 'repositories/openfoodfacts_repository.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:food/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/login_screen.dart';
import 'widgets/app_nav_bar.dart';
import 'widgets/recipes_navBar.dart';
import 'screens/shopping_list.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ftuijeorywnqjgmqbcfk.supabase.co',
    anonKey:
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ0dWlqZW9yeXducWpnbXFiY2ZrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA5MDQ4MDcsImV4cCI6MjA3NjQ4MDgwN30._iADlHpMD_9_5Y_tUnuaayvPwBEW2Dqg4osxUo7ox9U',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = OpenFoodFactsRepository();
    return MaterialApp(
      title: 'SmartBites',
      locale: const Locale('fr'),
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
      initialRoute: '/login',
      routes: {
        '/login': (ctx) => const LoginScreen(),
        '/home': (ctx) => const HomeScreen(),
        '/next': (ctx) => const NextPage(),
        '/shopping': (ctx) {
          final session = Supabase.instance.client.auth.currentSession;
          if (session == null) {
            // Si pas connecté, retour login
            return const LoginScreen();
          }
          return ShoppingListMenu(session: session);
        },
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _query = '';

  void _onSearchChanged(String q) => setState(() => _query = q);
  void _onSearchSubmitted(String q) => debugPrint('Search submitted: $q');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppNavBar(
        title: AppLocalizations.of(context)!.products,
        showSearch: true,
        onSearchChanged: _onSearchChanged,
        onSearchSubmitted: _onSearchSubmitted,
        showSquareButtons: true,
        backgroundColor: Colors.green,
        rightRoute: '/next',
        leftRoute: '/home',
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Search value: $_query'),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.shopping_cart),
              label: const Text('Voir ma liste de courses'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/shopping');
              },
            ),
          ],
        ),
      ),
    );
  }
}
