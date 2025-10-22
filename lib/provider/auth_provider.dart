import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/model/user_admin.dart';
import 'package:flutter_application_1/utils/index.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/db/db_helper.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DBHelper db = DBHelper();
  final Tables adminTables = Tables.userAdmin;

  String? currUserId;
  String? currUsername;
  Map<String, dynamic>? currUserData;

  bool isLoading = false;

  AuthProvider() {
    _loadCurrentUser();
    _listenAuthChanges();
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void _listenAuthChanges() {
    _auth.authStateChanges().listen((user) async {
      if (user == null) {
        await _clearLocalUser();
        notifyListeners();
      } else {
        currUserId = user.uid;
        await _checkLocalUser();
        notifyListeners();
      }
    });
  }

  Future<void> _loadCurrentUser() async {
    _setLoading(true);
    final prefs = await SharedPreferences.getInstance();
    currUserId = prefs.getString("curr_user_id");
    currUsername = prefs.getString("curr_username");

    if (currUsername != null) {
      await _checkLocalUser();
    }

    _setLoading(false);
  }

  Future<bool> login(String username, String password) async {
    final email = "$username@kjm.admin.app";

    try {
      _setLoading(true);

      final resData = await db.get(
        adminTables,
        where: "username = ?",
        whereArgs: [username],
      );

      if (resData.isEmpty) {
        _setLoading(false);
        return false;
      }

      final res = UserAdmin.fromMap(resData.first);

      if (!verifyPassword(password, res.password)) {
        _setLoading(false);
        return false;
      }

      UserCredential userCred;
      try {
        userCred = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } on FirebaseAuthException catch (e) {
        print('⚠️ Firebase error: ${e.code} — ${e.message}');

        if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
          final userCred = await _auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString("curr_user_id", userCred.user!.uid);
          await prefs.setString("curr_username", username);

          currUserId = userCred.user!.uid;
          currUsername = username;
          currUserData = resData.first;

          _setLoading(false);
          notifyListeners();
          print('✅ User baru dibuat & login sukses untuk $email');
          return true;
        }

        if (e.code == 'wrong-password') {
          print('❌ Password salah di Firebase.');
          _setLoading(false);
          return false;
        }

        print('⚠️ Login error (Firebase): ${e.code} — ${e.message}');
        _setLoading(false);
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("curr_user_id", userCred.user!.uid);
      await prefs.setString("curr_username", username);

      currUserId = userCred.user!.uid;
      currUsername = username;
      currUserData = resData.first;
      await db.update(
        adminTables,
        id: res.id,
        data: {"last_login": DateTime.now().toIso8601String()},
      );

      _setLoading(false);
      notifyListeners();
      print('✅ Login sukses untuk $email');
      return true;
    } catch (e) {
      print("💥 Login error (Lainnya): $e");
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    await _auth.signOut();
    await _clearLocalUser();
    _setLoading(false);
    notifyListeners();
  }

  Future<void> _clearLocalUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("curr_user_id");
    await prefs.remove("curr_username");
    currUserId = null;
    currUsername = null;
    currUserData = null;
  }

  bool get isLoggedIn => _auth.currentUser != null;

  Future<void> _checkLocalUser() async {
    if (currUsername == null) return;

    final res = await db.get(
      adminTables,
      where: "username = ?",
      whereArgs: [currUsername],
    );

    if (res.isEmpty) {
      await logout();
    } else {
      currUserData = res.first;
    }
  }
}
