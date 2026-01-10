// ==============================================================================
// MODÈLE : Recipe
// ==============================================================================
class Recipe {
  final int? id;
  final String userId;
  final String name;
  final String? description;
  final List<RecipeIngredient> ingredients;
  final List<int> notes;
  final int prepTime;
  final int bakingTime;
  final String instructions;

  //constructeur
  const Recipe({
    this.id,
    required this.userId,
    required this.name,
    this.description,
    this.ingredients = const [],
    this.notes = const [],
    required this.prepTime,
    required this.bakingTime,
    required this.instructions,
  });

  // ---------------------------------------------------------------------------
  // FACTORY : Crée une instance de Product (JSON -> Objet)
  // ---------------------------------------------------------------------------
  factory Recipe.fromJson(Map<String, dynamic> json) {
    List<RecipeIngredient> ingredients = [];
    if (json['ingredients'] is List) {
      for (var v in json['ingredients']) {
        if (v is Map<String, dynamic>) {
          ingredients.add(RecipeIngredient.fromJson(v));
        }
      }
    }
    List<int> notes = [];
    if (json['notes'] is List) {
      for (var v in json['notes']) {
        if (v is int) notes.add(v);
      }
    }
    return Recipe(id: json['id'] as int?,
      userId: json['user_id_creator'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      ingredients: ingredients,
      notes: notes,
      prepTime: json['time_preparation'] as int,
      bakingTime: json['time_baking'] as int,
      instructions: json['instructions'] as String);
  }

  // Convertit l'objet en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id_creator': userId,
      'name': name,
      'description': description,
      'ingredients': ingredients.map((e) => e.toJson()).toList(),
      'notes': notes,
      'time_preparation': prepTime,
      'time_baking': bakingTime,
      'instructions': instructions,
    };
  }

  // Permet de créer une copie modifiée de l'objet
  Recipe copyWith({
    int? id,
    String? userId,
    String? name,
    String? description,
    List<RecipeIngredient>? ingredients,
    List<int>? notes,
    int? prepTime,
    int? bakingTime,
    String? instructions,
  }) {
    return Recipe(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      notes: notes ?? this.notes,
      prepTime: prepTime ?? this.prepTime,
      bakingTime: bakingTime ?? this.bakingTime,
      instructions: instructions ?? this.instructions,
    );
  }
}

// ==============================================================================
// SOUS-MODÈLE : RecipeIngredient
// ==============================================================================
class RecipeIngredient {
  final String ingredient;
  final String? barcode;

  // Constructeur
  const RecipeIngredient({
    required this.ingredient,
    this.barcode,
  });

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      ingredient: json['name'] as String,
      barcode: json['barcode'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': ingredient,
      'barcode': barcode,
    };
  }
}
