
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/recipe.dart';

// ==============================================================================
// REPOSITORY : RecipeRepository
// ==============================================================================
class RecipeRepository {
  final SupabaseClient _client;

  RecipeRepository(this._client);
  static final RecipeRepository instance = RecipeRepository(Supabase.instance.client);
  static const String _tableName = 'Recettes';

  // ---------------------------------------------------------------------------
  // Récupérer toutes les recettes
  // ---------------------------------------------------------------------------
  Future<List<Recipe>> getRecipes({String? userId, bool descending = true}) async {
    try {
      var query = _client.from(_tableName).select();
      if (userId != null) {
        query = query.eq('user_id_creator', userId);
      }
      final response = await query.order('created_at', ascending: !descending);
      return response.map((json) => Recipe.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Récupérer une recette par ID
  // ---------------------------------------------------------------------------
  Future<Recipe?> getRecipe(int id) async {
    try {
      final response = await _client.from(_tableName).select().eq('id', id).maybeSingle();
      if (response != null) {
        return Recipe.fromJson(response);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Créer une nouvelle recette
  // ---------------------------------------------------------------------------
  Future<Recipe> createRecipe(Recipe recipe) async {
    try {
      final data = recipe.toJson()..remove('id');
      final response = await _client.from(_tableName).insert(data).select().single();
      return Recipe.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Mettre à jour une recette
  // ---------------------------------------------------------------------------
  Future<Recipe> updateRecipe(Recipe recipe) async {
    if (recipe.id == null) {
      throw Exception('Impossible de mettre à jour une recette sans ID');
    }
      try {
        final response = await _client.from(_tableName).update(recipe.toJson()).eq('id', recipe.id!).select().single();
        return Recipe.fromJson(response);
      } catch (e) {
        rethrow;
      }
  }

  // ---------------------------------------------------------------------------
  // Supprimer une recette
  // ---------------------------------------------------------------------------
  Future<void> deleteRecipe(int id) async {
    try {
      await _client.from(_tableName).delete().eq('id', id);
    } catch (e) {
      rethrow;
    }
  }
}
