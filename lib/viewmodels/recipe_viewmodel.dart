import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/recipe.dart';
import '../providers/app_providers.dart';

// ==============================================================================
// VIEW MODEL : RecipeViewModel
// ==============================================================================
final recipeViewModelProvider = AsyncNotifierProvider<RecipeViewModel, List<Recipe>>(() {
  return RecipeViewModel();
});

class RecipeViewModel extends AsyncNotifier<List<Recipe>> {
  @override
  FutureOr<List<Recipe>> build() async {
    return _fetchRecipes();
  }

  // ---------------------------------------------------------------------------
  // Récupérer les recettes
  // ---------------------------------------------------------------------------
  Future<List<Recipe>> _fetchRecipes() async {
    final repository = ref.read(recipeRepositoryProvider);
    return await repository.getRecipes(descending: true);
  }

  // ---------------------------------------------------------------------------
  // Recharger
  // ---------------------------------------------------------------------------
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchRecipes());
  }

  // ---------------------------------------------------------------------------
  // Créer une recette
  // ---------------------------------------------------------------------------
  Future<void> addRecipe(Recipe recipe) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(recipeRepositoryProvider).createRecipe(recipe);
      return _fetchRecipes();
    });
  }

  // ---------------------------------------------------------------------------
  // Mettre à jour une recette
  // ---------------------------------------------------------------------------
  Future<void> updateRecipe(Recipe recipe) async {
    if (recipe.id == null) return;
    try {
        await ref.read(recipeRepositoryProvider).updateRecipe(recipe);
        ref.invalidateSelf();
    } catch (e) {
        rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Supprimer une recette
  // ---------------------------------------------------------------------------
  Future<void> deleteRecipe(int id) async {
    final previousState = state;
    if (previousState.value != null) {
      state = AsyncData(previousState.value!.where((r) => r.id != id).toList());
    }
    try {
      await ref.read(recipeRepositoryProvider).deleteRecipe(id);
    } catch (e) {
      state = previousState;
      rethrow;
    }
  }
}
