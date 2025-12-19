import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';
import '../utils/color_constants.dart';
import '../widgets/primary_button.dart';
import '../widgets/recipe/recipe_detail_header.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class ViewRecipePage extends StatefulWidget {
  final Map<String, dynamic> recipe;

  const ViewRecipePage({super.key, required this.recipe});

  @override
  State<ViewRecipePage> createState() => _ViewRecipePageState();
}

class _ViewRecipePageState extends State<ViewRecipePage> {
    bool _isLoading = false;
    late final loc = AppLocalizations.of(context)!;


    Future<void> _addToShoppingList() async {
        final client = Supabase.instance.client;
        final user = client.auth.currentUser;

        if (user == null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.have_to_be_connected_to_create_list)));
            return;
        }

        setState(() => _isLoading = true);

        try {
            final ingredients = List<Map<String, dynamic>>.from(widget.recipe['ingredients'] ?? []);
            final List<String> products = [];
            final Map<String, int> quantities = {};

            for (var ing in ingredients) {
                String? barcode = ing['barcode'];
                String name = ing['name'] ?? 'Ingrédient';

                String key;
                if (barcode != null && barcode.isNotEmpty) {
                    key = barcode;
                } else {
                    key = "TEXT:$name";
                }
                
                products.add(key);
                quantities[key] = 1; 
            }

            final listName = "${loc.recipe} ${widget.recipe['name']}";
            
            await client.from('shopping_list').insert({
                'name': listName,
                'user_id': user.id,
                'products': products,
                'quantities': quantities
            });

            if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.list_added)));
            }
        } catch (e) {
            if (mounted) {
                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${loc.error}: $e")));
            }
        } finally {
            if (mounted) setState(() => _isLoading = false);
        }
    }

    @override
    Widget build(BuildContext context) {
      final loc = AppLocalizations.of(context)!;
      final recipe = widget.recipe;

      final description = (recipe['description'] ?? '').toString();
      final timePrep = recipe['time_preparation'] ?? 0;
      final timeBaking = recipe['time_baking'] ?? 0;
      final creatorName = recipe['creator_name'] ?? 'Inconnu';

      List<Map<String, dynamic>> ingredients = [];
      if (recipe['ingredients'] != null) {
          ingredients = List<Map<String, dynamic>>.from(recipe['ingredients']);
      }

      final instructions = (recipe['instructions'] ?? '').toString();
      return Scaffold(
        body: CustomScrollView(
          slivers: [
            RecipeDetailHeader(recipe: recipe),
            SliverList(
              delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                    BoxShadow(
                                        color: Colors.grey.withAlpha(20),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                    ),
                                ],
                            ),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    Text(
                                        description.isNotEmpty ? description : loc.description,
                                        style: GoogleFonts.recursive(fontSize: 16, color: Colors.grey.shade700, height: 1.5),
                                    ),
                                    const SizedBox(height: 16),
                                     Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                            Row(children: [const Icon(Icons.timer, size: 18, color: primaryPeach), const SizedBox(width: 4), Text('$timePrep min', style: GoogleFonts.recursive(fontWeight: FontWeight.bold))]),
                                            Row(children: [const Icon(Icons.local_fire_department, size: 18, color: Colors.orangeAccent), const SizedBox(width: 4), Text('$timeBaking min', style: GoogleFonts.recursive(fontWeight: FontWeight.bold))]),
                                        ],
                                    ),
                                    const SizedBox(height: 8),
                                    Divider(color: Colors.grey.shade100),
                                    const SizedBox(height: 8),
                                     Text('${loc.createdBy}: $creatorName', style: GoogleFonts.recursive(color: Colors.grey.shade400, fontStyle: FontStyle.italic)),
                                ],
                            ),
                        ),
                        const SizedBox(height: 24),

                      Text(loc.ingredients, style: GoogleFonts.recursive(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 12),
                       Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                    BoxShadow(
                                        color: Colors.grey.withAlpha(20),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                    ),
                                ],
                            ),
                            child: ingredients.isEmpty
                                ? Text(loc.noIngredients, style: GoogleFonts.recursive(color: Colors.grey))
                                : Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: ingredients.map((ing) {
                                        return Chip(
                                            label: Text(ing['name'] ?? '', style: GoogleFonts.recursive(color: Colors.black87)),
                                            backgroundColor: primaryPeach.withOpacity(0.15),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide.none),
                                        );
                                    }).toList(),
                                ),
                       ),

                      const SizedBox(height: 24),
                      Text(loc.instructions, style: GoogleFonts.recursive(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 12),
                       if (instructions.isEmpty)
                         Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                    BoxShadow(
                                        color: Colors.grey.withAlpha(20),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                    ),
                                ],
                            ),
                            child: Text(
                                loc.no_instructions,
                                style: GoogleFonts.recursive(fontSize: 16, height: 1.6, color: Colors.black87),
                            ),
                       )
                       else
                        ...instructions.split('\n').asMap().entries.map((entry) {
                            final index = entry.key;
                            final step = entry.value;
                            if (step.trim().isEmpty) return const SizedBox.shrink();
                            return Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                        BoxShadow(
                                            color: Colors.grey.withAlpha(20),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                        ),
                                    ],
                                ),
                                child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                        CircleAvatar(
                                            radius: 14,
                                            backgroundColor: primaryPeach.withOpacity(0.2),
                                            child: Text("${index + 1}", style: GoogleFonts.recursive(fontSize: 14, fontWeight: FontWeight.bold, color: primaryPeach)),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                            child: Text(
                                                step,
                                                style: GoogleFonts.recursive(fontSize: 16, height: 1.6, color: Colors.black87),
                                            ),
                                        ),
                                    ],
                                ),
                            );
                        }),


                      const SizedBox(height: 40),
                      Center(
                          child: PrimaryButton(
                              onPressed: _addToShoppingList,
                              label: loc.add_to_grocery_list,
                              icon: Icons.shopping_basket_outlined,
                              isLoading: _isLoading,
                          ),
                      ),
                       const SizedBox(height: 40),

                    ],
                  ),
                ),
              ]),
            ),
          ],
        ),
      );
    }
}
