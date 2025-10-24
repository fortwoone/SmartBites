import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../widgets/app_nav_bar.dart';
import '../widgets/bottom_action_bar.dart';

class RecipesSearchScreen extends StatefulWidget {
    const RecipesSearchScreen({super.key});

    @override
    State<RecipesSearchScreen> createState() => _RecipesSearchScreenState();
}

class _RecipesSearchScreenState extends State<RecipesSearchScreen> {
    String _query = '';

    void _onSearchChanged(String q) {
        setState(() => _query = q);
    }

    void _onSearchSubmitted(String q) {
        debugPrint('Search submitted: $q');
    }

    @override
    Widget build(BuildContext context) {
        final loc = AppLocalizations.of(context)!;

        return Scaffold(
            appBar: AppNavBar(
                title: loc.recipes,
                showSearch: true,
                onSearchChanged: _onSearchChanged,
                onSearchSubmitted: _onSearchSubmitted,
                showSquareButtons: true,
                backgroundColor: Colors.red,
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
