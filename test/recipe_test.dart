import "package:food/db_objects/recipe.dart";
import "package:test/test.dart";

void main(){
    group(
        "RecipeIngredient tests",
        (){
            group(
                "Constructor tests",
                (){
                    group(
                        "Normal constructor",
                        (){
                            test(
                                "All parameters given",
                                (){
                                    final ri = RecipeIngredient(
                                        ingredient: "test_ingredient",
                                        barcode: "1122334455667788"
                                    );
                                    expect("test_ingredient", ri.ingredient);
                                    expect("1122334455667788", ri.barcode);
                                }
                            );

                            test(
                                "Only the ingredient given",
                                (){
                                    final ri = RecipeIngredient(
                                        ingredient: "no_barcode"
                                    );
                                    expect("no_barcode", ri.ingredient);
                                    expect(null, ri.barcode);
                                }
                            );

                            test(
                                "Null barcode given",
                                (){
                                    final ri = RecipeIngredient(
                                        ingredient: "test_ingredient",
                                        barcode: null
                                    );
                                    expect("test_ingredient", ri.ingredient);
                                    expect(null, ri.barcode);
                                }
                            );
                        }
                    );

                    group(
                        "fromMap factory",
                        (){
                            test(
                                "All values given",
                                (){
                                    final ri = RecipeIngredient.fromMap(
                                        {
                                            "ingredient": "map_ingredient",
                                            "barcode": "8877665544332211"
                                        }
                                    );
                                    expect("map_ingredient", ri.ingredient);
                                    expect("8877665544332211", ri.barcode);
                                }
                            );

                            test(
                                "Only the ingredient given",
                                (){
                                    final ri = RecipeIngredient.fromMap(
                                        {
                                            "ingredient": "map_ingredient",
                                        }
                                    );
                                    expect("map_ingredient", ri.ingredient);
                                    expect(null, ri.barcode);
                                }
                            );

                            test(
                                "Null barcode given",
                                (){
                                    final ri = RecipeIngredient.fromMap(
                                        {
                                            "ingredient": "map_ingredient",
                                            "barcode": null,
                                        }
                                    );
                                    expect("map_ingredient", ri.ingredient);
                                    expect(null, ri.barcode);
                                }
                            );
                        }
                    );
                }
            );

            group(
                "toMap tests",
                (){
                    group(
                        "From normal constructor",
                        (){
                            test(
                                "All parameters given",
                                (){
                                    final ri = RecipeIngredient(
                                        ingredient: "test_ingredient",
                                        barcode: "0011223344556677"
                                    );

                                    final result = ri.toMap();
                                    expect("test_ingredient", result["name"]);
                                    expect("0011223344556677", result["barcode"]);
                                }
                            );

                            test(
                                "No barcode given",
                                (){
                                    final ri = RecipeIngredient(
                                        ingredient: "test_ingredient"
                                    );

                                    final result = ri.toMap();
                                    expect("test_ingredient", result["name"]);
                                    expect(null, result["barcode"]);
                                }
                            );

                            test(
                                "Null barcode given",
                                (){
                                    final ri = RecipeIngredient(
                                        ingredient: "test_ingredient",
                                        barcode: null
                                    );

                                    final result = ri.toMap();
                                    expect("test_ingredient", result["name"]);
                                    expect(null, result["barcode"]);
                                }
                            );
                        }
                    );

                    group(
                        "From factory method",
                        (){
                            test(
                                "With all parameters given",
                                (){
                                    final orig = {
                                        "name": "test_ingredient",
                                        "barcode": "0011223344556677"
                                    };
                                    final ri = RecipeIngredient.fromMap(orig);

                                    final result = ri.toMap();
                                    expect("test_ingredient", result["name"]);
                                    expect("0011223344556677", result["barcode"]);
                                }
                            );

                            test(
                                "No barcode given",
                                (){
                                    final orig = {
                                        "name": "test_ingredient"
                                    };
                                    final ri = RecipeIngredient.fromMap(orig);

                                    final result = ri.toMap();
                                    expect("test_ingredient", result["name"]);
                                    expect(null, result["barcode"]);
                                }
                            );

                            test(
                                "Null barcode given",
                                (){
                                    final orig = {
                                        "name": "test_ingredient",
                                        "barcode": null
                                    };
                                    final ri = RecipeIngredient.fromMap(orig);

                                    final result = ri.toMap();
                                    expect("test_ingredient", result["name"]);
                                    expect(null, result["barcode"]);
                                }
                            );
                        }
                    );
                }
            );
        }
    );

    group(
        "Recipe tests",
        (){
            group(
                "Constructor tests",
                (){
                    group(
                        "Normal constructor",
                        (){
                            test(
                                "All parameters given",
                                (){
                                    final recipe = Recipe(
                                        id: 0,
                                        user_id: "yetnjhktjhnksgnjqjgf",
                                        name: "blabla",
                                        description: "A test recipe.",
                                        ingredients: [
                                            RecipeIngredient(
                                                ingredient: "trucmuche",
                                                barcode: "1234567"
                                            )
                                        ],
                                        notes: [20, 18, 14, 16],
                                        prepTime: 200,
                                        bakingTime: 300,
                                        instructions: "Prends le trucmuche et fais-le cuire"
                                    );

                                    expect(0, recipe.id);
                                    expect("yetnjhktjhnksgnjqjgf", recipe.user_id);
                                    expect("blabla", recipe.name);
                                    expect("A test recipe.", recipe.description);
                                    expect(1, recipe.ingredients.length);
                                    expect("trucmuche", recipe.ingredients[0].ingredient);
                                    expect("1234567", recipe.ingredients[0].barcode);
                                    expect(4, recipe.notes.length);
                                    expect(20, recipe.notes[0]);
                                    expect(18, recipe.notes[1]);
                                    expect(14, recipe.notes[2]);
                                    expect(16, recipe.notes[3]);
                                    expect(200, recipe.prepTime);
                                    expect(300, recipe.bakingTime);
                                    expect("Prends le trucmuche et fais-le cuire", recipe.instructions);
                                }
                            );

                            test(
                                "Only required parameters given",
                                    (){
                                    final recipe = Recipe(
                                        user_id: "yetnjhktjhnksgnjqjgf",
                                        name: "blabla",
                                        ingredients: [
                                            RecipeIngredient(
                                                ingredient: "trucmuche",
                                                barcode: "1234567"
                                            )
                                        ],
                                        prepTime: 200,
                                        bakingTime: 300,
                                        instructions: "Prends le trucmuche et fais-le cuire"
                                    );

                                    expect(null, recipe.id);
                                    expect("yetnjhktjhnksgnjqjgf", recipe.user_id);
                                    expect("blabla", recipe.name);
                                    expect(null, recipe.description);
                                    expect(1, recipe.ingredients.length);
                                    expect("trucmuche", recipe.ingredients[0].ingredient);
                                    expect("1234567", recipe.ingredients[0].barcode);
                                    expect(true, recipe.notes.isEmpty);
                                    expect(200, recipe.prepTime);
                                    expect(300, recipe.bakingTime);
                                    expect("Prends le trucmuche et fais-le cuire", recipe.instructions);
                                }
                            );

                            test(
                                "Optional parameters passed as null",
                                    (){
                                    final recipe = Recipe(
                                        id: null,
                                        user_id: "yetnjhktjhnksgnjqjgf",
                                        name: "blabla",
                                        description: null,
                                        ingredients: [
                                            RecipeIngredient(
                                                ingredient: "trucmuche",
                                                barcode: "1234567"
                                            )
                                        ],
                                        notes: null,
                                        prepTime: 200,
                                        bakingTime: 300,
                                        instructions: "Prends le trucmuche et fais-le cuire"
                                    );

                                    expect(null, recipe.id);
                                    expect("yetnjhktjhnksgnjqjgf", recipe.user_id);
                                    expect("blabla", recipe.name);
                                    expect(null, recipe.description);
                                    expect(1, recipe.ingredients.length);
                                    expect("trucmuche", recipe.ingredients[0].ingredient);
                                    expect("1234567", recipe.ingredients[0].barcode);
                                    expect(true, recipe.notes.isEmpty);
                                    expect(200, recipe.prepTime);
                                    expect(300, recipe.bakingTime);
                                    expect("Prends le trucmuche et fais-le cuire", recipe.instructions);
                                }
                            );
                        }
                    );

                    group(
                        "fromMap factory method",
                        (){
                            test(
                                "All parameters given",
                                (){
                                    final orig = {
                                        "id": 0,
                                        "user_id_creator": "yetnjhktjhnksgnjqjgf",
                                        "name": "blabla",
                                        "description": "A test recipe.",
                                        "ingredients": [
                                            {
                                                "name": "trucmuche",
                                                "barcode": "1234567"
                                            }
                                        ],
                                        "notes": [20, 18, 14, 16],
                                        "time_preparation": 200,
                                        "time_baking": 300,
                                        "instructions": "Prends le trucmuche et fais-le cuire"
                                    };

                                    final recipe = Recipe.fromMap(orig);
                                    expect(0, recipe.id);
                                    expect("yetnjhktjhnksgnjqjgf", recipe.user_id);
                                    expect("blabla", recipe.name);
                                    expect("A test recipe.", recipe.description);
                                    expect(1, recipe.ingredients.length);
                                    expect("trucmuche", recipe.ingredients[0].ingredient);
                                    expect("1234567", recipe.ingredients[0].barcode);
                                    expect(4, recipe.notes.length);
                                    expect(20, recipe.notes[0]);
                                    expect(18, recipe.notes[1]);
                                    expect(14, recipe.notes[2]);
                                    expect(16, recipe.notes[3]);
                                    expect(200, recipe.prepTime);
                                    expect(300, recipe.bakingTime);
                                    expect("Prends le trucmuche et fais-le cuire", recipe.instructions);
                                }
                            );

                            test(
                                "Only required parameters given",
                                (){
                                    final orig = {
                                        "user_id_creator": "yetnjhktjhnksgnjqjgf",
                                        "name": "blabla",
                                        "ingredients": [
                                            {
                                                "name": "trucmuche",
                                                "barcode": "1234567"
                                            }
                                        ],
                                        "time_preparation": 200,
                                        "time_baking": 300,
                                        "instructions": "Prends le trucmuche et fais-le cuire"
                                    };

                                    final recipe = Recipe.fromMap(orig);
                                    expect(null, recipe.id);
                                    expect("yetnjhktjhnksgnjqjgf", recipe.user_id);
                                    expect("blabla", recipe.name);
                                    expect(null, recipe.description);
                                    expect(1, recipe.ingredients.length);
                                    expect("trucmuche", recipe.ingredients[0].ingredient);
                                    expect("1234567", recipe.ingredients[0].barcode);
                                    expect(true, recipe.notes.isEmpty);
                                    expect(200, recipe.prepTime);
                                    expect(300, recipe.bakingTime);
                                    expect("Prends le trucmuche et fais-le cuire", recipe.instructions);
                                }
                            );

                            test(
                                "Optional parameters passed as null",
                                (){
                                    final orig = {
                                        "id": null,
                                        "user_id_creator": "yetnjhktjhnksgnjqjgf",
                                        "name": "blabla",
                                        "description": null,
                                        "ingredients": [
                                            {
                                                "name": "trucmuche",
                                                "barcode": "1234567"
                                            }
                                        ],
                                        "notes": null,
                                        "time_preparation": 200,
                                        "time_baking": 300,
                                        "instructions": "Prends le trucmuche et fais-le cuire"
                                    };

                                    final recipe = Recipe.fromMap(orig);
                                    expect(null, recipe.id);
                                    expect("yetnjhktjhnksgnjqjgf", recipe.user_id);
                                    expect("blabla", recipe.name);
                                    expect(null, recipe.description);
                                    expect(1, recipe.ingredients.length);
                                    expect("trucmuche", recipe.ingredients[0].ingredient);
                                    expect("1234567", recipe.ingredients[0].barcode);
                                    expect(true, recipe.notes.isEmpty);
                                    expect(200, recipe.prepTime);
                                    expect(300, recipe.bakingTime);
                                    expect("Prends le trucmuche et fais-le cuire", recipe.instructions);
                                }
                            );
                        }
                    );
                }
            );

            group(
                "toMap tests",
                (){
                    group(
                        "From normal constructor",
                        (){
                            test(
                                "All parameters given",
                                (){
                                    final recipe = Recipe(
                                        id: 0,
                                        user_id: "yetnjhktjhnksgnjqjgf",
                                        name: "blabla",
                                        description: "A test recipe.",
                                        ingredients: [
                                            RecipeIngredient(
                                                ingredient: "trucmuche",
                                                barcode: "1234567"
                                            )
                                        ],
                                        notes: [20, 18, 14, 16],
                                        prepTime: 200,
                                        bakingTime: 300,
                                        instructions: "Prends le trucmuche et fais-le cuire"
                                    );

                                    final result = recipe.toMap();
                                    expect(0, result["id"]);
                                    expect("yetnjhktjhnksgnjqjgf", result["user_id_creator"]);
                                    expect("blabla", result["name"]);
                                    expect("A test recipe.", result["description"]);
                                    expect(
                                        [
                                            {
                                                "name": "trucmuche",
                                                "barcode": "1234567"
                                            }
                                        ],
                                        result["ingredients"]
                                    );
                                    expect([20, 18, 14, 16], result["notes"]);
                                    expect(200, result["time_preparation"]);
                                    expect(300, result["time_baking"]);
                                    expect(
                                        "Prends le trucmuche et fais-le cuire",
                                        result["instructions"]
                                    );
                                }
                            );

                            test(
                                "No optional parameters given",
                                (){
                                    final recipe = Recipe(
                                        user_id: "yetnjhktjhnksgnjqjgf",
                                        name: "blabla",
                                        ingredients: [
                                            RecipeIngredient(
                                                ingredient: "trucmuche",
                                                barcode: "1234567"
                                            )
                                        ],
                                        prepTime: 200,
                                        bakingTime: 300,
                                        instructions: "Prends le trucmuche et fais-le cuire"
                                    );

                                    final result = recipe.toMap();
                                    expect(null, result["id"]);
                                    expect("yetnjhktjhnksgnjqjgf", result["user_id_creator"]);
                                    expect("blabla", result["name"]);
                                    expect(null, result["description"]);
                                    expect(
                                        [
                                            {
                                                "name": "trucmuche",
                                                "barcode": "1234567"
                                            }
                                        ],
                                        result["ingredients"]
                                    );
                                    expect([], result["notes"]);
                                    expect(200, result["time_preparation"]);
                                    expect(300, result["time_baking"]);
                                    expect(
                                        "Prends le trucmuche et fais-le cuire",
                                        result["instructions"]
                                    );
                                }
                            );

                            test(
                                "Optional parameters passed as null",
                                (){
                                    final recipe = Recipe(
                                        id: null,
                                        user_id: "yetnjhktjhnksgnjqjgf",
                                        name: "blabla",
                                        description: null,
                                        ingredients: [
                                            RecipeIngredient(
                                                ingredient: "trucmuche",
                                                barcode: "1234567"
                                            )
                                        ],
                                        notes: null,
                                        prepTime: 200,
                                        bakingTime: 300,
                                        instructions: "Prends le trucmuche et fais-le cuire"
                                    );

                                    final result = recipe.toMap();
                                    expect(null, result["id"]);
                                    expect("yetnjhktjhnksgnjqjgf", result["user_id_creator"]);
                                    expect("blabla", result["name"]);
                                    expect(null, result["description"]);
                                    expect(
                                        [
                                            {
                                                "name": "trucmuche",
                                                "barcode": "1234567"
                                            }
                                        ],
                                        result["ingredients"]
                                    );
                                    expect([], result["notes"]);
                                    expect(200, result["time_preparation"]);
                                    expect(300, result["time_baking"]);
                                    expect(
                                        "Prends le trucmuche et fais-le cuire",
                                        result["instructions"]
                                    );
                                }
                            );
                        }
                    );

                    group(
                        "Created via fromMap",
                        (){
                            test(
                                "All parameters given",
                                (){
                                    final orig = {
                                        "id": 0,
                                        "user_id_creator": "yetnjhktjhnksgnjqjgf",
                                        "name": "blabla",
                                        "description": "A test recipe.",
                                        "ingredients": [
                                            {
                                                "name": "trucmuche",
                                                "barcode": "1234567"
                                            }
                                        ],
                                        "notes": [20, 18, 14, 16],
                                        "time_preparation": 200,
                                        "time_baking": 300,
                                        "instructions": "Prends le trucmuche et fais-le cuire"
                                    };
                                    final recipe = Recipe.fromMap(orig);

                                    final result = recipe.toMap();
                                    expect(0, result["id"]);
                                    expect("yetnjhktjhnksgnjqjgf", result["user_id_creator"]);
                                    expect("blabla", result["name"]);
                                    expect("A test recipe.", result["description"]);
                                    expect(
                                        [
                                            {
                                                "name": "trucmuche",
                                                "barcode": "1234567"
                                            }
                                        ],
                                        result["ingredients"]
                                    );
                                    expect([20, 18, 14, 16], result["notes"]);
                                    expect(200, result["time_preparation"]);
                                    expect(300, result["time_baking"]);
                                    expect(
                                        "Prends le trucmuche et fais-le cuire",
                                        result["instructions"]
                                    );
                                }
                            );

                            test(
                                "No optional parameters given",
                                (){
                                    final orig = {
                                        "user_id_creator": "yetnjhktjhnksgnjqjgf",
                                        "name": "blabla",
                                        "ingredients": [
                                            {
                                                "name": "trucmuche",
                                                "barcode": "1234567"
                                            }
                                        ],
                                        "time_preparation": 200,
                                        "time_baking": 300,
                                        "instructions": "Prends le trucmuche et fais-le cuire"
                                    };
                                    final recipe = Recipe.fromMap(orig);

                                    final result = recipe.toMap();
                                    expect(null, result["id"]);
                                    expect("yetnjhktjhnksgnjqjgf", result["user_id_creator"]);
                                    expect("blabla", result["name"]);
                                    expect(null, result["description"]);
                                    expect(
                                        [
                                            {
                                                "name": "trucmuche",
                                                "barcode": "1234567"
                                            }
                                        ],
                                        result["ingredients"]
                                    );
                                    expect([], result["notes"]);
                                    expect(200, result["time_preparation"]);
                                    expect(300, result["time_baking"]);
                                    expect(
                                        "Prends le trucmuche et fais-le cuire",
                                        result["instructions"]
                                    );
                                }
                            );

                            test(
                                "Optional parameters passed as null",
                                (){
                                    final orig = {
                                        "id": null,
                                        "user_id_creator": "yetnjhktjhnksgnjqjgf",
                                        "name": "blabla",
                                        "description":null,
                                        "ingredients": [
                                            {
                                                "name": "trucmuche",
                                                "barcode": "1234567"
                                            }
                                        ],
                                        "notes": null,
                                        "time_preparation": 200,
                                        "time_baking": 300,
                                        "instructions": "Prends le trucmuche et fais-le cuire"
                                    };
                                    final recipe = Recipe.fromMap(orig);

                                    final result = recipe.toMap();
                                    expect(null, result["id"]);
                                    expect("yetnjhktjhnksgnjqjgf", result["user_id_creator"]);
                                    expect("blabla", result["name"]);
                                    expect(null, result["description"]);
                                    expect(
                                        [
                                            {
                                                "name": "trucmuche",
                                                "barcode": "1234567"
                                            }
                                        ],
                                        result["ingredients"]
                                    );
                                    expect([], result["notes"]);
                                    expect(200, result["time_preparation"]);
                                    expect(300, result["time_baking"]);
                                    expect(
                                        "Prends le trucmuche et fais-le cuire",
                                        result["instructions"]
                                    );
                                }
                            );
                        }
                    );
                }
            );
        }
    );
}
