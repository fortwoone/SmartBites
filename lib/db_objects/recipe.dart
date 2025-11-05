class RecipeIngredient{
    String ingredient;
    String? barcode;

    RecipeIngredient({required this.ingredient, this.barcode});

    factory RecipeIngredient.fromMap(Map<String, dynamic> data){
        return RecipeIngredient(
            ingredient: data["name"] as String,
            barcode: data["barcode"] as String?
        );
    }

    Map<String, dynamic> toMap(){
        return {
            "name": ingredient,
            "barcode": barcode
        };
    }
}

class Recipe{
    int? id;
    String user_id;
    String name;
    String? description;
    List<RecipeIngredient> ingredients;
    List<int> notes;
    int prepTime;
    int bakingTime;
    String instructions;

    Recipe(
        {
            this.id,
            required this.user_id,
            required this.name,
            this.description,
            required this.ingredients,
            List<int>? notes,
            required this.prepTime,
            required this.bakingTime,
            required this.instructions
        }
    ): this.notes = notes ?? [];

    factory Recipe.fromMap(Map<String, dynamic> data){
        List<RecipeIngredient> ingredients = [];

        if (data["ingredients"] is List<dynamic>){
            for (Map<String, dynamic> value in data["ingredients"]){
                ingredients.add(RecipeIngredient.fromMap(value));
            }
        }

        List<int> notes = [];

        if (data["notes"] is List<dynamic>){
            for (int mark in data["notes"]){
                notes.add(mark);
            }
        }

        return Recipe(
            id: data["id"] as int?,
            user_id: data["user_id_creator"] as String,
            name: data["name"] as String,
            description: data["description"] as String?,
            ingredients:ingredients,
            notes: notes,
            prepTime: data["time_preparation"] as int,
            bakingTime: data["time_baking"] as int,
            instructions: data["instructions"] as String
        );
    }

    Map<String, dynamic> toMap(){
        List<Map<String, dynamic>> ingredientsExported = [];
        for (RecipeIngredient ingredient in ingredients){
            ingredientsExported.add(ingredient.toMap());
        }

        return {
            "id": id,
            "user_id_creator": user_id,
            "name": name,
            "description": description,
            "ingredients": ingredientsExported,
            "notes": notes,
            "time_preparation": prepTime,
            "time_baking": bakingTime,
            "instructions": instructions
        };
    }
}
