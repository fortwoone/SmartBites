// ==============================================================================
// MODÈLE : recipe
// ==============================================================================
class Recipe {
  final int? id;
  final String userId;
  final String name;
  final String? description;
  final List<RecipeIngredient> ingredients;
  final List<Map<String, dynamic>> notes;
  final int prepTime;
  final int bakingTime;
  final String instructions;
  final String? imageUrl;

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
    this.imageUrl,
  });

  // Temps total (préparation + cuisson)
  int get totalTime => prepTime + bakingTime;

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
    List<Map<String, dynamic>> notes = [];
    if (json['notes'] is List) {
      for (var v in json['notes']) {
        if (v is Map<String, dynamic>) notes.add(v);
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
        instructions: json['instructions'] as String,
        imageUrl: json['image_url'] as String?);
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
      'image_url': imageUrl,
    };
  }

  // Permet de créer une copie modifiée de l'objet
  Recipe copyWith({
    int? id,
    String? userId,
    String? name,
    String? description,
    List<RecipeIngredient>? ingredients,
    List<Map<String, dynamic>>? notes,
    int? prepTime,
    int? bakingTime,
    String? instructions,
    String? imageUrl,
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
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  double get averageRating {
    if (notes.isEmpty) return 0.0;
    final ratings = notes
        .map((n) => (n['rating'] as num?)?.toDouble() ?? 0.0)
        .where((r) => r > 0)
        .toList();

    if (ratings.isEmpty) return 0.0;

    final sum = ratings.reduce((a, b) => a + b);
    return sum / ratings.length;
  }

  int get ratingCount => notes.length;
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

