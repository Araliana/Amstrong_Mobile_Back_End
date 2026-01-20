import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/db/db_helper.dart';
import 'package:flutter_application_1/db/sync_manager.dart';
import 'package:flutter_application_1/utils/index.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  // Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  // Secure storage
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  // State
  String? currUserUid;
  String? currUserId;
  bool isLoading = false;

  final sync = SyncManager();
  final db = DBHelper();

  AuthProvider() {
    _listenAuthState();
  }

  void _listenAuthState() {
    _auth.authStateChanges().listen((user) async {
      if (user == null) {
        await _clearLocal();
      } else {
        currUserUid = user.uid;
        await _checkPasswordFingerprint();
      }
      notifyListeners();
    });
  }

  Future<void> loadCurrentUser() async {
    _setLoading(true);

    try {
      final firebaseUser = _auth.currentUser;

      if (firebaseUser == null) {
        await _clearLocal();
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      currUserUid = prefs.getString('curr_user_uid');
      currUserId = prefs.getString('curr_user_id');

      await _checkPasswordFingerprint();

      await analytics.logEvent(
        name: 'auto_login_success',
        parameters: {
          'firebase_user_id': currUserUid!,
          if (currUserId != null) 'user_id': currUserId!,
        },
      );
    } catch (e, s) {
      print('loadCurrentUser error: $e\n$s');
      await logout();
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    final email = "$username@kjm.admin.app";
    try {
      _setLoading(true);

      final snap = await firestore
          .collection('user_admin')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (snap.docs.isEmpty) {
        _setLoading(false);
        return false;
      }

      final userData = snap.docs.first.data();

      if (!verifyPassword(password, userData['password'])) {
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
        if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
          userCred = await _auth.createUserWithEmailAndPassword(
            email: email,
            password: password, // Gunakan password asli, bukan hash!
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
        } else {
          _setLoading(false);
          await analytics.logEvent(
            name: 'login_failed',
            parameters: {'reason': e.code, 'username': username},
          );
          return false;
        }
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('curr_user_uid', userCred.user!.uid);
      await prefs.setString('curr_user_id', userData['id']);

      currUserUid = userCred.user!.uid;
      currUserId = userData['id'];

      _setLoading(false);
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException: $e");
      _setLoading(false);
      return false;
    } catch (e) {
      print("Login error: $e");
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    await sync.syncAll();
    await _auth.signOut();
    await _clearLocal();
    _setLoading(false);
    notifyListeners();
  }

  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      _setLoading(true);

      final fingerprint = _passwordFingerprint(newPassword);

      await firestore.collection('users').doc(user.uid).update({
        'password_fingerprint': fingerprint,
        'updated_at': FieldValue.serverTimestamp(),
      });

      await secureStorage.write(
        key: 'password_fingerprint',
        value: fingerprint,
      );

      await analytics.logEvent(name: 'change_password_success');

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setLoading(false);
      return false;
    }
  }

  Future<void> _checkPasswordFingerprint() async {
    if (currUserUid == null) return;

    final local = await secureStorage.read(key: 'password_fingerprint');

    final doc = await firestore.collection('users').doc(currUserUid).get();

    if (!doc.exists) return;

    final server = doc.data()?['password_fingerprint'];

    if (local != null && server != null && local != server) {
      await analytics.logEvent(
        name: 'auto_logout_password_changed',
        parameters: {'user_id': currUserId ?? 'unknown'},
      );
      await logout();
    }
  }

  Future<void> _clearLocal() async {
    db.clearDB();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('curr_user_uid');
    await prefs.remove('curr_user_id');
    currUserUid = null;
    currUserId = null;
    await secureStorage.delete(key: 'password_fingerprint');
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  bool get isLoggedIn => currUserUid != null;
}

String _passwordFingerprint(String password) {
  final bytes = utf8.encode(password);
  final digest = sha256.convert(bytes);
  return digest.toString();
}
