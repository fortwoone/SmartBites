import 'package:flutter/material.dart';
import 'package:food/screens/product_search_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';

class AddRecipePage extends StatefulWidget {
  final Map<String, dynamic>? recipeToEdit;

  const AddRecipePage({Key? key, this.recipeToEdit}) : super(key: key);

  @override
  State<AddRecipePage> createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _descriptionController = TextEditingController();
    final _timePreparationController = TextEditingController();
    final _timeBakingController = TextEditingController();
    final _instructionsController = TextEditingController();

    bool _loading = false;
    List<Map<String, dynamic>> _ingredients = [];
    bool get _isEditing => widget.recipeToEdit != null;

    final Color peach = const Color(0xFFFFCBA4); // couleur principale

    @override
    void initState() {
        super.initState();
        if (_isEditing) _loadRecipeData(widget.recipeToEdit!);
        _addListeners();
        if (!_isEditing) _loadSavedInputs();
    }

    void _addListeners() {
        _nameController.addListener(_saveInputs);
        _descriptionController.addListener(_saveInputs);
        _timePreparationController.addListener(_saveInputs);
        _timeBakingController.addListener(_saveInputs);
        _instructionsController.addListener(_saveInputs);
    }

    void _loadRecipeData(Map<String, dynamic> recipe) {
        _nameController.text = recipe['name'] ?? '';
        _descriptionController.text = recipe['description'] ?? '';
        _timePreparationController.text = recipe['time_preparation']?.toString() ?? '';
        _timeBakingController.text = recipe['time_baking']?.toString() ?? '';
        _instructionsController.text = recipe['instructions'] ?? '';
        final ingr = recipe['ingredients'];
        if (ingr is List) _ingredients = ingr.map((e) => Map<String, dynamic>.from(e)).toList();
    }

    @override
    void dispose() {
        _saveInputs();
        _nameController.dispose();
        _descriptionController.dispose();
        _timePreparationController.dispose();
        _timeBakingController.dispose();
        _instructionsController.dispose();
        super.dispose();
    }

