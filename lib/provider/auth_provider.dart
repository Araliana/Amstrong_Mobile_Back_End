import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/utils/index.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_application_1/model/user_admin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/db/db_helper.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class AuthProvider with ChangeNotifier {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DBHelper db = DBHelper();
  final Tables adminTables = Tables.userAdmin;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  String? currUserUid;
  String? currUserId;

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
        currUserUid = user.uid;
        final prefs = await SharedPreferences.getInstance();
        currUserId ??= prefs.getString("curr_user_id");
        await _checkLocalUser();

        await analytics.logEvent(
          name: 'auth_state_change',
          parameters: {
            'status': 'logged_in',
            if (currUserUid != null) 'firebase_user_id': currUserUid!,
            if (currUserId != null) 'user_id': currUserId!,
          },
        );
        notifyListeners();
      }
    });
  }

  Future<void> loadCurrentUser() async {
    _setLoading(true);
    final prefs = await SharedPreferences.getInstance();
    currUserUid = prefs.getString("curr_user_uid");
    currUserId = prefs.getString("curr_user_id");

    if (currUserId != null) {
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

      final user = UserAdmin.fromMap(resData.first);

      // ✅ Verifikasi password lokal
      if (!verifyPassword(password, user.password)) {
        _setLoading(false);
        await analytics.logEvent(
          name: 'login_failed',
          parameters: {'reason': 'wrong_password', 'username': username},
        );
        return false;
      }

      // ✅ Coba login ke Firebase
      UserCredential userCred;
      try {
        userCred = await _auth.signInWithEmailAndPassword(
          email: email,
          password: user.password,
        );
      } on FirebaseAuthException catch (e) {
        // Jika user belum ada → buat baru
        if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
          userCred = await _auth.createUserWithEmailAndPassword(
            email: email,
            password: user.password,
          );
        } else if (e.code == 'wrong-password') {
          _setLoading(false);
          await analytics.logEvent(
            name: 'login_failed',
            parameters: {
              'reason': 'firebase_wrong_password',
              'username': username,
            },
          );
          return false;
        } else {
          _setLoading(false);
          await analytics.logEvent(
            name: 'login_failed',
            parameters: {'reason': e.code, 'username': username},
          );
          return false;
        }
      }

      if (userCred.user == null) {
        _setLoading(false);
        print('❌ Firebase login failed: null user');
        return false;
      }

      currUserUid = userCred.user!.uid;
      currUserId = user.id.toString();

      // ✅ Simpan ID user di SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("curr_user_uid", currUserUid!);
      await prefs.setString("curr_user_id", currUserId!);

      // ✅ Simpan hash password (versi aman)
      final doubleHash = _doubleHash(user.password);
      await secureStorage.write(key: 'curr_user_pass_hash', value: doubleHash);

      // ✅ Update last login
      await db.update(
        adminTables,
        id: user.id,
        data: {"last_login": DateTime.now().toIso8601String()},
      );

      _setLoading(false);

      await analytics.logLogin(loginMethod: 'email_password');
      await analytics.logEvent(
        name: 'login_success',
        parameters: {
          'username': username,
          if (currUserUid != null) 'firebase_user_id': currUserUid!,
          if (currUserId != null) 'user_id': currUserId!,
        },
      );

      notifyListeners();
      print('✅ Login sukses: $email');
      return true;
    } catch (e) {
      print("💥 Login error: $e");
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
    final userUid = currUserUid;
    final userId = currUserId;

    await _auth.signOut();
    await _clearLocalUser();
    await db.clearDB();

    _setLoading(false);
    await analytics.logEvent(
      name: 'logout',
      parameters: {
        if (userUid != null) 'firebase_user_id': userUid,
        if (userId != null) 'user_id': userId,
      },
    );

    notifyListeners();
  }

  Future<void> _clearLocalUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("curr_user_uid");
    await prefs.remove("curr_user_id");
    await secureStorage.delete(key: 'curr_user_pass_hash');
    currUserUid = null;
    currUserId = null;
  }

  bool get isLoggedIn => _auth.currentUser != null;

  // 🧩 Fungsi keamanan tambahan
  String _doubleHash(String hash) {
    return sha256.convert(utf8.encode(hash)).toString();
  }

  // ✅ Auto logout bila password DB berubah
  Future<void> _checkLocalUser() async {
    if (currUserId == null) return;

    final res = await db.get(
      adminTables,
      where: "id = ?",
      whereArgs: [currUserId],
    );
    if (res.isEmpty) {
      await logout();
      await analytics.logEvent(
        name: 'local_user_deleted',
        parameters: {'user_id': currUserId ?? 'unknown'},
      );
      return;
    }

    final localUser = UserAdmin.fromMap(res.first);
    final storedHash = await secureStorage.read(key: 'curr_user_pass_hash');
    final currentDoubleHash = _doubleHash(localUser.password);

    // 💡 Jika password hash beda (master ubah password)
    if (storedHash != null && storedHash != currentDoubleHash) {
      print('⚠️ Password changed in DB — auto logout');
      await logout();
      await analytics.logEvent(
        name: 'auto_logout_due_to_password_change',
        parameters: {'user_id': currUserId ?? 'unknown'},
      );
    }
  }

  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null || currUserUid == null) {
      print('❌ Tidak ada user yang sedang login.');
      return false;
    }

    _setLoading(true);
    try {
      // 🔐 Reauthenticate dulu pakai password lama
      final email = user.email ?? "${currUserId ?? 'unknown'}@kjm.admin.app";
      final cred = EmailAuthProvider.credential(
        email: email,
        password: hashPassword(oldPassword),
      );
      await user.reauthenticateWithCredential(cred);

      // 🔒 Simpan double hash baru di secure storage
      final hashed = hashPassword(newPassword); // gunakan fungsi hash kamu
      final doubleHash = _doubleHash(hashed);

      // 🔁 Ganti password di Firebase
      await user.updatePassword(hashPassword(hashed));

      await secureStorage.write(key: 'curr_user_pass_hash', value: doubleHash);

      // 🧾 Log ke Firebase Analytics
      await analytics.logEvent(
        name: 'change_password_success',
        parameters: {
          'firebase_user_id': currUserUid!,
          if (currUserId != null) 'user_id': currUserId!,
        },
      );

      print('✅ Password berhasil diubah di Firebase untuk $email');
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      print('⚠️ Firebase error: ${e.code} — ${e.message}');
      await analytics.logEvent(
        name: 'change_password_failed',
        parameters: {'reason': e.code, 'firebase_user_id': currUserUid ?? ''},
      );
      _setLoading(false);
      return false;
    } catch (e) {
      print('💥 Gagal ubah password: $e');
      await analytics.logEvent(
        name: 'change_password_failed',
        parameters: {
          'reason': 'exception',
          'error': e.toString(),
          'firebase_user_id': currUserUid ?? '',
        },
      );
      _setLoading(false);
      return false;
    }
  }
}
