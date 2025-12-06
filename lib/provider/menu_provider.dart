import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/db/db_helper.dart';
import 'package:flutter_application_1/model/category.dart';
import 'package:flutter_application_1/model/menu.dart';

class MenuProvider with ChangeNotifier {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final List<Menu> menus = [];
  final DBHelper db = DBHelper();
  final Tables menuTables = Tables.menu;
  final Tables dishTypesTable = Tables.dishType;

  bool isLoading = false;

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Future<void> loadMenu() async {
    _setLoading(true);
    final res = await db.get(
      menuTables,
      joins: [
        Join(
          joinTable: dishTypesTable,
          fromKey: "type_id",
          toKey: "id",
          isList: false,
        ),
      ],
      orderBy: "menu.created_at",
      orderType: OrderType.desc,
    );

    menus
      ..clear()
      ..addAll(res.map((e) => Menu.fromMap(e)).toList());
    _setLoading(false);

    await analytics.logEvent(
      name: 'load_menu',
      parameters: {'count': menus.length},
    );
  }

  Future<Menu?> getMenuById(int id) async {
    _setLoading(true);
    final res = (await db.get(
      menuTables,
      joins: [
        Join(
          joinTable: dishTypesTable,
          fromKey: "type_id",
          toKey: "id",
          isList: false,
        ),
      ],
      where: "menu.id = ?",
      whereArgs: [id],
    ))[0];
    _setLoading(false);
    await analytics.logEvent(
      name: 'get_menu_detail',
      parameters: {'menu_id': id},
    );
    return Menu.fromMap(res);
  }

  Future<void> addMenu({
    required String name,
    required String img,
    required double price,
    required String description,
    required int category,
  }) async {
    _setLoading(true);
    try {
      final res = await db.insert(menuTables, {
        'name': name,
        'img': img,
        'price': price,
        'description': description,
        'type_id': category,
      });
      final type = Category.fromMap(
        (await db.get(
          dishTypesTable,
          where: "id = ?",
          whereArgs: [category],
        ))[0],
      );

      menus.add(
        Menu(
          id: res,
          name: name,
          img: img,
          price: price,
          description: description,
          typeId: category,
          category: type,
          isActive: true,
        ),
      );
      _setLoading(false);

      await analytics.logEvent(
        name: 'add_menu',
        parameters: {'name': name, 'price': price, 'description': description},
      );
    } catch (e) {
      print(e);
    }
  }

  Future<void> editMenu({
    required String name,
    required String img,
    required double price,
    required String description,
    required int category,
    required bool isActive,
    required int id,
  }) async {
    _setLoading(true);
    final type = Category.fromMap(
      (await db.get(dishTypesTable, where: "id = ?", whereArgs: [category]))[0],
    );
    await db.update(
      menuTables,
      id: id,
      data: {
        'name': name,
        'img': img,
        'price': price,
        'description': description,
        'type_id': category,
        'is_active': isActive ? 1 : 0,
      },
    );
    if (menus.indexWhere((item) => item.id == id) == -1) {
      await loadMenu();
    }
    final index = (menus.indexWhere((item) => item.id == id)) == -1
        ? id
        : menus.indexWhere((item) => item.id == id);
    menus[index] = Menu(
      id: id,
      name: name,
      img: img,
      price: price,
      description: description,
      typeId: category,
      category: type,
      isActive: isActive,
    );

    _setLoading(false);
    await analytics.logEvent(
      name: 'edit_menu',
      parameters: {
        'id': id,
        'name': name,
        'price': price,
        'description': description,
      },
    );
  }

  Future<void> deleteMenu(int id) async {
    _setLoading(true);
    await db.delete(menuTables, id: id);
    menus.removeWhere((item) => item.id == id);
    _setLoading(false);

    await analytics.logEvent(name: 'delete_menu', parameters: {'id': id});
  }
}
