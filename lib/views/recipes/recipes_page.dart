import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../l10n/app_localizations.dart';
import '../../models/recipe.dart';
import '../../utils/color_constants.dart';
import '../../viewmodels/recipe_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import 'recipe_detail_page.dart';
import 'add_recipe_page.dart';

/// StateProvider to track whether to show only the user's recipes
final showMyRecipesProvider = StateProvider<bool>((ref) => false);

class RecipesPage extends ConsumerWidget {
  const RecipesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final recipesAsync = ref.watch(recipeViewModelProvider);
    final user = ref.watch(authViewModelProvider).value;
    final showMyRecipes = ref.watch(showMyRecipesProvider);

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'lib/ressources/cuisine_icon.png',
            fit: BoxFit.contain,
          ),
        ),
        title: Text(
          loc.recipes_menu,
          style: GoogleFonts.recursive(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              showMyRecipes ? Icons.person : Icons.person_outline,
            ),
            onPressed: () {
              ref.read(showMyRecipesProvider.notifier).state = !showMyRecipes;
            },
            tooltip: loc.myRecipes,
          ),
        ],
      ),
      body: recipesAsync.when(
        data: (recipes) {
          if (recipes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant_menu, size: 64, color: Colors.grey.withAlpha(100)),
                  const SizedBox(height: 16),
                  Text(loc.noRecipeFound, style: GoogleFonts.recursive(color: Colors.grey)),
                ],
              ),
            );
          }

          final currentUserId = user?.id;
          // Apply filtering based on showMyRecipes
          final filteredRecipes = showMyRecipes
              ? recipes.where((r) => r.userId == currentUserId).toList()
              : recipes;

          if (filteredRecipes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant_menu, size: 64, color: Colors.grey.withAlpha(100)),
                  const SizedBox(height: 16),
                  Text(loc.noRecipeFound, style: GoogleFonts.recursive(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredRecipes.length,
            itemBuilder: (context, index) {
              final recipe = filteredRecipes[index];
              return _RecipeCard(
                recipe: recipe,
                isOwner: user != null && user.id == recipe.userId,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RecipeDetailPage(recipe: recipe, initialRecipe: recipe),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (user == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(loc.user_not_authenticated)),
            );
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddRecipePage()),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final bool isOwner;
  final VoidCallback onTap;

  const _RecipeCard({required this.recipe, required this.isOwner, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: recipe.imageUrl != null
                  ? Image.network(
                recipe.imageUrl!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              )
                  : Container(
                height: 150,
                width: double.infinity,
                color: AppColors.primary.withAlpha(50),
                child: const Icon(Icons.restaurant, size: 60, color: AppColors.primary),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(recipe.name,
                      style: GoogleFonts.recursive(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.timer, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text("${recipe.prepTime} min",
                          style: GoogleFonts.recursive(color: Colors.grey)),
                      const SizedBox(width: 16),
                      const Icon(Icons.local_fire_department, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text("${recipe.bakingTime} min",
                          style: GoogleFonts.recursive(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(recipe.averageRating.toStringAsFixed(1),
                          style: GoogleFonts.recursive(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 6),
                      Text("(${recipe.ratingCount})",
                          style: GoogleFonts.recursive(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
