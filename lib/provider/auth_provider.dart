import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/model/user_admin.dart';
import 'package:flutter_application_1/utils/index.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/db/db_helper.dart';
import 'package:bcrypt/bcrypt.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DBHelper db = DBHelper();
  final Tables adminTables = Tables.userAdmin;

  String? currUserId;
  String? currDbUserId; // Store the ID from the local DB
  Map<String, dynamic>? currUserData;

  bool isLoading = false;

  AuthProvider() {
    loadCurrentUser();
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
        await analytics.logEvent(
          name: 'auth_state_change',
          parameters: {'status': 'logged_out'},
        );
        notifyListeners();
      } else {
        currUserId = user.uid;

        // pastikan currDbUserId sudah terisi (misalnya dari SharedPreferences)
        final prefs = await SharedPreferences.getInstance();
        currDbUserId ??= prefs.getString("curr_db_user_id");

        await _checkLocalUser();

        await analytics.logEvent(
          name: 'auth_state_change',
          parameters: {
            'status': 'logged_in',
            if (currUserId != null) 'firebase_user_id': currUserId!,
            if (currDbUserId != null) 'db_user_id': currDbUserId!,
          },
        );

        notifyListeners();
      }
    });
  }

  Future<void> loadCurrentUser() async {
    _setLoading(true);
    final prefs = await SharedPreferences.getInstance();
    currUserId = prefs.getString("curr_user_id");
    currDbUserId = prefs.getString("curr_db_user_id");

    if (currDbUserId != null) {
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
        await analytics.logEvent(
          name: 'login_failed',
          parameters: {'reason': 'username_not_found', 'username': username},
        );
        return false;
      }

      final res = UserAdmin.fromMap(resData.first);

      // Verify password using bcrypt
      if (!BCrypt.checkpw(password, res.password)) {
        _setLoading(false);
        await analytics.logEvent(
          name: 'login_failed',
          parameters: {'reason': 'wrong_password', 'username': username},
        );
        return false;
      }

      UserCredential userCred;
      try {
        // Try signing in with the user's email and the *unhashed* password
        userCred = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } on FirebaseAuthException catch (e) {
        print('⚠️ Firebase error: ${e.code} — ${e.message}');

        // If user is not found in Firebase, create them
        if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
          final userCred = await _auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );

          if (userCred.user != null) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString("curr_user_id", userCred.user!.uid);
            await prefs.setString("curr_db_user_id", res.id.toString());

            currUserId = userCred.user!.uid;
            currDbUserId = res.id.toString();
            currUserData = resData.first;

            await db.update(
              adminTables,
              id: res.id,
              data: {"last_login": DateTime.now().toIso8601String()},
            );

            _setLoading(false);

            await analytics.logEvent(
              name: 'user_created',
              parameters: {
                'username': username,
                if (currUserId != null) 'firebase_user_id': currUserId!,
              },
            );

            notifyListeners();
            print('✅ User baru dibuat di Firebase & login sukses untuk $email');
            return true;
          } else {
            _setLoading(false);
            print('❌ User creation failed - user is null');
            return false;
          }
        }

        if (e.code == 'wrong-password') {
          print('❌ Password salah di Firebase.');
          _setLoading(false);
          await analytics.logEvent(
            name: 'login_failed',
            parameters: {
              'reason': 'firebase_wrong_password',
              'username': username,
            },
          );
          return false;
        }

        print('⚠️ Login error (Firebase): ${e.code} — ${e.message}');
        _setLoading(false);
        await analytics.logEvent(
          name: 'login_failed',
          parameters: {'reason': e.code, 'username': username},
        );
        return false;
      }

      if (userCred.user == null) {
        _setLoading(false);
        print('❌ Login failed - user is null');
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("curr_user_id", userCred.user!.uid);
      await prefs.setString("curr_db_user_id", res.id.toString());

      currUserId = userCred.user!.uid;
      currDbUserId = res.id.toString();
      currUserData = resData.first;

      await db.update(
        adminTables,
        id: res.id,
        data: {"last_login": DateTime.now().toIso8601String()},
      );

      _setLoading(false);
      await analytics.logLogin(loginMethod: 'email_password');
      await analytics.logEvent(
        name: 'login_success',
        parameters: {
          'username': username,
          if (currUserId != null) 'firebase_user_id': currUserId!,
          if (currDbUserId != null) 'db_user_id': currDbUserId!,
        },
      );
      notifyListeners();
      print('✅ Login sukses untuk $email');
      return true;
    } catch (e) {
      print("💥 Login error (Lainnya): $e");
      _setLoading(false);
      await analytics.logEvent(
        name: 'login_failed',
        parameters: {'reason': 'exception', 'error': e.toString()},
      );
      return false;
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    final userId = currUserId;
    final dbUserId = currDbUserId;
    await _auth.signOut();
    await _clearLocalUser();
    await db.clearDB();
    _setLoading(false);
    await analytics.logEvent(
      name: 'logout',
      parameters: {
        if (userId != null) 'firebase_user_id': userId,
        if (dbUserId != null) 'db_user_id': dbUserId,
      },
    );
    notifyListeners();
  }

  Future<void> _clearLocalUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("curr_user_id");
    await prefs.remove("curr_db_user_id");
    currUserId = null;
    currDbUserId = null;
    currUserData = null;
  }

  bool get isLoggedIn => _auth.currentUser != null;

  Future<void> _checkLocalUser() async {
    if (currDbUserId == null) return;

    final res = await db.get(adminTables, where: "password = ?", whereArgs: []);

    if (res.isEmpty) {
      await logout();
      await analytics.logEvent(
        name: 'local_user_not_found',
        parameters: {if (currDbUserId != null) 'db_user_id': currDbUserId!},
      );
    } else {
      currUserData = res.first;
    }
  }
}
