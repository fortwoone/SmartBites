import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:SmartBites/screens/view_recipe_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../l10n/app_localizations.dart';
import '../widgets/side_menu.dart';
import '../utils/color_constants.dart';
import '../utils/page_transitions.dart';
import 'add_recipe_page.dart';
import '../widgets/recipe/recipe_background.dart';
import '../widgets/recipe/recipe_list_header.dart';
import '../widgets/recipe/recipe_card.dart';

class RecipeListPage extends StatefulWidget {
  const RecipeListPage({super.key});

  @override
  State<RecipeListPage> createState() => _RecipeListPageState();
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

  /// Calculates the average rating of a recipe
  double calculateAverageRating(Map<String, dynamic> recipe) {
    final notesData = recipe['notes'];
    List<dynamic> notes = [];

    if (notesData is List) {
      notes = notesData;
    } else if (notesData is Map) {
      notes = [notesData];
    } else {
      return 0.0;
    }

    if (notes.isEmpty) return 0.0;

    double sum = 0;
    int count = 0;
    for (var note in notes) {
      if (note is Map && note['rating'] != null) {
        final rating = note['rating'];
        if (rating is int || rating is double) {
          sum += rating.toDouble();
          count++;
        }
      }
    }

    return count > 0 ? sum / count : 0.0;
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

  void _openRecipeDetail(Map<String, dynamic> recipe) {
    Navigator.push(
      context,
      SlideAndFadePageRoute(page: ViewRecipePage(recipe: recipe)),
    );
  }

  Future<void> _openRecipeEditor(Map<String, dynamic> recipe) async {
    await Navigator.push(
      context,
      SlideAndFadePageRoute(
        page: AddRecipePage(
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
        title: Text(loc.deleteRecipeConfirm, style: GoogleFonts.recursive(fontWeight: FontWeight.bold)),
        content: Text(loc.deleteRecipeConfirm, style: GoogleFonts.recursive()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(loc.cancel, style: GoogleFonts.recursive()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: Text(loc.delete, style: GoogleFonts.recursive(color: Colors.white)),
          ),
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
          .showSnackBar(SnackBar(content: Text(loc.recipeDeleted)));
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
    final topPadding = MediaQuery.of(context).padding.top + 80;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: RecipeListHeader(
        isMenuOpen: _isMenuOpen,
        onToggleMenu: _toggleMenu,
        showOnlyMine: _showOnlyMine,
        onToggleFilter: _toggleFilter,
        onAddRecipe: () async {
          await Navigator.push(
            context,
            SlideAndFadePageRoute(page: const AddRecipePage(), direction: AxisDirection.up),
          );
          _fetchRecipes();
        },
      ),
      body: Stack(
        children: [
          const RecipeBackground(),
          Padding(
            padding: EdgeInsets.only(top: topPadding),
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: primaryPeach))
                : _recipes.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.menu_book, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    loc.noRecipeFound,
                    style: GoogleFonts.recursive(fontSize: 18, color: Colors.grey.shade500),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              itemCount: _recipes.length,
              itemBuilder: (context, index) {
                final recipe = _recipes[index];
                final isMine = recipe['user_id_creator'] == userId;
                final averageRating = calculateAverageRating(recipe);

                return RecipeCard(
                  recipe: recipe,
                  isMine: isMine,
                  averageRating: averageRating,
                  onTap: () => _openRecipeDetail(recipe),
                  onMenuAction: (action) {
                    if (action == RecipeMenuAction.edit) {
                      _openRecipeEditor(recipe);
                    } else {
                      _deleteRecipe(recipe);
                    }
                  },
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: topPadding),
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: SideMenu(
                key: _menuKey,
                currentRoute: '/recipe',
                onOpenChanged: (isOpen) {
                  setState(() => _isMenuOpen = isOpen);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
