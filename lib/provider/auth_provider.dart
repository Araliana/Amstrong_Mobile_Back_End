import 'package:flutter/material.dart';
import 'package:flutter_application_1/db/db_helper.dart';
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

  Future<bool> login(String username, String password) async {
    _setLoading(true);

    final res = await db.get(
      adminTables,
      where: "username = ? AND password = ?",
      whereArgs: [username, password],
    );

    if (res.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("curr_user_id", res[0]["id"]);
      _setLoading(false);
      return true;
    } else {
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("curr_user_id");
    currUserId = null;
    _setLoading(false);
  }
}
