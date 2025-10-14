import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/widgets.dart';

// region Table models
class DBShoppingProduct{
    int? id;
    String barcode;
    int list_id;

    DBShoppingProduct({required this.barcode, required this.list_id});

    static DBShoppingProduct fromMap(Map<String, dynamic> input){
        var ret = DBShoppingProduct(barcode: input["barcode"], list_id: input["list_id"]);
        if (input.containsKey("id")){
            ret.id = input["id"];
        }
        return ret;
    }

    Map<String, dynamic> toMap(){
        var ret = {
            "barcode": barcode,
            "list_id": list_id
        };

        if (id != null){
            ret["id"] = id!;
        }

        return ret;
    }

    @override
    String toString() {
        return "DBShoppingProduct{barcode: $barcode, list_id: $list_id}";
    }
}

class DBShoppingList{
    int? id;
    String name;

    DBShoppingList({required this.name});

    static DBShoppingList fromMap(Map<String, dynamic> input){
        var ret = DBShoppingList(name: input["name"]);

        if (input.containsKey("id")){
            ret.id = input["id"];
        }

        return ret;
    }

    Map<String, dynamic> toMap(){
        var ret = {
            "name": name,
        };

        if (id != null){
            ret["id"] = id!.toString();
        }

        return ret;
    }

    @override
    String toString() {
        return "DBShoppingList{name: $name}";
    }
}
// endregion
