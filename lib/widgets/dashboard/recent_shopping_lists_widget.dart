
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
import 'dashboard_section_header.dart'; // Import header

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
        DashboardSectionHeader(
           title: loc.shopping_lists,
           seeAllLabel: loc.see_all,
           onMoreTap: () {
              ref.read(dashboardIndexProvider.notifier).state = 1;
           },
        ),
        listState.when(
            data: (lists) {
                if (lists.isEmpty) {
                    return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(loc.no_shopping_lists_found, style: GoogleFonts.inter(color: Colors.grey)),
                    );
                }
                final lastList = lists.isNotEmpty ? lists.first : null;
                if (lastList == null){
                  return const SizedBox();
                }
                return _ListCard(list: lastList, user: user);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Padding(
               padding: const EdgeInsets.all(16),
               child: Text("Erreur: $err"),
            ),
        )
      ],
    );
  }
}

class _ListCard extends StatelessWidget {
    final ShoppingList list;
    final dynamic user;
    const _ListCard({required this.list, required this.user});

    @override
    Widget build(BuildContext context) {
        final loc = AppLocalizations.of(context)!;
        
        return Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            decoration: BoxDecoration(
                gradient: const LinearGradient(
                   colors: [AppColors.primary, Color(0xFFFF8A65)],
                   begin: Alignment.topLeft,
                   end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                    BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                    ),
                ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                  onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ShoppingListDetailPage(listId: list.id!, initialList: list),
                          ),
                      );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Container(
                           padding: const EdgeInsets.all(10),
                           decoration: BoxDecoration(
                             color: Colors.white.withOpacity(0.2),
                             shape: BoxShape.circle,
                           ),
                           child: const Icon(Icons.shopping_basket_rounded, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                list.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                  "${list.products.length} ${loc.products}",
                                  style: GoogleFonts.inter(color: Colors.white.withOpacity(0.9), fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 18),
                      ],
                    ),
                  ),
              ),
            ),
        );
    }
}
