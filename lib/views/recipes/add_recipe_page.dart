import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../l10n/app_localizations.dart';
import '../../models/recipe.dart';
import '../../utils/color_constants.dart';
import '../../viewmodels/recipe_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';

class AddRecipePage extends ConsumerStatefulWidget {
  final Recipe? recipeToEdit;
  const AddRecipePage({super.key, this.recipeToEdit});

  @override
  ConsumerState<AddRecipePage> createState() => _AddRecipePageState();
}

class _AddRecipePageState extends ConsumerState<AddRecipePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _prepCtrl = TextEditingController();
  final _bakeCtrl = TextEditingController();
  final _instructionCtrl = TextEditingController();
  List<RecipeIngredient> _ingredients = [];
  bool get isEditing => widget.recipeToEdit != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _nameCtrl.text = widget.recipeToEdit!.name;
      _descCtrl.text = widget.recipeToEdit!.description ?? '';
      _prepCtrl.text = widget.recipeToEdit!.prepTime.toString();
      _bakeCtrl.text = widget.recipeToEdit!.bakingTime.toString();
      _instructionCtrl.text = widget.recipeToEdit!.instructions;
      _ingredients = List.from(widget.recipeToEdit!.ingredients);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? loc.updateRecipe : loc.addRecipe, style: GoogleFonts.recursive(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: InputDecoration(labelText: loc.nameRecipe, border: const OutlineInputBorder()),
              validator: (v) => v?.isEmpty == true ? loc.enterName : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descCtrl,
              decoration: InputDecoration(labelText: loc.description, border: const OutlineInputBorder()),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: TextFormField(
                  controller: _prepCtrl,
                  decoration: InputDecoration(labelText: loc.timePreparing, border: const OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                )),
                const SizedBox(width: 16),
                Expanded(child: TextFormField(
                  controller: _bakeCtrl,
                  decoration: InputDecoration(labelText: loc.timeBaking, border: const OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                )),
              ],
            ),
            const SizedBox(height: 16),
             Text(loc.ingredients, style: GoogleFonts.recursive(fontSize: 18, fontWeight: FontWeight.bold)),
            _buildIngredientsList(loc),
            const SizedBox(height: 16),
             Text(loc.instructions, style: GoogleFonts.recursive(fontSize: 18, fontWeight: FontWeight.bold)),
            TextFormField(
              controller: _instructionCtrl,
               decoration: InputDecoration(hintText: loc.enterInstructions, border: const OutlineInputBorder()),
               maxLines: 10,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.all(16)),
              onPressed: _submit,
              child: Text(loc.validate, style: const TextStyle(color: Colors.white, fontSize: 18)),
            )
          ],
        ),
      ),
    );
  }

  // Fabrique la liste des ingrédients avec option d'ajout/suppression
  Widget _buildIngredientsList(AppLocalizations loc) {
    return Column(
      children: [
        ..._ingredients.map((ing) => ListTile(
          title: Text(ing.ingredient),
          trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => _ingredients.remove(ing))),
        )),
        ElevatedButton.icon(
          onPressed: _showAddIngDialog,
          icon: const Icon(Icons.add),
          label: Text(loc.addIngredient),
        )
      ],
    );
  }

  // Affiche une boîte de dialogue pour ajouter un ingrédient
  void _showAddIngDialog() {
      final ctrl = TextEditingController();
      showDialog(context: context, builder: (_) => AlertDialog(
        title: const Text("Ajouter un ingrédient"),
        content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: "Nom (ex: Farine)")),
        actions: [
          ElevatedButton(onPressed: (){
             if (ctrl.text.isNotEmpty) {
               setState(() => _ingredients.add(RecipeIngredient(ingredient: ctrl.text)));
               Navigator.pop(context);
             }
          }, child: const Text("OK"))
        ],
      ));
  }

  // Soumet le formulaire pour ajouter ou mettre à jour la recette
  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
       final user = ref.read(authViewModelProvider).value;
       if (user == null) return;
       final recipe = Recipe(
          id: widget.recipeToEdit?.id,
          userId: user.id,
          name: _nameCtrl.text,
          description: _descCtrl.text,
          ingredients: _ingredients,
          instructions: _instructionCtrl.text,
          prepTime: int.tryParse(_prepCtrl.text) ?? 0,
          bakingTime: int.tryParse(_bakeCtrl.text) ?? 0,
          notes: widget.recipeToEdit?.notes ?? [],
       );

       if (isEditing) {
          await ref.read(recipeViewModelProvider.notifier).updateRecipe(recipe);
       } else {
          await ref.read(recipeViewModelProvider.notifier).addRecipe(recipe);
       }
       if (mounted) Navigator.pop(context);
    }
  }
}
