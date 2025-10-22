import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:food/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'widgets/app_nav_bar.dart';
import 'screens/login_screen.dart';

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
      home: const LoginScreen(),  // Login is the main screen
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (ctx) => const HomeScreen(),
        '/next': (ctx) => const NextPage(),
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

  void _onSearchChanged(String q) {
    setState(() => _query = q);
  }

  void _onSearchSubmitted(String q) {
    debugPrint('Search submitted: $q');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppNavBar(
        title: 'Products',
        showSearch: true,
        onSearchChanged: _onSearchChanged,
        onSearchSubmitted: _onSearchSubmitted,
        showSquareButtons: true,
        backgroundColor: Colors.green,
        rightRoute: '/next',
        leftRoute: '/',// pass the route name — simple setup
      ),
      body: Center(
        child: Text('Search value: $_query'),
      ),
    );
  }
}
