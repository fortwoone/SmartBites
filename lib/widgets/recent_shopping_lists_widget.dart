import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:SmartBites/db_objects/shopping_lst.dart';
import 'package:SmartBites/screens/shopping_list.dart';
import 'package:SmartBites/l10n/app_localizations.dart';
import '../utils/color_constants.dart';

class RecentShoppingListsWidget extends StatefulWidget {
  const RecentShoppingListsWidget({super.key});

  @override
  State<RecentShoppingListsWidget> createState() => _RecentShoppingListsWidgetState();
}

class _RecentShoppingListsWidgetState extends State<RecentShoppingListsWidget> {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<ShoppingList>> fetchRecentLists() async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    final response = await supabase
        .from('shopping_list')
        .select()
        .eq('user_id', user.id)
        .order('id', ascending: false)
        .limit(3);

    return (response as List).map((lst) => ShoppingList.fromMap(lst)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

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
                onPressed: () => Navigator.pushNamed(context, '/shopping'),
                child: Text(loc.see_all, style: GoogleFonts.recursive(color: primaryPeach)),
              ),
            ],
          ),
        ),
        FutureBuilder<List<ShoppingList>>(
          future: fetchRecentLists(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final lists = snapshot.data ?? [];

            if (lists.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(loc.no_shopping_lists_found),
              );
            }

            return Column(
              children: lists.map((lst) => _buildListCard(context, lst)).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildListCard(BuildContext context, ShoppingList lst) {
    final loc = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: primaryPeach,
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
          lst.name,
          style: GoogleFonts.recursive(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          "${lst.products.length} ${loc.products}",
          style: GoogleFonts.recursive(color: Colors.white.withAlpha(200)),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ShoppingListDetail(
                list: lst,
                user: supabase.auth.currentUser,
              ),
            ),
          );
        },
      ),
    );
  }
}