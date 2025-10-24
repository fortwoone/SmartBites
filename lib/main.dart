import 'package:flutter/material.dart';
import 'package:food/widgets/bottom_action_bar.dart';
import 'repositories/openfoodfacts_repository.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:food/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/login_screen.dart';
import 'widgets/app_nav_bar.dart';
import 'screens/recipes_search_screen.dart';
import 'screens/shopping_list.dart';

Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();

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
                useMaterial3: true,
            ),
            debugShowCheckedModeBanner: false,

            // 👇 ajoute la route manquante
            initialRoute: initialRoute,
            routes: {
                '/login': (ctx) => const LoginScreen(),
                '/home': (ctx) => HomeScreen(),
                '/next': (ctx) => const RecipesSearchScreen(),
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
                child: Text('Search value: $_query'),
            ),
            bottomNavigationBar: const BottomActionBar(),
        );
    }
}
