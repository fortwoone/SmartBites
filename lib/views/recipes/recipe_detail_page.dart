import 'dart:ui';
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
import '../shopping_list/shopping_list_detail_page.dart';
import 'add_recipe_page.dart';
import '../../widgets/recipe/notes_list.dart';


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
  final ScrollController _scrollController = ScrollController();

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
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                    SliverAppBar(
                        expandedHeight: 400,
                        backgroundColor: Colors.white,
                        pinned: true,
                        stretch: true,
                        flexibleSpace: FlexibleSpaceBar(
                            stretchModes: const [StretchMode.zoomBackground],
                            background: Stack(
                              fit: StackFit.expand,
                              children: [
                                _recipe.imageUrl != null
                                    ? Image.network(
                                        _recipe.imageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                                      )
                                    : _buildPlaceholder(),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.black.withValues(alpha: 0.3),
                                        Colors.transparent,
                                        Colors.black.withValues(alpha: 0.7),
                                      ],
                                      stops: const [0, 0.5, 1],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            title: Text(
                                _recipe.name, 
                                style: GoogleFonts.recursive(
                                    color: Colors.white, 
                                    fontWeight: FontWeight.bold,
                                    shadows: [const Shadow(blurRadius: 10, color: Colors.black)]
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                            ),
                        ),
                        actions: [
                            if (isOwner)
                                _buildGlassActionButton(
                                    icon: Icons.edit,
                                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddRecipePage(recipeToEdit: _recipe))),
                                ),
                             if (isOwner)
                                _buildGlassActionButton(
                                    icon: Icons.delete,
                                    color: Colors.redAccent,
                                    onTap: () => _showDeleteDialog(loc),
                                ),
                             const SizedBox(width: 8),
                        ],
                    ),
                    SliverToBoxAdapter(
                        child: Container(
                            decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                            ),
                            transform: Matrix4.translationValues(0, -20, 0),
                            child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                        Center(
                                          child: Container(
                                            height: 4, width: 40, 
                                            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                                            margin: const EdgeInsets.only(bottom: 20),
                                          )
                                        ),
                                        Text(_recipe.description ?? loc.no_description, 
                                            style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[600], height: 1.5)
                                        ),
                                        const SizedBox(height: 24),
                                        _buildStatsRow(),
                                        const SizedBox(height: 32),
                                        Text(loc.ingredients, style: GoogleFonts.recursive(fontSize: 22, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 16),
                                        _buildIngredientsList(),
                                        const SizedBox(height: 32),
                                        Text(loc.instructions, style: GoogleFonts.recursive(fontSize: 22, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 16),
                                        _buildInstructionsList(),
                                        const SizedBox(height: 40),
                                        _buildRatingSection(loc, user),
                                        const SizedBox(height: 40),

                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[50], 
                                            borderRadius: BorderRadius.circular(16)
                                          ),
                                          child: RecipeNotesList(notes: _recipe.notes)
                                        ),
                                        
                                        const SizedBox(height: 100),
                                    ],
                                ),
                            ),
                        )
                    )
                ],
            ),
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10)),
                      ]
                    ),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                        ),
                        onPressed: () => _addToShoppingList(context, loc, user),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              loc.add_to_grocery_list, 
                              style: GoogleFonts.recursive(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)
                            ),
                          ],
                        ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildPlaceholder() {
      return Container(
        color: Colors.orange,
        child: const Center(
          child: Icon(Icons.restaurant_menu, size: 80, color: Colors.white54),
        ),
      );
  }

  Widget _buildGlassActionButton({required IconData icon, required VoidCallback onTap, Color color = Colors.white}) {
      return Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              shape: BoxShape.circle,
          ),
          child: ClipOval(
             child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: IconButton(
                    icon: Icon(icon, color: color),
                    onPressed: onTap,
                ),
             ),
          ),
      );
  }

  Widget _buildStatsRow() {
     return Row(
         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
         children: [
             _buildStatItem(Icons.timer_outlined, "${_recipe.prepTime} min", "Prep"),
             Container(height: 30, width: 1, color: Colors.grey[300]),
             _buildStatItem(Icons.local_fire_department_outlined, "${_recipe.bakingTime} min", "Cook"),
             Container(height: 30, width: 1, color: Colors.grey[300]),
             _buildStatItem(Icons.star_rate_rounded, _recipe.averageRating > 0 ? _recipe.averageRating.toStringAsFixed(1) : "-", "Rating"),
         ],
     );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
      return Column(
          children: [
              Icon(icon, color: AppColors.primary, size: 28),
              const SizedBox(height: 4),
              Text(value, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(label, style: GoogleFonts.inter(color: Colors.grey, fontSize: 12)),
          ],
      );
  }

  Widget _buildIngredientsList() {
      return Column(
          children: _recipe.ingredients.map((ing) {
              return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200)
                  ),
                  child: Row(
                      children: [
                          Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                              child: const Icon(Icons.check, size: 16, color: AppColors.primary),
                          ),
                          const SizedBox(width: 16),
                          Expanded(child: Text(ing.ingredient, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500))),
                      ],
                  ),
              );
          }).toList(),
      );
  }

  Widget _buildInstructionsList() {
      final steps = _recipe.instructions.split('\n');
      return Column(
          children: steps.asMap().entries.map((entry) {
              if (entry.value.trim().isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 24),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Column(
                          children: [
                             Container(
                                width: 30, height: 30,
                                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                child: Center(child: Text("${entry.key + 1}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                             ),
                             if (entry.key != steps.length - 1)
                                Container(width: 2, height: 40, color: Colors.grey[200], margin: const EdgeInsets.only(top: 8))
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                            child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))]
                                ),
                                child: Text(entry.value, style: GoogleFonts.inter(fontSize: 15, height: 1.5)),
                            )
                        ),
                    ],
                ),
              );
          }).toList(),
      );
  }

  Widget _buildRatingSection(AppLocalizations loc, dynamic user) {
      return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade100),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15)]
          ),
          child: Column(
              children: [
                   Text(loc.rateAndComment, style: GoogleFonts.recursive(fontSize: 20, fontWeight: FontWeight.bold)),
                   const SizedBox(height: 16),
                   Row(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: List.generate(5, (index) {
                           return GestureDetector(
                               onTap: () => setState(() => _rating = index + 1),
                               child: Padding(
                                 padding: const EdgeInsets.symmetric(horizontal: 4),
                                 child: Icon(
                                    index < _rating ? Icons.star_rounded : Icons.star_outline_rounded, 
                                    color: Colors.amber, 
                                    size: 40
                                 ),
                               ),
                           );
                       }),
                   ),
                   const SizedBox(height: 24),
                   TextField(
                       controller: _noteCtrl,
                       decoration: InputDecoration(
                           hintText: loc.comments,
                           filled: true,
                           fillColor: Colors.grey[50],
                           border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                           contentPadding: const EdgeInsets.all(16),
                       ),
                       maxLines: 3,
                   ),
                   const SizedBox(height: 16),
                   if (user != null)
                     SizedBox(
                         width: double.infinity,
                         child: ElevatedButton(
                             style: ElevatedButton.styleFrom(
                                 backgroundColor: Colors.black87,
                                 padding: const EdgeInsets.symmetric(vertical: 16),
                                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                             ),
                             onPressed: () => _saveNote(user),
                             child: const Text("Post Comment", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                         ),
                     )
              ],
          ),
      );
  }

  Future<void> _showDeleteDialog(AppLocalizations loc) async {
       showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(loc.delete_recipe, style: GoogleFonts.recursive(fontWeight: FontWeight.bold)),
            content: Text(loc.confirm_delete_recipe),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(loc.cancel, style: const TextStyle(color: Colors.black54)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                onPressed: () {
                  Navigator.pop(ctx);
                  ref.read(recipeViewModelProvider.notifier).deleteRecipe(_recipe.id!);
                  Navigator.pop(context);
                },
                child: Text(loc.delete, style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
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
  Future<void> _addToShoppingList(
      BuildContext context,
      AppLocalizations loc,
      dynamic user,
      ) async {
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.have_to_be_connected_to_create_list)),
      );
      return;
    }

    final products = _recipe.ingredients.map((i) {
      return i.barcode ?? "TEXT:${i.ingredient}";
    }).toList();

    final quantities = {for (var e in products) e: 1};

    final newList = ShoppingList(
      userId: user.id,
      name: "Recette: ${_recipe.name}",
      products: products,
      quantities: quantities,
    );

    try {
      final createdList = await ref
          .read(shoppingListViewModelProvider.notifier)
          .addListWithReturn(newList);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Expanded(child: Text(loc.list_added)),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ShoppingListDetailPage(
                        listId: createdList.id!,
                        initialList: createdList,
                      ),
                    ),
                  );
                },
                child: Text(
                  loc.goTo,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur: $e")),
        );
      }
    }
  }
}
