import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/widgets.dart';

// region Table models
class DBShoppingProduct{
    int barcode;
    int list_id;

    DBShoppingProduct({required this.barcode, required this.list_id});

    static DBShoppingProduct fromMap(Map<String, dynamic> input){
        return DBShoppingProduct(barcode: input["barcode"], list_id: input["list_id"]);
    }

    Map<String, dynamic> toMap(){
        return {
            "barcode": barcode,
            "list_id": list_id
        };
    }

    @override
    String toString() {
        return "DBShoppingProduct{barcode: $barcode, list_id: $list_id}";
    }
}

class DBShoppingList{
    int id;
    String name;

    DBShoppingList({required this.id, required this.name});

    static DBShoppingList fromMap(Map<String, dynamic> input){
        return DBShoppingList(id: input["id"], name: input["name"]);
    }

    Map<String, dynamic> toMap(){
        return {
            "id": id,
            "name": name,
        };
    }

    @override
    String toString() {
        return "DBShoppingList{id: $id, name: $name}";
    }
}
// endregion
