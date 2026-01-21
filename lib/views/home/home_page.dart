import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/color_constants.dart';
import '../../widgets/profile/avatar_widget.dart';
import '../../widgets/navigation/bottom_nav_bar.dart';
import '../../widgets/dashboard/recent_products_widget.dart';
import '../../widgets/dashboard/recent_recipes_widget.dart';
import '../../widgets/dashboard/recent_shopping_lists_widget.dart';
import '../../providers/app_providers.dart';
import '../shopping_list/shopping_lists_page.dart';
import '../recipes/recipes_page.dart';
import '../product/product_search_page.dart';
import '../profile/profile_page.dart';
import '../../viewmodels/auth_viewmodel.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final currentIndex = ref.watch(dashboardIndexProvider);
    final authState = ref.watch(authViewModelProvider);
    final user = authState.value;

    // Pages pour la navigation
    final List<Widget> pages = [
      _buildDashboard(loc),
      const ShoppingListsPage(),
      const RecipesPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'lib/ressources/logo_App.png',
            fit: BoxFit.contain,
          ),
        ),
        title: Text(
          'SmartBites',
          style: GoogleFonts.recursive(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProductSearchPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) {
          ref.read(dashboardIndexProvider.notifier).state = index;
        },
        userAvatarUrl: user?.avatarUrl,
        homeLabel: loc.home_menu,
        cartLabel: loc.shopping_lists,
        recipesLabel: loc.recipes_menu,
        profileLabel: loc.my_account,
      ),
    );
  }

  // Tableau de bord avec les widgets récents
  Widget _buildDashboard(AppLocalizations loc) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: const [
          SizedBox(height: 12),
          RecentProductsWidget(),
          SizedBox(height: 16),
          RecentRecipesWidget(),
          SizedBox(height: 16),
          RecentShoppingListsWidget(),
          SizedBox(height: 30),
        ],
      ),
    );
  }
}