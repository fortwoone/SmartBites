import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:SmartBites/screens/view_recipe_page.dart';
import '../utils/color_constants.dart';
import '../l10n/app_localizations.dart';

class RecentRecipesWidget extends StatefulWidget {
  const RecentRecipesWidget({super.key});

  @override
  State<RecentRecipesWidget> createState() => _RecentRecipesWidgetState();
}

class _RecentRecipesWidgetState extends State<RecentRecipesWidget> {
  final SupabaseClient supabase = Supabase.instance.client;

  // Contrôleur pour le défilement
  final PageController _pageController = PageController(viewportFraction: 0.95);

  // Variable pour stocker l'index actuel et le futur des données
  int _currentPage = 0;
  late Future<List<Map<String, dynamic>>> _recipesFuture;

  @override
  void initState() {
    super.initState();
    // On initialise le chargement une seule fois ici
    _recipesFuture = fetchRecentRecipes();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> fetchRecentRecipes() async {
    // Récupère les 3 dernières recettes
    final response = await supabase
        .from('Recettes')
        .select()
        .order('created_at', ascending: false)
        .limit(3);

    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- EN-TÊTE : Titre et bouton "Voir tout" ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                loc.last_recipes,
                style: GoogleFonts.recursive(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/recipe'),
                child: Text(
                    loc.see_all,
                    style: GoogleFonts.recursive(color: primaryPeach)
                ),
              ),
            ],
          ),
        ),

        // --- CORPS : FutureBuilder pour charger les données ---
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _recipesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                  height: 230,
                  child: Center(child: CircularProgressIndicator())
              );
            }

            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(loc.charge_recipe_error),
              );
            }

            final recipes = snapshot.data ?? [];

            if (recipes.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(loc.no_recipes),
              );
            }

            return Column(
              children: [
                // Zone de défilement (PageView)
                SizedBox(
                  height: ((MediaQuery.of(context).size.width) * 0.65).clamp(200.0, 350.0),
                  child: PageView.builder(
                    clipBehavior: Clip.none,
                    controller: _pageController,
                    itemCount: recipes.length,
                    onPageChanged: (int index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final recipe = recipes[index];
                      return _buildRecipeCard(recipe);
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // --- INDICATEUR DE POINTS (DOTS) ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    recipes.length,
                        (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: _currentPage == index ? 20 : 8, // Le point actif s'allonge
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? primaryPeach
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  // Widget personnalisé pour la carte de recette
  Widget _buildRecipeCard(Map<String, dynamic> recipe) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewRecipePage(recipe: recipe),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(26),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image de la recette
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: recipe['image_url'] != null
                    ? Image.network(
                  recipe['image_url'],
                  fit: BoxFit.cover,
                  width: double.infinity,
                )
                    : Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.restaurant, color: Colors.grey, size: 40),
                ),
              ),
            ),
            // Informations (Nom et Temps)
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      recipe['name'] ?? 'Unknown',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.recursive(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          "${recipe['time_preparation'] ?? '??'} min",
                          style: GoogleFonts.recursive(
                              color: Colors.grey.shade600,
                              fontSize: 13
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}