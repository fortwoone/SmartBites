
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/shopping_list.dart';

// ==============================================================================
// REPOSITORY : ShoppingListRepository
// ==============================================================================
class ShoppingListRepository {
  final SupabaseClient _client;
  ShoppingListRepository(this._client);
  static final ShoppingListRepository instance = ShoppingListRepository(Supabase.instance.client);
  static const String _tableName = 'shopping_list';

  // ---------------------------------------------------------------------------
  // Récupérer toutes les listes d'un utilisateur
  // ---------------------------------------------------------------------------
  Future<List<ShoppingList>> getLists(String userId) async {
    try {
      final response = await _client.from(_tableName).select().eq('user_id', userId).order('id', ascending: true);
      return response.map((json) => ShoppingList.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Créer une nouvelle liste
  // ---------------------------------------------------------------------------
  Future<ShoppingList> createList(ShoppingList list) async {
    try {
      final data = list.toJson()..remove('id');
      final response = await _client.from(_tableName).insert(data).select().single();
      return ShoppingList.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Mettre à jour une liste (Nom, Produits, Quantités)
  // ---------------------------------------------------------------------------
  Future<ShoppingList> updateList(ShoppingList list) async {
    if (list.id == null) {
      throw Exception('Impossible de mettre à jour une liste sans ID');
    }
    try {
      final response = await _client.from(_tableName).update(list.toJson()).eq('id', list.id!).select().single();
      return ShoppingList.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Supprimer une liste
  // ---------------------------------------------------------------------------
  Future<void> deleteList(int listId) async {
    try {
      await _client.from(_tableName).delete().eq('id', listId);
    } catch (e) {
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Vérifier si un nom de liste existe déjà pour l'utilisateur
  // ---------------------------------------------------------------------------
  Future<bool> nameExists(String userId, String name) async {
    try {
      final response = await _client.from(_tableName).select('id').eq('user_id', userId).eq('name', name).maybeSingle();
      return response != null;
    } catch (e) {
      return false;
    }
  }
}
