import 'package:flutter/material.dart';
import 'package:food/screens/view_recipe_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../l10n/app_localizations.dart';
import '../widgets/bottom_action_bar.dart';
import 'add_recipe_page.dart';

class RecipeListPage extends StatefulWidget {
    const RecipeListPage({Key? key}) : super(key: key);

    @override
    State<RecipeListPage> createState() => _RecipeListPageState();
}

class _RecipeListPageState extends State<RecipeListPage> {
    bool _showOnlyMine = false;
    bool _loading = false;
    List<Map<String, dynamic>> _recipes = [];

    final supabase = Supabase.instance.client;

    @override
    void initState() {
        super.initState();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _fetchRecipes();
        });
    }

    Future<void> _fetchRecipes() async {
        setState(() => _loading = true);
        final user = supabase.auth.currentUser;

        try {
            var query = supabase.from('Recettes').select();

            if (_showOnlyMine && user != null) {
                query = query.eq('user_id_creator', user.id);
            }

            final data = await query.order('created_at', ascending: false);

            if (!mounted) return;
            setState(() => _recipes = List<Map<String, dynamic>>.from(data));
        } catch (e) {
            if (!mounted) return;
            final loc = AppLocalizations.of(context)!;
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(loc.error)));
        } finally {
           if (mounted) setState(() => _loading = false);
        }
    }

    void _toggleFilter() {
        setState(() => _showOnlyMine = !_showOnlyMine);
        _fetchRecipes();
    }

    Future<void> _openRecipeEditor(Map<String, dynamic> recipe) async {
        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddRecipePage(
                  key: ValueKey(recipe['id']),
                  recipeToEdit: recipe,
                ),
            ),
        );
      _fetchRecipes();
    }

    Future<void> _deleteRecipe(Map<String, dynamic> recipe) async {
      final loc = AppLocalizations.of(context)!;


      final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
              title: Text(loc.deleteRecipeConfirm),
              content: Text(loc.deleteRecipeConfirm),
              actions: [
                  TextButton(onPressed: () => Navigator.pop(context, false), child:  Text(loc.cancel)),
                  ElevatedButton(onPressed: () => Navigator.pop(context, true), child:  Text(loc.delete)),
              ],
          ),
      );


    if (confirmed != true) return;

    setState(() => _loading = true);

    try {
    final id = int.tryParse(recipe['id'].toString());

    if (id == null) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(loc.invalidID)));
    return;
    }

    await supabase.from('Recettes').delete().eq('id', id);

    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar( SnackBar(content: Text(loc.recipeDeleted)));
    _fetchRecipes();
    } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(loc.error)));
    } finally {
    if (mounted) setState(() => _loading = false);
    }


  }

  @override
  Widget build(BuildContext context) {
      final userId = supabase.auth.currentUser?.id;
      final loc = AppLocalizations.of(context)!;


      return Scaffold(
        appBar: AppBar(
          title: Text(_showOnlyMine ? loc.myRecipes : loc.recipes, style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.deepOrangeAccent.shade100,
          elevation: 0,
          actions: [
              IconButton(
                  icon: Icon(_showOnlyMine ? Icons.person : Icons.people_alt_outlined),
                  tooltip: _showOnlyMine ? loc.allRecipes : loc.showMyRecipes,
                  onPressed: _toggleFilter,
              ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddRecipePage()));
                _fetchRecipes();
            },
            backgroundColor: Colors.deepOrangeAccent.shade200,
            child: const Icon(Icons.add, size: 30),
        ),
        body: _loading
        ? const Center(child: CircularProgressIndicator(color: Colors.deepOrangeAccent))
            : _recipes.isEmpty
        ? Center(child: Text(loc.noRecipeFound))
            : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _recipes.length,
        itemBuilder: (context, index) {
        final recipe = _recipes[index];
        final isMine = recipe['user_id_creator'] == userId;
        final description = (recipe['description'] ?? '').toString();

        return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: const CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.deepOrangeAccent,
                      child: Icon(Icons.restaurant_menu, color: Colors.white, size: 28),
                  ),
                  title: Text(recipe['name'] ?? 'Sans titre',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (recipe['creator_name'] != null && recipe['creator_name'].toString().isNotEmpty)
                          Text(
                            '${loc.createdBy}: ${recipe['creator_name']}',
                            style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.black54),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  trailing: isMine
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                          children: [
                          IconButton(
                              icon: const Icon(Icons.edit_outlined, color: Colors.deepOrangeAccent),
                              onPressed: () => _openRecipeEditor(recipe)),
                          IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              onPressed: () => _deleteRecipe(recipe)),
                      ],
                  )
                      : null,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewRecipePage(recipe: recipe),
                      ),
                    );
                  },


                ),
        );
        },
        ),
        bottomNavigationBar: const BottomActionBar(currentRoute: '/recipe',),

      );

  }
}
