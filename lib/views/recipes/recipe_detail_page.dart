import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../l10n/app_localizations.dart';
import '../../models/recipe.dart';
import '../../models/shopping_list.dart';
import '../../utils/color_constants.dart';
import '../../viewmodels/recipe_viewmodel.dart';
import '../../viewmodels/shopping_list_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import 'add_recipe_page.dart';

class RecipeDetailPage extends ConsumerStatefulWidget {
  final Recipe initialRecipe;
  final Recipe? recipe;
  const RecipeDetailPage({super.key, required this.initialRecipe, this.recipe});
  @override
  ConsumerState<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends ConsumerState<RecipeDetailPage> {
  late Recipe _recipe;
  final TextEditingController _noteCtrl = TextEditingController();
  int _rating = 0;

  @override
  void initState() {
    super.initState();
    _recipe = widget.recipe ?? widget.initialRecipe;
  }

  // Récupérer la note de l'utilisateur
  Map<String, dynamic>? _getUserNote(String userId) {
      if (_recipe.notes.isEmpty) return null;
      try {
          return _recipe.notes.firstWhere((n) => n['author'] == userId);
      } catch (e) {
          return null;
      }
  }

  @override
  void didChangeDependencies() {
      super.didChangeDependencies();
      final user = ref.read(authViewModelProvider).value;
      if (user != null) {
          final note = _getUserNote(user.id);
          if (note != null) {
              _noteCtrl.text = note['note'] ?? '';
              _rating = note['rating'] ?? 0;
          }
      }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final user = ref.watch(authViewModelProvider).value;
    final isOwner = user != null && user.id == _recipe.userId;

    return Scaffold(
        body: CustomScrollView(
            slivers: [
                SliverAppBar(
                    expandedHeight: 250,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                        title: Text(_recipe.name, style: GoogleFonts.recursive(color: Colors.white, fontWeight: FontWeight.bold, shadows: [const Shadow(blurRadius: 4, color: Colors.black)])),
                        background: Container(
                             color: Colors.orange,
                             child: const Icon(Icons.fastfood, size: 100, color: Colors.white54), 
                        ),
                    ),
                    actions: [
                        if (isOwner)
                            IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => AddRecipePage(recipeToEdit: _recipe)));
                                },
                            ),
                         if (isOwner)
                            IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: Text(loc.delete_recipe),
                                        content: Text(loc.confirm_delete_recipe),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx),
                                            child: Text(loc.cancel),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(ctx);
                                              ref.read(recipeViewModelProvider.notifier).deleteRecipe(_recipe.id!);
                                              Navigator.pop(context);
                                            },
                                            child: Text(loc.delete, style: const TextStyle(color: Colors.red)),
                                          ),
                                        ],
                                      ),
                                    );
                                },
                            )
                    ],
                ),
                SliverList(delegate: SliverChildListDelegate([
                    Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                _buildInfoCard(loc),
                                const SizedBox(height: 20),
                                Text(loc.ingredients, style: GoogleFonts.recursive(fontSize: 22, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 10),
                                _buildIngredientsChips(),
                                const SizedBox(height: 20),
                                Text(loc.instructions, style: GoogleFonts.recursive(fontSize: 22, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 10),
                                _buildInstructionsList(),
                                const SizedBox(height: 30),
                                _buildRatingSection(loc, user),
                                const SizedBox(height: 30),
                                SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary,
                                            padding: const EdgeInsets.all(16),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                                        ),
                                        icon: const Icon(Icons.shopping_cart, color: Colors.white),
                                        label: Text(loc.add_to_grocery_list, style: GoogleFonts.recursive(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                                        onPressed: () => _addToShoppingList(context, loc, user),
                                    ),
                                ),
                                const SizedBox(height: 40),
                            ],
                        ),
                    )
                ]))
            ],
        ),
    );
  }

  // Carte d'information sur la recette
  Widget _buildInfoCard(AppLocalizations loc) {
      return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)]),
          child: Column(
              children: [
                   Text(_recipe.description ?? loc.no_description, style: GoogleFonts.recursive(fontSize: 16)),
                   const SizedBox(height: 16),
                   Row(
                       mainAxisAlignment: MainAxisAlignment.spaceAround,
                       children: [
                           Column(children: [const Icon(Icons.timer, color: AppColors.primary), Text("${_recipe.prepTime} min")]),
                           Column(children: [const Icon(Icons.local_fire_department, color: Colors.orange), Text("${_recipe.bakingTime} min")]),
                       ],
                   )
              ],
          ),
      );
  }

  // Ingrédients sous forme de chips
  Widget _buildIngredientsChips() {
      return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _recipe.ingredients.map((ing) {
              return Chip(
                  label: Text(ing.ingredient),
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              );
          }).toList(),
      );
  }

  // Liste des instructions
  Widget _buildInstructionsList() {
      final steps = _recipe.instructions.split('\n');
      return Column(
          children: steps.asMap().entries.map((entry) {
              return ListTile(
                  leading: CircleAvatar(backgroundColor: AppColors.primary, child: Text("${entry.key + 1}", style: const TextStyle(color: Colors.white))),
                  title: Text(entry.value, style: GoogleFonts.recursive()),
              );
          }).toList(),
      );
  }

  // Section de notation et commentaire
  Widget _buildRatingSection(AppLocalizations loc, dynamic user) {
      return Column(
          children: [
              Text(loc.rateAndComment, style: GoogleFonts.recursive(fontSize: 20, fontWeight: FontWeight.bold)),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                      return IconButton(
                          icon: Icon(index < _rating ? Icons.star : Icons.star_border, color: AppColors.primary, size: 32),
                          onPressed: () {
                              setState(() => _rating = index + 1);
                          },
                      );
                  }),
              ),
              TextField(
                  controller: _noteCtrl,
                  decoration: InputDecoration(
                      hintText: loc.comments,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))
                  ),
                  maxLines: 3,
              ),
              const SizedBox(height: 8),
              if (user != null)
                IconButton(
                    icon: const Icon(Icons.save, color: AppColors.primary),
                    onPressed: () {
                        _saveNote(user);
                    },
                )
          ],
      );
  }

  // Sauvegarder la note et le commentaire de l'utilisateur
  Future<void> _saveNote(dynamic user) async {
       final newNote = {
           'note': _noteCtrl.text,
           'rating': _rating,
           'author': user.id
       };
       List<Map<String, dynamic>> updatedNotes = List.from(_recipe.notes);
       final index = updatedNotes.indexWhere((n) => n['author'] == user.id);
       if (index >= 0) {
           updatedNotes[index] = newNote;
       } else {
           updatedNotes.add(newNote);
       }
       final updatedRecipe = _recipe.copyWith(notes: updatedNotes);
       await ref.read(recipeViewModelProvider.notifier).updateRecipe(updatedRecipe);
       setState(() => _recipe = updatedRecipe);
       if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Note sauvegardée")));
  }

  // Ajouter les ingrédients de la recette à une liste de courses
  Future<void> _addToShoppingList(BuildContext context, AppLocalizations loc, dynamic user) async {
      if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.have_to_be_connected_to_create_list)));
          return;
      }
      
      final products = _recipe.ingredients.map((i) {
          return i.barcode ?? "TEXT:${i.ingredient}";
      }).toList();
      
      final quantities = { for (var e in products) e : 1 };
      
      final newList = ShoppingList(
          userId: user.id,
          name: "Recette: ${_recipe.name}",
          products: products,
          quantities: quantities
      );
      
      try {
          await ref.read(shoppingListViewModelProvider.notifier).addList(newList);
          if (context.mounted) {
             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.list_added)));
          }
      } catch (e) {
          if (context.mounted) {
             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: $e")));
          }
      }
  }
}
