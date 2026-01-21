
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                    ),
                ],
                border: Border.all(color: Colors.grey.withOpacity(0.05)),
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
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // Icone dans une bulle pastel
                        Container(
                           padding: const EdgeInsets.all(12),
                           decoration: BoxDecoration(
                             color: AppColors.primary.withOpacity(0.1), // Pastel Peach
                             borderRadius: BorderRadius.circular(12),
                           ),
                           child: const Icon(Icons.shopping_cart_outlined, color: AppColors.primary, size: 24),
                        ),
                        const SizedBox(width: 16),
                        // Textes
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                list.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary, // Dark text
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                  "${list.products.length} ${loc.products}",
                                  style: GoogleFonts.inter(color: Colors.grey, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        // Arrow
                        Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey.shade300, size: 16),
                      ],
                    ),
                  ),
              ),
            ),
        );
    }
}
