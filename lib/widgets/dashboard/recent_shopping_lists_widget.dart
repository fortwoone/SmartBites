
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/app_providers.dart';

import '../../l10n/app_localizations.dart';
import '../../models/shopping_list.dart';
import '../../utils/color_constants.dart';
import '../../viewmodels/shopping_list_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../views/shopping_list/shopping_list_detail_page.dart';

class RecentShoppingListsWidget extends ConsumerWidget {
  const RecentShoppingListsWidget({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final listState = ref.watch(shoppingListViewModelProvider);
    final user = ref.watch(authViewModelProvider).value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                loc.shopping_lists,
                style: GoogleFonts.recursive(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                   ref.read(dashboardIndexProvider.notifier).state = 2;
                },
                child: Text(loc.see_all, style: GoogleFonts.recursive(color: AppColors.primary)),
              ),
            ],
          ),
        ),
        listState.when(
            data: (lists) {
                if (lists.isEmpty) {
                    return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(loc.no_shopping_lists_found),
                    );
                }
                final lastList = lists.isNotEmpty ? lists.first : null;
                if (lastList == null){
                  return const SizedBox();
                }
                return _ListCard(list: lastList, user: user);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text("Erreur: $err"),
        )
      ],
    );
  }
}

// Widget pour une carte de liste de courses
class _ListCard extends StatelessWidget {
    final ShoppingList list;
    final dynamic user;
    const _ListCard({required this.list, required this.user});

    @override
    Widget build(BuildContext context) {
        final loc = AppLocalizations.of(context)!;
        return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                    BoxShadow(
                        color: Colors.black.withAlpha(26),
                        blurRadius: 4,
                        offset: const Offset(2, 2),
                    ),
                ],
            ),
            child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                title: Text(
                    list.name,
                    style: GoogleFonts.recursive(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                    ),
                ),
                subtitle: Text(
                    "${list.products.length} ${loc.products}",
                    style: GoogleFonts.recursive(color: Colors.white.withAlpha(200)),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ShoppingListDetailPage(listId: list.id!, initialList: list),
                        ),
                    );
                },
            ),
        );
    }
}
