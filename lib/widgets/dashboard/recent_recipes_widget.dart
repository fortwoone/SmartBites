import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/app_providers.dart';

import '../../l10n/app_localizations.dart';
import '../../models/recipe.dart';
import '../../utils/color_constants.dart';
import '../../viewmodels/recipe_viewmodel.dart';
import '../../views/recipes/recipe_detail_page.dart';

class RecentRecipesWidget extends ConsumerWidget {
  const RecentRecipesWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final recipesState = ref.watch(recipeViewModelProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                loc.last_recipes,
                style: GoogleFonts.recursive(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                ),
              ),
              TextButton(
                onPressed: () {
                   ref.read(dashboardIndexProvider.notifier).state = 3;
                },
                child: Text(
                    loc.see_all,
                    style: GoogleFonts.recursive(color: AppColors.primary)
                ),
              ),
            ],
          ),
        ),
        recipesState.when(
          data: (recipes) {
            if (recipes.isEmpty) {
               return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(loc.no_recipes),
              );
            }
            final recentRecipes = recipes.take(3).toList();
            
            return SizedBox(
               height: 280, 
               child: PageView.builder(
                 controller: PageController(viewportFraction: 0.9),
                 itemCount: recentRecipes.length,
                 itemBuilder: (context, index) => _RecipeCard(recipe: recentRecipes[index]),
               ),
            );
          },
          loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
          error: (error, _) => Padding(
             padding: const EdgeInsets.all(16),
             child: Text("Erreur: $error"),
          ),
        )
      ],
    );
  }
}

// Widget pour une carte de recette
class _RecipeCard extends StatelessWidget {
  final Recipe recipe;
  const _RecipeCard({required this.recipe});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
          Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailPage(initialRecipe: recipe),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(26),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: recipe.imageUrl != null
                    ? Image.network(
                        recipe.imageUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.restaurant, color: Colors.grey, size: 40),
                      ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      recipe.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.recursive(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          "${recipe.prepTime} min",
                          style: GoogleFonts.recursive(
                              color: Colors.grey.shade600,
                              fontSize: 13
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
