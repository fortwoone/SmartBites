import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/navigation/bottom_nav_bar.dart';
import '../../widgets/dashboard/recent_products_widget.dart';
import '../../widgets/dashboard/recent_recipes_widget.dart';
import '../../widgets/dashboard/recent_shopping_lists_widget.dart';
import '../../widgets/common/custom_home_header.dart';
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
    final List<Widget> pages = [
      _buildDashboard(context), // Modification ici pour passer le contexte si besoin
      const ShoppingListsPage(),
      const RecipesPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      extendBody: true, // Pour que la navbar du bas soit flottante si on veut (optionnel, mais sympa avec glassmorphism)
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

  // Tableau de bord avec header custom et widgets récents
  Widget _buildDashboard(BuildContext context) {
    return Stack(
      children: [
        // Contenu scrollable
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(top: 100, bottom: 100), // Padding pour le header et la nav bar
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
        ),
        
        // Header Custom Fixe (Glassmorphism)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: CustomHomeHeader(
             onSearchTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProductSearchPage(),
                  ),
                );
             },
          ),
        ),
      ],
    );
  }
}