    Future<void> _loadSavedInputs() async {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
          _nameController.text = prefs.getString('recipe_name') ?? '';
          _descriptionController.text = prefs.getString('recipe_description') ?? '';
          _timePreparationController.text = prefs.getString('recipe_time_prep') ?? '';
          _timeBakingController.text = prefs.getString('recipe_time_bake') ?? '';
          _instructionsController.text = prefs.getString('recipe_instructions') ?? '';
      });
    }

    Future<void> _saveInputs() async {
        if (_isEditing) return;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('recipe_name', _nameController.text);
        await prefs.setString('recipe_description', _descriptionController.text);
        await prefs.setString('recipe_time_prep', _timePreparationController.text);
        await prefs.setString('recipe_time_bake', _timeBakingController.text);
        await prefs.setString('recipe_instructions', _instructionsController.text);
    }

    Future<void> _clearSavedInputs() async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('recipe_name');
        await prefs.remove('recipe_description');
        await prefs.remove('recipe_time_prep');
        await prefs.remove('recipe_time_bake');
        await prefs.remove('recipe_instructions');
    }

    Future<void> _addIngredientDialog() async {
      final loc = AppLocalizations.of(context)!;

      final choice = await showDialog<String>(
            context: context,
            builder: (context) => SimpleDialog(
              title:  Text(loc.addIngredient),
              children: [
                  SimpleDialogOption(
                      onPressed: () => Navigator.pop(context, 'manual'),
                      child:  Text(loc.addIngredientManual),
                  ),
                  SimpleDialogOption(
                      onPressed: () => Navigator.pop(context, 'search'),
                      child:  Text(loc.addIngredientSearch),
                  ),
                  SimpleDialogOption(
                      onPressed: () => Navigator.pop(context, null),
                      child:  Text(loc.cancel),
                  ),
              ],
            ),
        );


        if (choice == 'manual') {
            final nameController = TextEditingController();
            final name = await showDialog<String>(
            context: context,
            builder: (context) => AlertDialog(
                title:  Text(loc.nameIngredient),
                content: TextField(
                    controller: nameController,
                    decoration:  InputDecoration(
                    labelText: loc.nameIngredient,
                    hintText: loc.hintIngredient
                    ),
                ),
                actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child:  Text(loc.cancel)),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: peach),
                        onPressed: () => Navigator.pop(context, nameController.text.trim()),
                        child:  Text(loc.add_product),
                    ),
                ],
                ),
            );
            if (name != null && name.isNotEmpty) setState(() => _ingredients.add({'name': name, 'barcode': null}));
        } else if (choice == 'search') {
            final product = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProductSearchPage(inAddMode: true)),
            );
            if (product != null && product.name != null) {
            setState(() => _ingredients.add({'name': product.name!, 'barcode': product.barcode}));
            }
        }


    }

    Future<void> _saveRecipe() async {
      final loc = AppLocalizations.of(context)!;

      if (!_formKey.currentState!.validate()) return;
        setState(() => _loading = true);

        final supabase = Supabase.instance.client;
        final user = supabase.auth.currentUser;

        try {
            if (!_isEditing) {
                await supabase.from('Recettes').insert({
                    'name': _nameController.text.trim(),
                    'description': _descriptionController.text.trim(),
                    'time_preparation': int.tryParse(_timePreparationController.text) ?? 0,
                    'time_baking': int.tryParse(_timeBakingController.text) ?? 0,
                    'instructions': _instructionsController.text.trim(),
                    'ingredients': _ingredients,
                    'user_id_creator': user?.id,
                });
                await _clearSavedInputs();
                _nameController.clear();
                _descriptionController.clear();
                _timePreparationController.clear();
                _timeBakingController.clear();
                _instructionsController.clear();
                setState(() => _ingredients = []);
            } else {
                await supabase.from('Recettes').insert({
                    'name': _nameController.text.trim(),
                    'description': _descriptionController.text.trim(),
                    'time_preparation': int.tryParse(_timePreparationController.text) ?? 0,
                    'time_baking': int.tryParse(_timeBakingController.text) ?? 0,
                    'instructions': _instructionsController.text.trim(),
                    'ingredients': _ingredients,
                    'user_id_creator': user?.id,
                });
                await _clearSavedInputs();
            }

            if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(_isEditing ? loc.updatedRecipe : loc.addedRecipe)),
                );
                Navigator.pop(context);
            }
        } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text( '${loc.error} : $e')),
        );
        } finally {
            if (mounted) setState(() => _loading = false);
        }
    }

    InputDecoration _inputDecoration(String label) {
        return InputDecoration(
            labelText: label,
            filled: true,
            fillColor: peach.withOpacity(0.15),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: peach, width: 2),
            ),
        );
    }

    @override
    Widget build(BuildContext context) {
      final loc = AppLocalizations.of(context)!;

      return Scaffold(
          appBar: AppBar(
              title: Text(_isEditing ? loc.updateRecipe : loc.addRecipe),
              backgroundColor: peach,
          ),
          body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                  key: _formKey,
                  child: ListView(
                      children: [
                          TextFormField(controller: _nameController, decoration: _inputDecoration(loc.nameRecipe), validator: (val) => val == null || val.isEmpty ? loc.enterName : null),
                          const SizedBox(height: 12),
                          TextFormField(controller: _descriptionController, decoration: _inputDecoration(loc.description), maxLines: 6),
                          const SizedBox(height: 12),
                          Row(
                              children: [
                                  Expanded(child: TextFormField(controller: _timePreparationController, decoration: _inputDecoration(loc.timePreparaing), keyboardType: TextInputType.number)),
                                  const SizedBox(width: 12),
                                  Expanded(child: TextFormField(controller: _timeBakingController, decoration: _inputDecoration(loc.timeBaking), keyboardType: TextInputType.number)),
                              ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                   Text(loc.ingredients, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  IconButton(icon: const Icon(Icons.add_circle_outline), color: peach, onPressed: _addIngredientDialog),
                              ],
                          ),
                          const SizedBox(height: 8),
                          _ingredients.isEmpty
                              ?  Text(loc.noIngredientsAdded, style: TextStyle(color: Colors.grey))
                              : Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _ingredients
                                      .map((ing) => Chip(
                                        label: Text(ing['name'] ?? loc.ingredients),
                                        backgroundColor: peach.withOpacity(0.3),
                                        deleteIconColor: Colors.red,
                                        onDeleted: () => setState(() => _ingredients.remove(ing)),
                                  ))
                                      .toList(),
                          )
                        ,
                        const SizedBox(height: 12),
                        TextFormField(controller: _instructionsController, decoration: _inputDecoration(loc.instructions), maxLines: 15, validator: (val) => val == null || val.isEmpty ? loc.enterInstructions : null),
                        const SizedBox(height: 20),
                          SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: peach, padding: const EdgeInsets.symmetric(vertical: 14)),
                                  onPressed: _loading ? null : _saveRecipe,
                                  child: _loading ? const CircularProgressIndicator(color: Colors.white) : Text(_isEditing ? loc.update : loc.addRecipe, style: const TextStyle(fontSize: 16)),
                              ),
                          ),
                      ],
                  ),
              ),
          ),
      );
    }
}
