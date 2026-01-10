class ShoppingList{
    int? id;
    String name;
    String user_id;
    List<String> products;
    Map<String, int> quantities;

    ShoppingList({
        this.id,
        required this.name,
        required this.user_id,
        required this.products,
        Map<String, int>? quantities
    }) : quantities = quantities ?? {};

    /// Create a shopping list in memory from retrieved data in the database.
    factory ShoppingList.fromMap(Map<String, dynamic> orig){
        List<String> products = [];
        for (String product in orig["products"]){
            products.add(product);
        }

        Map<String, int> quantities = {};
        if (orig["quantities"] != null) {
            final quantitiesData = orig["quantities"] as Map<String, dynamic>;
            quantitiesData.forEach((key, value) {
                quantities[key] = value is int ? value : int.tryParse(value.toString()) ?? 1;
            });
        }

        for (String product in products) {
            if (!quantities.containsKey(product)) {
                quantities[product] = 1;
            }
        }

        return ShoppingList(
            id: orig["id"],
            name: orig["name"],
            user_id: orig["user_id"],
            products: products,
            quantities: quantities
        );
    }

    Map<String, dynamic> toMap(){
        Map<String, dynamic> ret = {
            "name": name,
            "user_id": user_id,
            "products": products,
            "quantities": quantities
        };
        if (id != null){
            ret["id"] = id;
        }
        return ret;
    }
}