import 'package:flutter/material.dart';
import 'package:SmartBites/db_objects/recipe.dart';
import 'package:SmartBites/screens/view_recipe_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../l10n/app_localizations.dart';
import '../widgets/app_nav_bar.dart';
import '../widgets/side_menu.dart';

class RecipesSearchScreen extends StatefulWidget {
    const RecipesSearchScreen({super.key});

    @override
    State<RecipesSearchScreen> createState() => _RecipesSearchScreenState();
}

class _RecipesSearchScreenState extends State<RecipesSearchScreen> {
    final supabase = Supabase.instance.client;
    List<Recipe> _recipes = [];
    bool _loading = false;
    String? _error = null;

    @override
    void initState() {
        super.initState();
        _search();
    }


    Future<void> _search([String? query]) async {
        final q = (query ?? "").trim();

        setState(() {
            _loading = true;
            _error = null;
            _recipes = [];
        });

        try {
            final request = supabase.from("Recettes").select();

            final results = q.isEmpty
                ? await request
                : await request.ilike("name", "%$q%");

            setState(() {
                _recipes = results
                    .map<Recipe>((r) => Recipe.fromMap(r))
                    .toList();
            });
        } catch (e) {
            setState(() => _error = e.toString());
        } finally {
            setState(() => _loading = false);
        }
    }


    void _onSearchSubmitted(String q) {
        _search(q);
    }

    @override
    Widget build(BuildContext context) {
        final loc = AppLocalizations.of(context)!;

        return Scaffold(
            body: Stack(
                children: [
                    Scaffold(
                        appBar: AppNavBar(
                            title: loc.recipes,
                            showSearch: true,
                            onSearchSubmitted: _onSearchSubmitted,
                            showSquareButtons: true,
                            backgroundColor: Colors.red,
                            rightRoute: '/next',
                            leftRoute: '/home',
                        ),
                        body: Center(
                            child: Column(
                                children: [
                                    const SizedBox(height: 12),
                                    if (_loading) const CircularProgressIndicator(),
                                    if (_error != null)
                                        Text(_error!, style: const TextStyle(color: Colors.red)),
                                    if (!_loading && _error == null)
                                        Expanded(
                                            child: _recipes.isEmpty
                                                ? const Center(child: Text("Pas de résultats"))
                                                : ListView.builder(
                                                itemCount: _recipes.length,
                                                itemBuilder: (context, index) {
                                                    final r = _recipes[index];
                                                    return Card(
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(16)),
                                                        elevation: 3,
                                                        margin: const EdgeInsets.symmetric(vertical: 8),
                                                        child: ListTile(
                                                            contentPadding: const EdgeInsets.all(16),
                                                            leading: const CircleAvatar(
                                                                radius: 28,
                                                                backgroundColor: Colors.deepOrangeAccent,
                                                                child: Icon(Icons.restaurant_menu,
                                                                    color: Colors.white, size: 28),
                                                            ),
                                                            title: Text(
                                                                r.name,
                                                                style: const TextStyle(
                                                                    fontWeight: FontWeight.bold,
                                                                    fontSize: 18),
                                                            ),
                                                            subtitle: Text(
                                                                r.description ?? "",
                                                                maxLines: 2,
                                                                overflow: TextOverflow.ellipsis,
                                                            ),
                                                            onTap: () {
                                                                Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder: (_) =>
                                                                            ViewRecipePage(recipe: r.toMap()),
                                                                    ),
                                                                );
                                                            },
                                                        ),
                                                    );
                                                },
                                            ),
                                        ),
                                ],
                            ),
                        ),
                    ),

                    const SideMenu(currentRoute: '/next'),
                ],
            ),
        );

    }
}
