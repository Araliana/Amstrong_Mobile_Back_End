import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? currUserId;
  String? currUsername;

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
        notifyListeners();
      }
    });
  }

  Future<void> _loadCurrentUser() async {
    _setLoading(true);
    final prefs = await SharedPreferences.getInstance();
    currUserId = prefs.getString("curr_user_id");
    currUsername = prefs.getString("curr_username");
    _setLoading(false);
  }

  Future<bool> login(String username, String password) async {
    try {
      _setLoading(true);
      final email = "$username@kjm.local";

      final userCred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("curr_user_id", userCred.user!.uid);
      await prefs.setString("curr_username", username);

      currUserId = userCred.user!.uid;
      currUsername = username;

      _setLoading(false);
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      print("Login error: $e");
      _setLoading(false);
      return false;
    }
  }

  /// Logout user
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
  }

  bool get isLoggedIn => _auth.currentUser != null;
}
