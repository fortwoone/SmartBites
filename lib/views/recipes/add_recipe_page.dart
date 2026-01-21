import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../l10n/app_localizations.dart';
import '../../models/recipe.dart';
import '../../models/product.dart';
import '../../utils/color_constants.dart';
import '../../viewmodels/recipe_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../product/product_search_page.dart';

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
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(
              isEditing ? loc.updateRecipe : loc.addRecipe,
              style: GoogleFonts.recursive(fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black87),
            floating: true,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(loc.description),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _nameCtrl,
                      label: loc.nameRecipe,
                      icon: Icons.edit_note,
                      validator: (v) => v?.isEmpty == true ? loc.enterName : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _descCtrl,
                      label: loc.description,
                      icon: Icons.description,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle(loc.preparation),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _prepCtrl,
                            label: loc.timePreparing,
                            icon: Icons.timer_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _bakeCtrl,
                            label: loc.timeBaking,
                            icon: Icons.local_fire_department_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle(loc.ingredients),
                    const SizedBox(height: 8),
                    _buildIngredientsList(loc),
                     const SizedBox(height: 16),
                     _buildAddIngredientButtons(loc),

                    const SizedBox(height: 24),
                    _buildSectionTitle(loc.instructions),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _instructionCtrl,
                      label: loc.enterInstructions,
                      icon: Icons.format_list_numbered,
                      maxLines: 10,
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: _submit,
                        child: Text(
                          loc.validate,
                          style: GoogleFonts.recursive(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.recursive(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        style: GoogleFonts.inter(),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.grey.shade400),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildIngredientsList(AppLocalizations loc) {
    if (_ingredients.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            loc.noIngredientsAdded,
            style: GoogleFonts.recursive(color: Colors.grey, fontStyle: FontStyle.italic),
          ),
        ),
      );
    }
    return Column(
      children: _ingredients.map((ing) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 16, color: AppColors.primary),
          ),
          title: Text(ing.ingredient, style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
          subtitle: ing.barcode != null ? Text("Code: ${ing.barcode}", style: const TextStyle(fontSize: 12)) : null,
          trailing: IconButton(
            icon: const Icon(Icons.close, color: Colors.red, size: 20),
            onPressed: () => setState(() => _ingredients.remove(ing)),
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildAddIngredientButtons(AppLocalizations loc) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showIngredientTypeSelection(loc),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
        label: Text(loc.addIngredient, style: GoogleFonts.recursive(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
      ),
    );
  }

  void _showIngredientTypeSelection(AppLocalizations loc) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(loc.addIngredient, style: GoogleFonts.recursive(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                  child: const Icon(Icons.edit, color: Colors.blue),
                ),
                title: Text(loc.addIngredientManual, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showAddIngDialog();
                },
              ),
              const Divider(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
                  child: const Icon(Icons.search, color: Colors.green),
                ),
                title: Text(loc.addIngredientSearch, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(ctx);
                  _addIngredientFromApi();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddIngDialog() {
    final ctrl = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text("Ajouter un ingrédient"),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: TextField(
          controller: ctrl,
          decoration: InputDecoration(
              hintText: "Nom (ex: Farine)",
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)
          )
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
        ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: (){
              if (ctrl.text.isNotEmpty) {
                setState(() => _ingredients.add(RecipeIngredient(ingredient: ctrl.text)));
                Navigator.pop(context);
              }
            },
            child: const Text("Ajouter")
        )
      ],
    ));
  }

  Future<void> _addIngredientFromApi() async {
    // Navigate to ProductSearchPage in selection mode
    final Product? selectedProduct = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProductSearchPage(inAddMode: true),
      ),
    );

    if (selectedProduct != null) {
      if (selectedProduct.name != null) {
         setState(() {
           _ingredients.add(RecipeIngredient(
             ingredient: selectedProduct.name!,
             barcode: selectedProduct.barcode
           ));
         });
      }
    }
  }


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
