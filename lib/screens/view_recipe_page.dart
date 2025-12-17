import 'package:flutter/material.dart';
import '../db_objects/shopping_lst.dart';
import '../l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:SmartBites/db_objects/cached_product.dart';
import './shopping_list.dart';

class ViewRecipePage extends StatelessWidget {
  final Map<String, dynamic> recipe;

  const ViewRecipePage({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final List<Map<String, dynamic>> ingredients =
        (recipe['ingredients'] as List?)
            ?.map((e) => Map<String, dynamic>.from(e))
            .toList() ??
            [];

    const Color peach = Color(0xFFFFCBA4);
    const Color peachDark = Color(0xFFFFA86F);

    Future<void> _createShoppingListFromRecipe(BuildContext context) async {
      final supabase = Supabase.instance.client;

      // Récupération des ingrédients
      final allIngredients = (recipe['ingredients'] as List?)
          ?.map((e) => Map<String, dynamic>.from(e))
          .toList() ??
          [];

      if (allIngredients.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Aucun ingrédient trouvé.")),
        );
        return;
      }

      // Créer la liste complète avec pseudo-code-barre pour les produits sans code-barres
      final products = allIngredients.map((ing) {
        final barcode = ing['barcode']?.toString();
        if (barcode != null && barcode.isNotEmpty) {
          return barcode;
        } else {
          // Remplacement par un identifiant textuel unique
          final name = (ing['name'] ?? 'Ingrédient').toString().trim();
          return "TEXT:$name";
        }
      }).toList();

      // Vérifier la session utilisateur
      final session = supabase.auth.currentSession;
      final user = session?.user;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Utilisateur non connecté.")),
        );
        return;
      }

      // Création de la nouvelle liste
      final listName = "${recipe['name']}";
      final newList = ShoppingList(
        name: listName,
        user_id: user.id,
        products: products,
      );

      try {
        final inserted = await supabase
            .from('shopping_list')
            .insert(newList.toMap())
            .select();

        print("Insertion réussie : $inserted");
        newList.id = inserted[0]['id'];
      } catch (e) {
        print("❌ Erreur lors de l'insertion Supabase : $e");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de la création : $e")),
        );
        return;
      }


      // Ajouter au cache (y compris les produits TEXT:)
      for (final ing in allIngredients) {
        final barcode = (ing['barcode']?.toString().isNotEmpty ?? false)
            ? ing['barcode'].toString()
            : "TEXT:${(ing['name'] ?? 'Ingrédient').toString().trim()}";

        final cached = CachedProduct(
          barcode: barcode,
          img_small_url: "",
          brands: ing['brand'] ?? "",
          fr_name: ing['name'] ?? "",
          en_name: ing['name'] ?? "",
        );

        await supabase.rpc("add_entry_to_cache", params: {
          "product_barcode": cached.barcode,
          "p_img_small_url": cached.img_small_url,
          "p_brands": cached.brands,
          "p_fr_name": cached.fr_name,
          "p_en_name": cached.en_name,
        });
      }

      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ShoppingListDetail(list: newList, user: user),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: peach,
        foregroundColor: Colors.white,
        title: Text(recipe['name'] ?? loc.recipe),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Description
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${loc.createdBy}: ${recipe['creator_name']}',
                      style: const TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: Colors.black54),
                    ),
                    Text(loc.description,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 8),
                    Text(recipe['description'] ?? '',
                        style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Time Preparation & Baking
            Row(
              children: [
                Expanded(
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    color: peach.withValues(alpha:0.3),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(Icons.timer, color: peachDark),
                          const SizedBox(height: 8),
                          Text(loc.preparation,
                              style:
                              const TextStyle(fontWeight: FontWeight.bold)),
                          Text('${recipe['time_preparation'] ?? 0} min'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    color: peach.withValues(alpha:0.3),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(Icons.local_fire_department, color: peachDark),
                          const SizedBox(height: 8),
                          Text(loc.baking,
                              style:
                              const TextStyle(fontWeight: FontWeight.bold)),
                          Text('${recipe['time_baking'] ?? 0} min'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Instructions
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(loc.instructions,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 8),
                      Text(recipe['instructions'] ?? '',
                          style: const TextStyle(fontSize: 16)),
                    ]),
              ),
            ),
            const SizedBox(height: 16),

            // Ingredients
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                    Text(loc.ingredients,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: peachDark
                        )
                    ),
                  CircleAvatar(
                    backgroundColor: peachDark,
                    radius: 30, // bump this up to fit text
                    child: InkWell(
                      onTap: () async {
                        await _createShoppingListFromRecipe(context);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shopping_cart, size: 18, color: Colors.white),
                          SizedBox(height: 2),
                          Text(
                            loc.add,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )

                ]
            ),
            const SizedBox(height: 8),
            if (ingredients.isEmpty)
              Text(loc.noIngredients,
                  style: const TextStyle(color: Colors.grey))
            else
              ...ingredients.map((ing) => Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                color: Colors.white,
                child: ListTile(
                  leading: const Icon(Icons.food_bank, color: peach),
                  title: Text(ing['name'] ?? 'Ingrédient'),
                  subtitle: (ing['barcode'] != null &&
                      ing['barcode'].toString().isNotEmpty)
                      ? Text('${loc.barcode}: ${ing['barcode']}')
                      : const Text("Sans code-barres"),
                ),
              )),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () async {
      //     await _createShoppingListFromRecipe(context);
      //   },
      //   label: const Text("Créer la liste de courses"),
      //   icon: const Icon(Icons.shopping_cart),
      //   backgroundColor: peachDark,
      // ),
    );
  }
}
