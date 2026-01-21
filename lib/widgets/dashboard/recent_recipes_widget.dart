import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/app_providers.dart';

import '../../l10n/app_localizations.dart';
import '../../models/recipe.dart';
import '../../utils/color_constants.dart';
import '../../viewmodels/recipe_viewmodel.dart';
import '../../views/recipes/recipe_detail_page.dart';
import '../../views/recipes/recipes_page.dart'; // Import needed for showMyRecipesProvider
import 'dashboard_section_header.dart';

class RecentRecipesWidget extends ConsumerWidget {
  const RecentRecipesWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final recipesState = ref.watch(recipeViewModelProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashboardSectionHeader(
          title: loc.last_recipes,
          seeAllLabel: loc.see_all,
          onMoreTap: () {
             ref.read(showMyRecipesProvider.notifier).state = false; 
             ref.read(dashboardIndexProvider.notifier).state = 2;
          },
        ),
        recipesState.when(
          data: (recipes) {
            if (recipes.isEmpty) {
               return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(loc.no_recipes, style: GoogleFonts.inter(color: Colors.grey)),
              );
            }
            final recentRecipes = recipes.take(3).toList();
            
            return SizedBox(
               height: 260, 
               child: PageView.builder(
                 controller: PageController(viewportFraction: 0.85),
                 padEnds: false,
                 itemCount: recentRecipes.length,
                 itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 10), // Add left padding here instead
                      child: _RecipeCard(recipe: recentRecipes[index]),
                    );
                 },
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
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Expanded(
              flex: 5,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: recipe.imageUrl != null
                        ? Image.network(
                            recipe.imageUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.restaurant, color: Colors.grey, size: 40),
                          ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                             recipe.averageRating.toStringAsFixed(1),
                             style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
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
                      style: GoogleFonts.poppins(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w600
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _buildInfoChip(Icons.timer_outlined, "${recipe.prepTime} min"),
                        const SizedBox(width: 12),
                         _buildInfoChip(Icons.local_fire_department_outlined, "${recipe.bakingTime} min bake"),
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

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500
          ),
        ),
      ],
    );
  }
}
