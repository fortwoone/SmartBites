import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../l10n/app_localizations.dart';
import '../../models/shopping_list.dart';
import '../../utils/color_constants.dart';
import '../../viewmodels/shopping_list_viewmodel.dart';
import 'shopping_list_detail_page.dart';

class ShoppingListsPage extends ConsumerStatefulWidget {
  const ShoppingListsPage({super.key});
  @override
  ConsumerState<ShoppingListsPage> createState() => _ShoppingListsPageState();
}

class _ShoppingListsPageState extends ConsumerState<ShoppingListsPage> {
  
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final shoppingListsAsync = ref.watch(shoppingListViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.shopping_lists, style: GoogleFonts.recursive(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: shoppingListsAsync.when(
        data: (lists) {
          if (lists.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey.withAlpha(100)),
                   const SizedBox(height: 16),
                   Text(loc.no_list_create_one, style: GoogleFonts.recursive(color: Colors.grey)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: lists.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final list = lists[index];
              return _ShoppingListCard(
                list: list,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ShoppingListDetailPage(listId: list.id!, initialList: list)),
                ),
                onDelete: () => _confirmDelete(context, list, loc),
                onRename: () => _showRenameDialog(context, list, loc),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, loc),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
  // Ajout d'une nouvelle liste
  Future<void> _showAddDialog(BuildContext context, AppLocalizations loc) async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.new_list, style: GoogleFonts.recursive(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
             hintText: loc.name_list,
             border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(loc.cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
             onPressed: () async {
               if (controller.text.isNotEmpty) {
                 await ref.read(shoppingListViewModelProvider.notifier).createList(controller.text.trim());
                 if (context.mounted) Navigator.pop(context);
               }
             },
             child: Text(loc.validate, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Renommer une liste existante
  Future<void> _showRenameDialog(BuildContext context, ShoppingList list, AppLocalizations loc) async {
    final controller = TextEditingController(text: list.name);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.rename, style: GoogleFonts.recursive(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
           decoration: InputDecoration(
             border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(loc.cancel)),
           ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
             onPressed: () async {
               if (controller.text.isNotEmpty) {
                 await ref.read(shoppingListViewModelProvider.notifier).renameList(list, controller.text.trim());
                 if (context.mounted) Navigator.pop(context);
               }
             },
             child: Text(loc.validate, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Confirmer la suppression d'une liste
  Future<void> _confirmDelete(BuildContext context, ShoppingList list, AppLocalizations loc) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.confirm, style: GoogleFonts.recursive(fontWeight: FontWeight.bold)),
        content: Text(loc.delete_list, style: GoogleFonts.recursive()),
        actions: [
           TextButton(onPressed: () => Navigator.pop(context, false), child: Text(loc.cancel)),
           ElevatedButton(
             style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
             onPressed: () => Navigator.pop(context, true),
             child: Text(loc.delete, style: const TextStyle(color: Colors.white)),
           ),
        ],
      ),
    );

    if (confirm == true && list.id != null) {
       await ref.read(shoppingListViewModelProvider.notifier).deleteList(list.id!);
    }
  }
}

class _ShoppingListCard extends StatelessWidget {
  final ShoppingList list;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onRename;

  const _ShoppingListCard({required this.list, required this.onTap, required this.onDelete, required this.onRename});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
             BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 8, offset: const Offset(0, 4))
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text(list.name, style: GoogleFonts.recursive(fontWeight: FontWeight.bold, fontSize: 18)),
          subtitle: Text("${list.products.length} produits", style: GoogleFonts.recursive(color: Colors.grey)),
          trailing: PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'rename') onRename();
              if (value == 'delete') onDelete();
            },
            itemBuilder: (context) => [
               const PopupMenuItem(value: 'rename', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text("Renommer")])),
               const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 18), SizedBox(width: 8), Text("Supprimer", style: TextStyle(color: Colors.red))])),
            ],
          ),
        ),
      ),
    );
  }
}
