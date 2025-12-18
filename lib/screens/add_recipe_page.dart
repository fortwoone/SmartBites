import 'package:flutter/material.dart';
import 'package:SmartBites/screens/product_search_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../l10n/app_localizations.dart';
import '../widgets/styled_text_field.dart';
import '../widgets/primary_button.dart';
import '../utils/color_constants.dart';
import '../widgets/recipe/recipe_background.dart';
import '../widgets/recipe/recipe_image_picker.dart';
import '../widgets/recipe/ingredient_list_editor.dart';
import '../widgets/recipe/recipe_steps_editor.dart';

class AddRecipePage extends StatefulWidget {
  final Map<String, dynamic>? recipeToEdit;

  const AddRecipePage({super.key, this.recipeToEdit});

  @override
  State<AddRecipePage> createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _descriptionController = TextEditingController();
    final _timePreparationController = TextEditingController();
    final _timeBakingController = TextEditingController();

    bool _loading = false;
    List<Map<String, dynamic>> _ingredients = [];
    List<String> _steps = [];
    bool get _isEditing => widget.recipeToEdit != null;
    
    File? _imageFile;
    String? _existingImageUrl;
    final ImagePicker _picker = ImagePicker();


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
        _timeBakingController.addListener(_saveInputs);
    }

    void _loadRecipeData(Map<String, dynamic> recipe) {
        _nameController.text = recipe['name'] ?? '';
        _descriptionController.text = recipe['description'] ?? '';
        _timePreparationController.text = recipe['time_preparation']?.toString() ?? '';
        _timeBakingController.text = recipe['time_baking']?.toString() ?? '';
        _timeBakingController.text = recipe['time_baking']?.toString() ?? '';
        final rawInstructions = recipe['instructions'] as String? ?? '';
        if (rawInstructions.isNotEmpty) {
            _steps = rawInstructions.split('\n');
        } else {
            _steps = [];
        }
        _existingImageUrl = recipe['image_url'];
        final ingr = recipe['ingredients'];
        if (ingr is List) _ingredients = ingr.map((e) => Map<String, dynamic>.from(e)).toList();
    }

    @override
    void dispose() {
        _nameController.dispose();
        _descriptionController.dispose();
        _timePreparationController.dispose();
        _timeBakingController.dispose();
        super.dispose();
    }

    Future<void> _loadSavedInputs() async {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      
      setState(() {
          _nameController.text = prefs.getString('recipe_name') ?? '';
          _descriptionController.text = prefs.getString('recipe_description') ?? '';
          _timePreparationController.text = prefs.getString('recipe_time_prep') ?? '';
          _timeBakingController.text = prefs.getString('recipe_time_bake') ?? '';
          final savedInstr = prefs.getString('recipe_instructions');
          if (savedInstr != null && savedInstr.isNotEmpty) {
             _steps = savedInstr.split('\n');
          }
      });
    }

    Future<void> _saveInputs() async {
        if (_isEditing) return;
        final name = _nameController.text;
        final desc = _descriptionController.text;
        final prep = _timePreparationController.text;
        final bake = _timeBakingController.text;
        final steps = _steps.join('\n');

        final prefs = await SharedPreferences.getInstance();
        
        // Use captured values
        await prefs.setString('recipe_name', name);
        await prefs.setString('recipe_description', desc);
        await prefs.setString('recipe_time_prep', prep);
        await prefs.setString('recipe_time_bake', bake);
        await prefs.setString('recipe_instructions', steps);
    }

    Future<void> _clearSavedInputs() async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('recipe_name');
        await prefs.remove('recipe_description');
        await prefs.remove('recipe_time_prep');
        await prefs.remove('recipe_time_bake');
        await prefs.remove('recipe_instructions');
    }

    Future<void> _pickImage() async {
        final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
        if (image != null) {
            setState(() {
                _imageFile = File(image.path);
            });
        }
    }

    Future<String?> _uploadImage(String userId) async {
        if (_imageFile == null) return _existingImageUrl;

        final supabase = Supabase.instance.client;
        final fileExt = _imageFile!.path.split('.').last;
        final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
        
        try {
             await supabase.storage.from('recipes').upload(
                fileName,
                _imageFile!,
                fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
            );
            
            final imageUrl = supabase.storage.from('recipes').getPublicUrl(fileName);
            return imageUrl;
        } catch (e) {
            print("Erreur upload image: $e");
             ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Erreur upload image: $e")),
            );
            return null;
        }
    }


    Future<void> _addIngredientDialog() async {
      final loc = AppLocalizations.of(context)!;

      final choice = await showDialog<String>(
            context: context,
            builder: (context) => SimpleDialog(
              title:  Text(loc.addIngredient, style: GoogleFonts.recursive(fontWeight: FontWeight.bold)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              backgroundColor: Colors.white,
              children: [
                  SimpleDialogOption(
                      onPressed: () => Navigator.pop(context, 'manual'),
                      child:  Text(loc.addIngredientManual, style: GoogleFonts.recursive()),
                  ),
                  SimpleDialogOption(
                      onPressed: () => Navigator.pop(context, 'search'),
                      child:  Text(loc.addIngredientSearch, style: GoogleFonts.recursive()),
                  ),
                  SimpleDialogOption(
                      onPressed: () => Navigator.pop(context, null),
                      child:  Text(loc.cancel, style: GoogleFonts.recursive(color: Colors.red)),
                  ),
              ],
            ),
        );


        if (choice == 'manual') {
            final nameController = TextEditingController();
            final name = await showDialog<String>(
            context: context,
            builder: (context) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title:  Text(loc.nameIngredient, style: GoogleFonts.recursive(fontWeight: FontWeight.bold)),
                content: StyledTextField(
                    controller: nameController,
                    hint: loc.hintIngredient,
                    label: loc.nameIngredient,
                ),
                actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child:  Text(loc.cancel, style: GoogleFonts.recursive())),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: primaryPeach,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                        ),
                        onPressed: () => Navigator.pop(context, nameController.text.trim()),
                        child:  Text(loc.add_product, style: GoogleFonts.recursive(color: Colors.white)),
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

    String _nameFromEmail(String? email) {
        if (email == null || email.isEmpty) return 'Utilisateur';
        final local = email.split('@').first;
        final parts = local.replaceAll(RegExp(r'[._]+'), ' ').split(' ');
        final titled = parts.map((p) {
            if (p.isEmpty) return '';
            return p[0].toUpperCase() + (p.length > 1 ? p.substring(1) : '');
        }).where((s) => s.isNotEmpty).join(' ');
        return titled.isNotEmpty ? titled : local;
    }

    Future<void> _saveRecipe() async {
      final loc = AppLocalizations.of(context)!;
      final client = Supabase.instance.client;
      final user = client.auth.currentUser ?? client.auth.currentSession?.user;
      final email = user?.email ?? '';
      final displayName = user?.userMetadata?['display_name'] as String? ?? _nameFromEmail(email);


      if (!_formKey.currentState!.validate()) return;
        setState(() => _loading = true);
        String? imageUrl;
        if (user != null) {
            imageUrl = await _uploadImage(user.id);
        }

        final supabase = Supabase.instance.client;
        try {
            if (!_isEditing) {
                await supabase.from('Recettes').insert({
                    'name': _nameController.text.trim(),
                    'description': _descriptionController.text.trim(),
                    'time_preparation': int.tryParse(_timePreparationController.text) ?? 1,
                    'time_baking': int.tryParse(_timeBakingController.text) ?? 0,
                    'instructions': _steps.join('\n'),
                    'ingredients': _ingredients,
                    'user_id_creator': user?.id,
                    'creator_name': displayName,
                    'image_url': imageUrl
                });
                await _clearSavedInputs();
            } else {
                final recipeId = widget.recipeToEdit!['id'];
                
                final updates = {
                    'name': _nameController.text.trim(),
                    'description': _descriptionController.text.trim(),
                    'time_preparation': int.tryParse(_timePreparationController.text) ?? 0,
                    'time_baking': int.tryParse(_timeBakingController.text) ?? 0,
                    'instructions': _steps.join('\n'),
                    'ingredients': _ingredients,
                };
                
                if (imageUrl != null) {
                    updates['image_url'] = imageUrl;
                }

                await supabase.from('Recettes').update(updates).eq('id', recipeId);
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


    @override
    Widget build(BuildContext context) {
      final loc = AppLocalizations.of(context)!;

      return Scaffold(
          extendBodyBehindAppBar: true, 
          appBar: AppBar(
              title: Text(
                  _isEditing ? loc.updateRecipe : loc.addRecipe,
                  style: GoogleFonts.recursive(fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.black87),
          ),
          body: Stack(
              children: [
                const RecipeBackground(),

                SafeArea(
                    child: Form(
                        key: _formKey,
                        child: ListView(
                            padding: const EdgeInsets.all(24.0),
                            children: [
                                RecipeImagePicker(
                                    imageFile: _imageFile,
                                    existingImageUrl: _existingImageUrl,
                                    onTap: _pickImage,
                                ),
                                const SizedBox(height: 24),

                                StyledTextField(
                                    controller: _nameController, 
                                    hint: loc.nameRecipe, 
                                    label: loc.nameRecipe,
                                    icon: Icons.restaurant_menu,
                                    validator: (val) => val == null || val.isEmpty ? loc.enterName : null
                                ),
                                const SizedBox(height: 16),
                                StyledTextField(
                                    controller: _descriptionController,
                                    hint: loc.description,
                                    label: loc.description,
                                    maxLines: 4,
                                    icon: Icons.description_outlined,
                                ),
                                const SizedBox(height: 16),
                                Row(
                                    children: [
                                        Expanded(child: StyledTextField(
                                            controller: _timePreparationController, 
                                            hint: "min", 
                                            label: loc.timePreparing,
                                            keyboardType: TextInputType.number,
                                            icon: Icons.timer_outlined,
                                        )),
                                        const SizedBox(width: 16),
                                        Expanded(child: StyledTextField(
                                            controller: _timeBakingController, 
                                            hint: "min", 
                                            label: loc.timeBaking,
                                            keyboardType: TextInputType.number,
                                            icon: Icons.local_fire_department_outlined,
                                        )),
                                    ],
                                ),
                                const SizedBox(height: 24),
                                
                                IngredientListEditor(
                                    ingredients: _ingredients,
                                    onAddIngredient: _addIngredientDialog,
                                    onRemoveIngredient: (ing) => setState(() => _ingredients.remove(ing)),
                                ),
                              
                              const SizedBox(height: 24),
                               RecipeStepsEditor(
                                 steps: _steps,
                                 onStepsChanged: (newSteps) {
                                     _steps = newSteps;
                                     _saveInputs(); 
                                 },
                               ),
                              const SizedBox(height: 32),
                              
                              PrimaryButton(
                                  onPressed: _saveRecipe, 
                                  label: _isEditing ? loc.update : loc.addRecipe,
                                  isLoading: _loading,
                              ),
                              const SizedBox(height: 32),
                            ],
                        ),
                    ),
                ),
              ],
          ),
      );
    }
}
