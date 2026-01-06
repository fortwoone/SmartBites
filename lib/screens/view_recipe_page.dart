import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';
import '../utils/color_constants.dart';
import '../widgets/primary_button.dart';
import '../widgets/recipe/recipe_detail_header.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';

class ViewRecipePage extends StatefulWidget {
  final Map<String, dynamic> recipe;
  const ViewRecipePage({super.key, required this.recipe});

  @override
  State<ViewRecipePage> createState() => _ViewRecipePageState();
}

class _ViewRecipePageState extends State<ViewRecipePage> {
  bool _isLoading = false;
  bool _savingNote = false;
  int _selectedRating = 0;
  final _noteController = TextEditingController();
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingNote();
    });
  }

  void _loadExistingNote() {
    final noteData = widget.recipe['notes'];

    if (noteData != null) {
      Map<String, dynamic>? data;

      if (noteData is Map<String, dynamic>) {
        data = noteData;
      } else if (noteData is String) {
        try {
          data = jsonDecode(noteData);
        } catch (_) {}
      } else if (noteData is List && noteData.isNotEmpty) {
        final user = supabase.auth.currentUser;
        if (user != null) {
          for (var note in noteData) {
            if (note['author'] == user.id) {
              data = Map<String, dynamic>.from(note);
              break;
            }
          }
        }
      }

      if (data != null) {
        _noteController.text = data['note'] ?? '';
        _selectedRating = data['rating'] ?? 0;
      }
    }

    setState(() {});
  }

  Future<void> _saveNoteAndRating() async {
    final id = int.tryParse(widget.recipe['id'].toString());
    final user = supabase.auth.currentUser;
    final loc = AppLocalizations.of(context)!;

    if (user == null || id == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(loc.error)));
      return;
    }

    setState(() => _savingNote = true);

    try {
      dynamic notesData = widget.recipe['notes'];
      List<dynamic> existingNotes = [];

      if (notesData is List) {
        existingNotes = notesData;
      } else if (notesData is Map) {
        existingNotes = [notesData];
      }

      final newNote = {
        'note': _noteController.text.trim(),
        'rating': _selectedRating,
        'author': user.id,
      };

      bool updated = false;
      for (int i = 0; i < existingNotes.length; i++) {
        final note = existingNotes[i];
        if (note is Map && note['author'] == user.id) {
          existingNotes[i] = newNote;
          updated = true;
          break;
        }
      }
      if (!updated) existingNotes.add(newNote);

      final response = await supabase
          .from('Recettes')
          .update({'notes': existingNotes})
          .eq('id', id)
          .select();

      if (!mounted) return;

      if (response.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("⚠ ${loc.error}: row not found")));
        return;
      }

      widget.recipe['notes'] = response.first['notes'];
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("✔ ${loc.successComment}")));
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("${loc.error}: $e")));
    } finally {
      if (mounted) setState(() => _savingNote = false);
    }
  }

  Widget _buildStarSelector() {
    return Row(
      children: List.generate(5, (i) {
        final starValue = i + 1;
        return IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: Icon(
            starValue <= _selectedRating ? Icons.star : Icons.star_border,
            size: 30,
            color: primaryPeach,
          ),
          onPressed: () => setState(() => _selectedRating = starValue),
        );
      }),
    );
  }

  Widget _buildCommentsSection() {
    final notesData = widget.recipe['notes'];
    List<Map<String, dynamic>> notes = [];

    if (notesData is Map) {
      notes = [Map<String, dynamic>.from(notesData)];
    } else if (notesData is List) {
      notes = notesData.map((e) => Map<String, dynamic>.from(e)).toList();
    }

    if (notes.isEmpty) return _emptyBox("Aucun commentaire pour l'instant.");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: notes.map((note) {
        final rating = note['rating'] ?? 0;
        final text = note['note'] ?? '';
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRatingStars(rating),
              const SizedBox(height: 4),
              Text(text, style: GoogleFonts.recursive()),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRatingStars(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        return Icon(
          i < rating ? Icons.star : Icons.star_border,
          size: 18,
          color: primaryPeach,
        );
      }),
    );
  }

  Future<void> _addToShoppingList() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    final loc = AppLocalizations.of(context)!;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.have_to_be_connected_to_create_list)));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final ingredients =
      List<Map<String, dynamic>>.from(widget.recipe['ingredients'] ?? []);
      final List<String> products = [];
      final Map<String, int> quantities = {};

      for (var ing in ingredients) {
        String? barcode = ing['barcode'];
        String name = ing['name'] ?? 'Ingrédient';
        final key = (barcode != null && barcode.isNotEmpty) ? barcode : "TEXT:$name";
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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(loc.list_added)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("${loc.error}: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _emptyBox(String text) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
    child: Text(text, style: GoogleFonts.recursive()),
  );

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final recipe = widget.recipe;

    final description = (recipe['description'] ?? '').toString();
    final timePrep = recipe['time_preparation'] ?? 0;
    final timeBaking = recipe['time_baking'] ?? 0;
    final creatorName = recipe['creator_name'] ?? 'Inconnu';
    final instructions = (recipe['instructions'] ?? '').toString();

    List<Map<String, dynamic>> ingredients = [];
    if (recipe['ingredients'] != null) {
      ingredients = List<Map<String, dynamic>>.from(recipe['ingredients']);
    }

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
                    // --- Description and times ---
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
                              offset: const Offset(0, 4))
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            description.isNotEmpty ? description : loc.description,
                            style: GoogleFonts.recursive(
                                fontSize: 16,
                                color: Colors.grey.shade700,
                                height: 1.5),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(children: [
                                const Icon(Icons.timer, size: 18, color: primaryPeach),
                                const SizedBox(width: 4),
                                Text('$timePrep min',
                                    style: GoogleFonts.recursive(
                                        fontWeight: FontWeight.bold)),
                              ]),
                              Row(children: [
                                const Icon(Icons.local_fire_department,
                                    size: 18, color: Colors.orangeAccent),
                                const SizedBox(width: 4),
                                Text('$timeBaking min',
                                    style: GoogleFonts.recursive(
                                        fontWeight: FontWeight.bold)),
                              ]),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Divider(color: Colors.grey.shade100),
                          const SizedBox(height: 8),
                          Text('${loc.createdBy}: $creatorName',
                              style: GoogleFonts.recursive(
                                  color: Colors.grey.shade400,
                                  fontStyle: FontStyle.italic)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    // --- Ingredients ---
                    Text(loc.ingredients,
                        style: GoogleFonts.recursive(
                            fontSize: 22, fontWeight: FontWeight.bold)),
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
                              offset: const Offset(0, 4))
                        ],
                      ),
                      child: ingredients.isEmpty
                          ? Text(loc.noIngredients,
                          style: GoogleFonts.recursive(color: Colors.grey))
                          : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ingredients
                            .map((ing) => Chip(
                          label: Text(ing['name'] ?? '',
                              style: GoogleFonts.recursive(
                                  color: Colors.black87)),
                          backgroundColor:
                          primaryPeach.withOpacity(0.15),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(12)),
                        ))
                            .toList(),
                      ),
                    ),

                    const SizedBox(height: 24),
                    // --- Instructions ---
                    Text(loc.instructions,
                        style: GoogleFonts.recursive(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    if (instructions.isEmpty)
                      _emptyBox(loc.no_instructions)
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
                                  offset: const Offset(0, 4))
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: primaryPeach.withOpacity(0.2),
                                child: Text("${index + 1}",
                                    style: GoogleFonts.recursive(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: primaryPeach)),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                  child: Text(step,
                                      style: GoogleFonts.recursive(
                                          fontSize: 16,
                                          height: 1.6,
                                          color: Colors.black87))),
                            ],
                          ),
                        );
                      }),

                    const SizedBox(height: 30),
                    // --- Rate & Comment ---
                    Text("⭐ ${loc.rateAndComment}",
                        style: GoogleFonts.recursive(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildStarSelector(),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.withAlpha(20),
                              blurRadius: 6,
                              offset: const Offset(0, 3))
                        ],
                      ),
                      child: TextField(
                        controller: _noteController,
                        decoration: InputDecoration(
                          hintText: "📝 ${loc.description}",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.all(12),
                        ),
                        style: GoogleFonts.recursive(fontSize: 15, color: Colors.black87),
                        maxLines: 3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: _savingNote ? null : _saveNoteAndRating,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryPeach,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: _savingNote
                            ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.save, size: 18),
                        label: Text(loc.addComment,
                            style: GoogleFonts.recursive(fontWeight: FontWeight.bold)),
                      ),
                    ),

                    const SizedBox(height: 40),
                    // --- Shopping List Button ---
                    Center(
                      child: PrimaryButton(
                        onPressed: _addToShoppingList,
                        label: loc.add_to_grocery_list,
                        icon: Icons.shopping_basket_outlined,
                        isLoading: _isLoading,
                      ),
                    ),

                    const SizedBox(height: 40),
                    // --- Comments Section ---
                    Text("💬 ${loc.comments}",
                        style: GoogleFonts.recursive(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildCommentsSection(),
                    const SizedBox(height: 40),
                  ],
                ),
              )
            ]),
          )
        ],
      ),
    );
  }
}
