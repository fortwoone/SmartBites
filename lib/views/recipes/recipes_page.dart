import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../l10n/app_localizations.dart';
import '../../models/recipe.dart';
import '../../utils/color_constants.dart';
import '../../viewmodels/recipe_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/common/custom_page_header.dart';
import 'recipe_detail_page.dart';
import 'add_recipe_page.dart';

final showMyRecipesProvider = StateProvider<bool>((ref) => false);

class RecipesPage extends ConsumerStatefulWidget {
  const RecipesPage({super.key});

  @override
  ConsumerState<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends ConsumerState<RecipesPage> {
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final recipesAsync = ref.watch(recipeViewModelProvider);
    final user = ref.watch(authViewModelProvider).value;
    final showMyRecipes = ref.watch(showMyRecipesProvider);

    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 100),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: loc.search_recipe_hint ?? "Rechercher une recette...", 
                          prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, color: Colors.grey),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(color: AppColors.primary, width: 1),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      if (user != null)
                      Row(
                        children: [
                          FilterChip(
                            label: Text(loc.myRecipes),
                            selected: showMyRecipes,
                            onSelected: (bool selected) {
                              ref.read(showMyRecipesProvider.notifier).state = selected;
                            },
                            backgroundColor: Colors.white,
                            selectedColor: AppColors.primary.withOpacity(0.2),
                            checkmarkColor: AppColors.primary,
                            labelStyle: GoogleFonts.inter(
                              color: showMyRecipes ? AppColors.primary : Colors.black87,
                              fontWeight: showMyRecipes ? FontWeight.w600 : FontWeight.normal,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: showMyRecipes ? AppColors.primary : Colors.grey.shade300,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: recipesAsync.when(
                    data: (recipes) {
                      if (recipes.isEmpty) {
                        return _buildEmptyState(loc);
                      }

                      final currentUserId = user?.id;
                      final searchQuery = _searchController.text.toLowerCase();
                      final filteredRecipes = recipes.where((r) {
                        if (showMyRecipes && r.userId != currentUserId) {
                          return false;
                        }

                        if (searchQuery.isNotEmpty) {
                           final nameMatch = r.name.toLowerCase().contains(searchQuery);
                           if (!nameMatch) {
                             return false;
                           }
                        }
                        
                        return true;
                      }).toList();

                      if (filteredRecipes.isEmpty) {
                        return _buildEmptyState(loc, isSearchEmpty: true);
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 100),
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
                ),
              ],
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomPageHeader(
              title: loc.recipes_menu,
              onAddTap: user != null 
                  ? () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddRecipePage()),
                    )
                  : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(loc.user_not_authenticated)),
                      );
                    },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations loc, {bool isSearchEmpty = false}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearchEmpty ? Icons.search_off : Icons.restaurant_menu,
            size: 64,
            color: Colors.grey.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            isSearchEmpty ? loc.no_results_now : loc.noRecipeFound,
            style: GoogleFonts.recursive(color: Colors.grey),
          ),
        ],
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
           BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.05)),
      ),
      child: Material(
        color: Colors.transparent,
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
                  errorBuilder: (context, error, stackTrace) {
                     return Container(
                        height: 150,
                        width: double.infinity,
                        color: AppColors.primary.withOpacity(0.1),
                        child: const Icon(Icons.restaurant, size: 60, color: AppColors.primary),
                      );
                  },
                )
                    : Container(
                  height: 150,
                  width: double.infinity,
                  color: AppColors.primary.withOpacity(0.1),
                  child: const Icon(Icons.restaurant, size: 60, color: AppColors.primary),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(recipe.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87)),
                        ),
                        if (isOwner)
                          const Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: Icon(Icons.person, size: 16, color: AppColors.primary),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildInfoChip(Icons.timer_outlined, "${recipe.prepTime} min"),
                        const SizedBox(width: 12),
                        _buildInfoChip(Icons.local_fire_department_outlined, "${recipe.bakingTime} min"),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.star_rounded, size: 20, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(recipe.averageRating.toStringAsFixed(1),
                            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(width: 4),
                        Text("(${recipe.ratingCount})",
                            style: GoogleFonts.inter(color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(label,
            style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
