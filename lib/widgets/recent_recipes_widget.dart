import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RecentRecipesWidget extends StatefulWidget {
  const RecentRecipesWidget({super.key});

  @override
  State<RecentRecipesWidget> createState() => _RecentRecipesWidgetState();
}

class _RecentRecipesWidgetState extends State<RecentRecipesWidget> {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchRecentRecipes() async {
    // Récupère les 3 dernières recettes ajoutées
    // Note : On suppose que vos colonnes sont 'nom', 'image_url' et 'created_at'
    final response = await supabase
        .from('Recettes')
        .select()
        .order('created_at', ascending: false)
        .limit(3);

    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Dernières Recettes",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/recipe'),
                child: const Text("Voir tout", style: TextStyle(color: Colors.orange)),
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
                child: Text("Erreur lors du chargement des recettes"),
              );
            }

            final recipes = snapshot.data ?? [];

            if (recipes.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("Aucune recette disponible."),
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
                  return Container(
                    width: 200, // Plus large pour un aspect "fiche recette"
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
                                  recipe['name'] ?? 'Recette sans nom',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.timer_outlined, size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      "${recipe['time_preparation'] ?? 'unknown'} min",
                                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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