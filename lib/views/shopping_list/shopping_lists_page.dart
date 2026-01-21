import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../l10n/app_localizations.dart';
import '../../models/shopping_list.dart';
import '../../utils/color_constants.dart';
import '../../viewmodels/shopping_list_viewmodel.dart';
import '../../widgets/common/custom_page_header.dart';
import 'shopping_list_detail_page.dart';

class ShoppingListsPage extends ConsumerStatefulWidget {
  const ShoppingListsPage({super.key});
  @override
  ConsumerState<ShoppingListsPage> createState() => _ShoppingListsPageState();
}

class _ShoppingListsPageState extends ConsumerState<ShoppingListsPage> {
  final Set<int> _selectedListIds = {};
  bool get _isSelectionMode => _selectedListIds.isNotEmpty;
  
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final shoppingListsAsync = ref.watch(shoppingListViewModelProvider);

    return Scaffold(
      extendBodyBehindAppBar: true, 
      body: Stack(
        children: [
          shoppingListsAsync.when(
            data: (lists) {
              if (lists.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       Container(
                         padding: const EdgeInsets.all(20),
                         decoration: BoxDecoration(
                           color: AppColors.primary.withOpacity(0.1),
                           shape: BoxShape.circle,
                         ),
                         child: Icon(Icons.shopping_cart_outlined, size: 40, color: AppColors.primary.withOpacity(0.5)),
                       ),
                       const SizedBox(height: 16),
                       Text(
                         loc.no_list_create_one, 
                         style: GoogleFonts.inter(color: Colors.grey, fontSize: 16),
                         textAlign: TextAlign.center,
                       ),
                    ],
                  ),
                );
              }
              return ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(top: 110, left: 20, right: 20, bottom: 100),
                itemCount: lists.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final list = lists[index];
                  final isSelected = _selectedListIds.contains(list.id);
                  return _ShoppingListCard(
                    list: list,
                    isSelected: isSelected,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ShoppingListDetailPage(listId: list.id!, initialList: list)),
                    ),
                    onCheckboxTap: () => _toggleSelection(list.id!),
                    onDelete: () => _confirmDelete(context, list, loc),
                    onRename: () => _showRenameDialog(context, list, loc),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text("Error: $err")),
          ),
          Positioned(
            top: 0, 
            left: 0, 
            right: 0,
            child: _isSelectionMode
                ? _buildSelectionHeader(shoppingListsAsync.value ?? [])
                : CustomPageHeader(
                    title: loc.shopping_lists,
                    onAddTap: () => _showAddDialog(context, loc),
                  ),
          ),
        ],
      ),
    );
  }
  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextField(
        controller: controller,
        style: GoogleFonts.inter(fontSize: 15, color: Colors.black87),
        autofocus: true,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 13),
          floatingLabelStyle: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.bold),
          filled: false,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }

  Future<T?> _showStyledDialog<T>({
    required BuildContext context,
    required String title,
    required String subtitle,
    required Widget content,
    required Future<void> Function() onConfirm,
    required String confirmText,
    required Color confirmColor,
    required IconData icon,
    bool isLoading = false,
  }) {
    return showDialog<T>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
             return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              backgroundColor: Colors.white,
              elevation: 0,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: confirmColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: confirmColor, size: 32),
                      ),
                    ),
                    Text(
                      title,
                      style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade500),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    content,
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: isLoading ? null : () => Navigator.pop(context),
                             style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.cancel,
                              style: GoogleFonts.inter(color: Colors.grey.shade600, fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: confirmColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: isLoading ? null : () async {
                              setState(() => isLoading = true);
                              try {
                                await onConfirm();
                              } finally {
                                if (context.mounted) {
                                  setState(() => isLoading = false);
                                }
                              }
                            },
                             child: isLoading
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : Text(confirmText, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
        );
      }
    );
  }

  // Ajout d'une nouvelle liste
  Future<void> _showAddDialog(BuildContext context, AppLocalizations loc) async {
    final controller = TextEditingController();
    await _showStyledDialog(
      context: context,
      title: loc.new_list,
      subtitle: "Créez une nouvelle liste pour organiser vos courses.",
      icon: Icons.post_add_rounded,
      confirmColor: AppColors.primary,
      confirmText: loc.validate,
      content: _buildDialogTextField(controller: controller, label: loc.name_list),
      onConfirm: () async {
         if (controller.text.isNotEmpty) {
           await ref.read(shoppingListViewModelProvider.notifier).createList(controller.text.trim());
           if (context.mounted) Navigator.pop(context);
         }
      },
    );
  }

  // Renommer une liste existante
  Future<void> _showRenameDialog(BuildContext context, ShoppingList list, AppLocalizations loc) async {
    final controller = TextEditingController(text: list.name);
    await _showStyledDialog(
      context: context,
      title: loc.rename,
      subtitle: "Changez le nom de votre liste.",
      icon: Icons.edit_rounded,
      confirmColor: AppColors.primary,
      confirmText: loc.validate,
      content: _buildDialogTextField(controller: controller, label: loc.name_list),
      onConfirm: () async {
         if (controller.text.isNotEmpty) {
           await ref.read(shoppingListViewModelProvider.notifier).renameList(list, controller.text.trim());
           if (context.mounted) Navigator.pop(context);
         }
      },
    );
  }

  // Confirmer la suppression d'une liste
  Future<void> _confirmDelete(BuildContext context, ShoppingList list, AppLocalizations loc) async {
     await _showStyledDialog(
      context: context,
      title: loc.delete_list,
      subtitle: loc.confirm,
      icon: Icons.delete_forever_rounded,
      confirmColor: AppColors.error,
      confirmText: loc.delete,
      content: const SizedBox.shrink(),
      onConfirm: () async {
         if (list.id != null) {
            await ref.read(shoppingListViewModelProvider.notifier).deleteList(list.id!);
            if (context.mounted) Navigator.pop(context);
         }
      },
    );
  }

  // ---------------------------------------------------------------------------
  // SELECTION MODE METHODS
  // ---------------------------------------------------------------------------
  
  void _toggleSelection(int listId) {
    setState(() {
      if (_selectedListIds.contains(listId)) {
        _selectedListIds.remove(listId);
      } else {
        _selectedListIds.add(listId);
      }
    });
  }

  Future<void> _deleteSelectedLists() async {
    if (_selectedListIds.isEmpty) return;
    
    for (final listId in _selectedListIds) {
      await ref.read(shoppingListViewModelProvider.notifier).deleteList(listId);
    }
    
    setState(() => _selectedListIds.clear());
  }

  Widget _buildSelectionHeader(List<ShoppingList> allLists) {
    final loc = AppLocalizations.of(context)!;
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 8,
            bottom: 16,
            left: 16,
            right: 16,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _selectedListIds.clear()),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.close_rounded, size: 22, color: Colors.black87),
                ),
              ),
              
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  "${_selectedListIds.length} sélectionnée${_selectedListIds.length > 1 ? 's' : ''}",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (_selectedListIds.length == allLists.length) {
                      _selectedListIds.clear();
                    } else {
                      _selectedListIds.addAll(allLists.map((l) => l.id!));
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _selectedListIds.length == allLists.length 
                      ? Icons.deselect_rounded 
                      : Icons.select_all_rounded, 
                    size: 22, 
                    color: Colors.black87
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _deleteSelectedLists,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.error.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.white),
                      const SizedBox(width: 6),
                      Text(
                        loc.delete,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShoppingListCard extends StatelessWidget {
  final ShoppingList list;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onCheckboxTap;
  final VoidCallback onDelete;
  final VoidCallback onRename;

  const _ShoppingListCard({
    required this.list, 
    required this.isSelected,
    required this.onTap, 
    required this.onCheckboxTap,
    required this.onDelete, 
    required this.onRename,
  });


  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withOpacity(0.08) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
           BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
        border: Border.all(
          color: isSelected ? AppColors.primary.withOpacity(0.3) : Colors.grey.withOpacity(0.05),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onCheckboxTap,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                ),
                Container(
                   padding: const EdgeInsets.all(12),
                   decoration: BoxDecoration(
                     color: AppColors.primary.withOpacity(0.1),
                     borderRadius: BorderRadius.circular(12),
                   ),
                   child: const Icon(Icons.shopping_cart_outlined, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        list.name, 
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600, 
                          fontSize: 16,
                          color: AppColors.textPrimary
                        )
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${list.products.length} ${loc.products}", 
                        style: GoogleFonts.inter(color: Colors.grey, fontSize: 13)
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  icon: Icon(Icons.more_vert_rounded, color: Colors.grey.shade400),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  position: PopupMenuPosition.under,
                  onSelected: (value) {
                    if (value == 'rename') onRename();
                    if (value == 'delete') onDelete();
                  },
                  itemBuilder: (context) => [
                     PopupMenuItem(
                       value: 'rename', 
                       child: Row(children: [
                         const Icon(Icons.edit, size: 18, color: Colors.black87), 
                         const SizedBox(width: 12), 
                         Text(loc.rename, style: GoogleFonts.inter(fontSize: 14))
                       ])
                     ),
                     PopupMenuItem(
                       value: 'delete', 
                       child: Row(children: [
                         const Icon(Icons.delete_outline, color: AppColors.error, size: 18), 
                         const SizedBox(width: 12), 
                         Text(loc.delete, style: GoogleFonts.inter(color: AppColors.error, fontSize: 14))
                       ])
                     ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


