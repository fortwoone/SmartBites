import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import '../repositories/auth_repository.dart';
import '../repositories/openfoodfacts_repository.dart';
import '../repositories/shopping_list_repository.dart';
import '../repositories/recipe_repository.dart';
import '../repositories/history_repository.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// HTTP Client (pour les tests plus tard)
final httpClientProvider = Provider<http.Client>((ref) {
  return http.Client();
});

// ==============================================================================
// REPOSITORY PROVIDERS
// ==============================================================================

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(supabaseClientProvider));
});

final openFoodFactsRepositoryProvider = Provider<OpenFoodFactsRepository>((ref) {
  return OpenFoodFactsRepository(client: ref.watch(httpClientProvider));
});

final shoppingListRepositoryProvider = Provider<ShoppingListRepository>((ref) {
  return ShoppingListRepository(ref.watch(supabaseClientProvider));
});

final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  return RecipeRepository(ref.watch(supabaseClientProvider));
});

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return HistoryRepository(prefs);
});

// ==============================================================================
// NAVIGATION PROVIDER
// ==============================================================================
final dashboardIndexProvider = StateProvider<int>((ref) => 0);


final priceRepositoryProvider = Provider<OpenFoodFactsRepository>((ref) {
  return OpenFoodFactsRepository(); // or however you instantiate it
});