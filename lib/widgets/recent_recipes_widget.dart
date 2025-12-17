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

  Future<List<Map<String, dynamic>>> fetchRecentRecipes() async {
    // Récupère les 3 dernières recettes ajoutées
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                loc.last_recipes,
                style: GoogleFonts.recursive(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/recipe'),
                child: Text(loc.see_all, style: GoogleFonts.recursive(color: primaryPeach)),
              ),
            ],
          ),
        ),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchRecentRecipes(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(height: 180, child: Center(child: CircularProgressIndicator()));
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
                padding: EdgeInsets.all(16.0),
                child: Text(loc.no_recipes),
              );
            }

            return SizedBox(
              height: 200, // Un peu plus haut pour les recettes
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: recipes.length,
                itemBuilder: (context, index) {
                  final recipe = recipes[index];
                  return GestureDetector( // <--- détecteur de clic
                      onTap: () {
                        // Action au clic : Navigation vers la page de détail
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewRecipePage(recipe: recipe),
                          ),
                        );
                      },
                    child: Container(
                      width: 200,
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                              child: recipe['image_url'] != null
                                  ? Image.network(
                                recipe['image_url'],
                                fit: BoxFit.cover,
                                width: double.infinity,
                              )
                                  : Container(
                                color: Colors.grey[200],
                                child: const Icon(Icons.restaurant, color: Colors.grey),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    recipe['name'] ?? 'unknown',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.recursive(color: Colors.black, fontSize: 14),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.timer_outlined, size: 14, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(
                                        "${recipe['time_preparation'] ?? 'unknown'} min",
                                        style: GoogleFonts.recursive(color: Colors.grey.shade600, fontSize: 12),
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
                },
              ),
            );
          },
        ),
      ],
    );
  }
}