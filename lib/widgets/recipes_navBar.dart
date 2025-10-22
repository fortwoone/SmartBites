// dart
// File: `lib/pages/recipes_navBar.dart`
import 'package:flutter/material.dart';
import 'package:food/l10n/app_localizations_en.dart';
import '../l10n/app_localizations.dart';
import 'app_nav_bar.dart';
import '../main.dart';

class MyApp extends StatelessWidget {

  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (ctx) => const NextPage(),
        '/next': (ctx) => const HomeScreen(),
      },
    );
  }
}

class NextPage extends StatefulWidget {
  const NextPage({super.key});
  @override
  State<NextPage> createState() => _HomeScreenState();

}
  class _HomeScreenState extends State<NextPage> {
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
        title: AppLocalizations.of(context)!.recipes,
        showSearch: true,
        onSearchChanged: _onSearchChanged,
        onSearchSubmitted: _onSearchSubmitted,
        showSquareButtons: true,
        backgroundColor: Colors.red,
        rightRoute: '/next', // pass the route name — simple setup
        leftRoute: '/',
      ),
      body: Center(
        child: Text('Search value: $_query'),
      ),
    );
  }
}
