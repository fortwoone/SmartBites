
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shopping_list.dart';
import '../providers/app_providers.dart';
import 'auth_viewmodel.dart';

// ==============================================================================
// VIEW MODEL : ShoppingListViewModel
// ==============================================================================
final shoppingListViewModelProvider = AsyncNotifierProvider<ShoppingListViewModel, List<ShoppingList>>(() {
  return ShoppingListViewModel();
});

class ShoppingListViewModel extends AsyncNotifier<List<ShoppingList>> {
  @override
  FutureOr<List<ShoppingList>> build() async {
    final userState = ref.watch(authViewModelProvider);
    if (userState.value == null) {
      return [];
    }
    final repository = ref.read(shoppingListRepositoryProvider);
    return await repository.getLists(userState.value!.id);
  }

  // ---------------------------------------------------------------------------
  // Créer une liste
  // ---------------------------------------------------------------------------
  Future<void> createList(String name) async {
    final user = ref.read(authViewModelProvider).value;
    if (user == null) return;
    final newList = ShoppingList(name: name, userId: user.id, products: [], quantities: {});

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(shoppingListRepositoryProvider).createList(newList);
      ref.invalidateSelf();
      final repository = ref.read(shoppingListRepositoryProvider);
      final user = ref.read(authViewModelProvider).value;
      return await repository.getLists(user!.id);
    });
  }

  // ---------------------------------------------------------------------------
  // Supprimer une liste
  // ---------------------------------------------------------------------------
  Future<void> deleteList(int listId) async {
    final previousState = state;
    if (previousState.value != null) {
        state = AsyncData(previousState.value!.where((l) => l.id != listId).toList());
    }

    try {
      await ref.read(shoppingListRepositoryProvider).deleteList(listId);
    } catch (e) {
      state = previousState;
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Renommer une liste
  // ---------------------------------------------------------------------------
  Future<void> renameList(ShoppingList list, String newName) async {
    if (list.id == null) {
      return;
    }
    final updatedList = list.copyWith(name: newName);
    try {
        await ref.read(shoppingListRepositoryProvider).updateList(updatedList);
        ref.invalidateSelf();
    } catch (e) {
        rethrow;
    }
  }
}
