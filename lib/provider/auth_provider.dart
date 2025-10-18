import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/db/db_helper.dart';
import 'package:flutter_application_1/model/access.dart';
import 'package:flutter_application_1/model/user_admin.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  int? currUserId;
  final DBHelper db = DBHelper();
  final Tables adminTables = Tables.userAdmin;

  bool isLoading = false;

  AuthProvider() {
    _loadCurrUser();
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Future<void> _loadCurrUser() async {
    _setLoading(true);
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString("curr_user_id");

    if (userJson != null) {
      currUserId = int.parse(userJson);
    } else {
      currUserId = null;
    }

    _setLoading(false);
  }

  Future<void> login(String username, String password) async {
    _setLoading(true);

    // Contoh ambil dari DB (atau API)
    final res = await db.get(
      userAdminTable,
      where: "username = ? AND password = ?",
      whereArgs: [username, password],
    );

    if (res.isNotEmpty) {
      currUser = UserAdmin.fromMap(res[0]);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("curr_user", jsonEncode(currUser!.toMap()));

      notifyListeners();
    } else {
      // handle error login
    }

    _setLoading(false);
  }
}
