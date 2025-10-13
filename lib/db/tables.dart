import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/widgets.dart';

// region Table models
class ShoppingProduct{
    final int barcode;
    final int list_id;

    const ShoppingProduct({required this.barcode, required this.list_id});

    static ShoppingProduct fromMap(Map<String, dynamic> input){
        return ShoppingProduct(barcode: input["barcode"], list_id: input["list_id"]);
    }

    Map<String, dynamic> toMap(){
        return {
            "barcode": barcode,
            "list_id": list_id
        };
    }

    @override
    String toString() {
        return "ShoppingProduct{barcode: $barcode, list_id: $list_id}";
    }
}

class ShoppingList{
    final int id;
    final String name;

    const ShoppingList({required this.id, required this.name});

    static ShoppingList fromMap(Map<String, dynamic> input){
        return ShoppingList(id: input["id"], name: input["name"]);
    }

    Map<String, dynamic> toMap(){
        return {
            "id": id,
            "name": name,
        };
    }

    @override
    String toString() {
        return "ShoppingList{id: $id, name: $name}";
    }
}
// endregion
