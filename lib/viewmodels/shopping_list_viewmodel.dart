
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
  // Créer une liste (Simple nom)
  // ---------------------------------------------------------------------------
  Future<void> createList(String name) async {
    final user = ref.read(authViewModelProvider).value;
    if (user == null) return;
    final newList = ShoppingList(name: name, userId: user.id, products: [], quantities: {});
    await addList(newList);
  }

  // ---------------------------------------------------------------------------
  // Ajouter une liste complète
  // ---------------------------------------------------------------------------
  Future<void> addList(ShoppingList list) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(shoppingListRepositoryProvider).createList(list);
      ref.invalidateSelf();
      final repository = ref.read(shoppingListRepositoryProvider);
      final user = ref.read(authViewModelProvider).value;
      return await repository.getLists(user!.id);
    });
  }

  // ---------------------------------------------------------------------------
  // Ajouter une liste complète avec renvoie de la liste
  // ---------------------------------------------------------------------------
  Future<ShoppingList> addListWithReturn(ShoppingList list) async {
    final repository = ref.read(shoppingListRepositoryProvider);
    final user = ref.read(authViewModelProvider).value!;

    final createdList = await repository.createList(list);

    // Update state locally (no full refetch needed, but allowed)
    state = AsyncData([
      ...(state.value ?? []),
      createdList,
    ]);

    return createdList;
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
  // Mettre à jour une liste (Nom, Produits, Quantités)
  // ---------------------------------------------------------------------------
  Future<void> updateList(ShoppingList list) async {
    if (list.id == null) return;
    try {
        await ref.read(shoppingListRepositoryProvider).updateList(list);
        ref.invalidateSelf();
    } catch (e) {
        rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Renommer une liste (Keep for convenience or refactor to use updateList)
  // ---------------------------------------------------------------------------
  Future<void> renameList(ShoppingList list, String newName) async {
    final updatedList = list.copyWith(name: newName);
    await updateList(updatedList);
  }
}
