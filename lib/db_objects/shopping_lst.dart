/// Representation in memory of shopping lists.
class ShoppingList{
    int? id;
    String name;
    String user_id;
    List<String> products;

    ShoppingList({this.id, required this.name, required this.user_id, required this.products});

    /// Create a shopping list in memory from retrieved data in the database.
    static ShoppingList fromMap(Map<String, dynamic> orig){
        List<String> products = [];
        for (String product in orig["products"]){
            products.add(product);
        }
        return ShoppingList(
            id: orig["id"],
            name: orig["name"],
            user_id: orig["user_id"],
            products: products
        );
    }

    Map<String, dynamic> toMap(){
        Map<String, dynamic> ret = {
            "name": name,
            "user_id": user_id,
            "products": products
        };
        if (id != null){
            ret["id"] = id;
        }
        return ret;
    }
}