import 'package:flutter/material.dart';
import 'package:SmartBites/screens/view_recipe_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../l10n/app_localizations.dart';
import '../widgets/side_menu.dart';
import 'add_recipe_page.dart';

class RecipeListPage extends StatefulWidget {
    const RecipeListPage({Key? key}) : super(key: key);

    @override
    State<RecipeListPage> createState() => _RecipeListPageState();
}

enum _RecipeMenuAction {
  edit,
  delete,
}


class _RecipeListPageState extends State<RecipeListPage> {
    bool _showOnlyMine = false;
    bool _loading = false;
    List<Map<String, dynamic>> _recipes = [];
    final GlobalKey<SideMenuState> _menuKey = GlobalKey<SideMenuState>();
    bool _isMenuOpen = false;

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

    void _toggleMenu() {
        _menuKey.currentState?.toggle();
    }

    Widget _buildSquareButton({
      required Color color,
      required Widget child,
      required VoidCallback onPressed,
    }) {
      return Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(26),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: child,
            ),
          ),
        ),
      );
    }

    void _openRecipeDetail(Map<String, dynamic> recipe) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ViewRecipePage(recipe: recipe),
        ),
      );
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
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddRecipePage()),
            );
            _fetchRecipes();
          },
          backgroundColor: Colors.deepOrangeAccent.shade200,
          icon: const Icon(Icons.add, size: 30),
          label: Text(loc.addRecipe),
        ),

        body: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight + 10),
            child: AppBar(
              backgroundColor: Colors.deepOrangeAccent.shade100,
              elevation: 0,
              leading: Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: _buildSquareButton(
                    color: Colors.transparent,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return RotationTransition(
                          turns: Tween(begin: 0.5, end: 1.0).animate(animation),
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                      child: Icon(
                        _isMenuOpen ? Icons.close_rounded : Icons.menu_rounded,
                        key: ValueKey(_isMenuOpen),
                        color: Colors.black87,
                      ),
                    ),
                    onPressed: _toggleMenu,
                  ),
                ),
              ),
              leadingWidth: 80,
              titleSpacing: 16,
              centerTitle: false,
              title: Text(
                _showOnlyMine ? loc.myRecipes : loc.recipes,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              actions: [
                IconButton(
                  icon: Icon(_showOnlyMine ? Icons.person : Icons.people_alt_outlined),
                  tooltip: _showOnlyMine ? loc.allRecipes : loc.showMyRecipes,
                  onPressed: _toggleFilter,
                ),
              ],
            ),
          ),

          body: Stack(
            children: [
              _loading
                  ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.deepOrangeAccent,
                ),
              )
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: const CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.deepOrangeAccent,
                        child: Icon(
                          Icons.restaurant_menu,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      title: Text(
                        recipe['name'] ?? 'Sans titre',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (recipe['creator_name'] != null &&
                                recipe['creator_name'].toString().isNotEmpty)
                              Text(
                                '${loc.createdBy}: ${recipe['creator_name']}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.black54,
                                ),
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
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isMine)
                            PopupMenuButton<_RecipeMenuAction>(
                              icon: const Icon(Icons.more_vert),
                              onSelected: (action) {
                                if (action == _RecipeMenuAction.edit) {
                                  _openRecipeEditor(recipe);
                                } else {
                                  _deleteRecipe(recipe);
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: _RecipeMenuAction.edit,
                                  child: Row(
                                    children: [
                                      const Icon(Icons.edit,
                                          size: 18, color: Colors.green),
                                      const SizedBox(width: 8),
                                      Text(loc.update),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: _RecipeMenuAction.delete,
                                  child: Row(
                                    children: [
                                      const Icon(Icons.delete,
                                          size: 18,
                                          color: Colors.redAccent),
                                      const SizedBox(width: 8),
                                      Text(loc.delete),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          IconButton(
                            tooltip: loc.viewRecipe,
                            iconSize: 35,
                            icon: const Icon(
                              Icons.arrow_circle_right,
                              color: Colors.deepOrangeAccent,
                            ),
                            onPressed: () => _openRecipeDetail(recipe),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              SideMenu(
                key: _menuKey,
                currentRoute: '/recipe',
                onOpenChanged: (isOpen) {
                  setState(() => _isMenuOpen = isOpen);
                },
              ),
            ],
          ),
        ),
      );
  }
}
