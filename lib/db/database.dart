import 'dart:async';

import 'package:food/db/tables.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/widgets.dart';

class DBAccess{
    static final DB_NAME = "shopping_lists.db";
    static final DB_VERSION = 1;

    DBAccess._priv();

    static final DBAccess inst = DBAccess._priv();

    static Database? _db;

    Future<Database> get database async{
        // Lazy instantiation
        if (_db != null){
            return _db!;
        }
        _db = await _initDB();
        return _db!;
    }

    Future<Database> _initDB() async{
        String path = join(await getDatabasesPath(), DB_NAME);
        return await openDatabase(
            path,
            version: DB_VERSION,
            onCreate: _createTables,
            onConfigure: _configDB
        );
    }

    Future<void> _createTables(Database db, int version) async{
        // Create the shopping list table.
        await db.execute(
            """
            CREATE TABLE shopping_list(
                id INTEGER PRIMARY KEY,
                name TEXT NOT NULL UNIQUE
            )"""
        );
        // Create the product list table (used to retrieve the products stored in each list).
        await db.execute(
            """
            CREATE TABLE shopping_product(
                barcode INTEGER PRIMARY KEY,
                list_id INTEGER NOT NULL,
                FOREIGN KEY (list_id) REFERENCES shopping_list(id)
            )"""
        );
    }

    Future<void> _configDB(Database db) async{
        await db.execute(
            "PRAGMA foreign_keys = ON"
        );
    }

    /// Update or insert a shopping list into the database.
    Future<DBShoppingList> upsertList(DBShoppingList lst) async{
        Database db = await inst.database;

        int? count = Sqflite.firstIntValue(
            await db.rawQuery(
                "SELECT COUNT(*) FROM shopping_list WHERE id = ?", [lst.id]
            )
        );
        if (count == 0){
            await db.insert(
                "shopping_list",
                lst.toMap(),
                conflictAlgorithm: ConflictAlgorithm.replace
            );
        }
        else{
            await db.update("shopping_list", lst.toMap(), where: "id = ?", whereArgs: [lst.id]);
        }

        return lst;
    }

    /// Update or insert a product reference into the database.
    Future<DBShoppingProduct> upsertProduct(DBShoppingProduct product) async{
        Database db = await inst.database;

        int? count = Sqflite.firstIntValue(
            await db.rawQuery(
                "SELECT COUNT(*) FROM shopping_product WHERE barcode = ?", [product.barcode]
            )
        );

        if (count == 0){
            await db.insert(
                "shopping_product",
                product.toMap(),
                conflictAlgorithm: ConflictAlgorithm.replace
            );
        }
        else{
            await db.update("shopping_product", product.toMap(), where: "barcode = ?", whereArgs: [product.barcode]);
        }

        return product;
    }


}
