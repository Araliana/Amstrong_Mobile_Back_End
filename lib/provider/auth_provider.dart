import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/db/sync_manager.dart';
import 'package:flutter_application_1/utils/index.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  AuthProvider() {
    _listenAuthState();
  }

  void _listenAuthState() {
    _auth.authStateChanges().listen((user) async {
      if (user == null) {
        await _clearLocal();
      } else {
        currUserUid = user.uid;
        await _loadUserProfile();
        await _checkPasswordFingerprint();
      }
      notifyListeners();
    });
  }

  Future<void> loadCurrentUser() async {
    _setLoading(true);

    final firebaseUser = _auth.currentUser;

    // ❌ Tidak ada session Firebase
    if (firebaseUser == null) {
      await _clearLocal();
      _setLoading(false);
      return;
    }

    // ✅ Firebase session masih hidup
    currUserUid = firebaseUser.uid;

    try {
      // Ambil profile user dari Firestore
      await _loadUserProfile();

      // Cek apakah password diganti oleh master
      await _checkPasswordFingerprint();

      // Sinkronisasi data lokal ↔ server
      await sync.syncAll();

      await analytics.logEvent(
        name: 'auto_login_success',
        parameters: {
          'firebase_user_id': currUserUid!,
          if (currUserId != null) 'user_id': currUserId!,
        },
      );
    } catch (e) {
      // Kalau user Firestore hilang / data korup → logout paksa
      print('⚠️ Auto login failed, force logout: $e');
      await logout();
    }

    _setLoading(false);
    notifyListeners();
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
            password: password,
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

      currUserUid = userCred.user!.uid;
      currUserId = userData['id'];

      // await _loadUserProfile();
      // await analytics.logLogin(loginMethod: 'email_password');

      _setLoading(false);
      notifyListeners();
      await sync.syncAll();
      return true;
    } on FirebaseAuthException catch (e) {
      print('❌ Login error: ${e.message}');
      _setLoading(false);
      return false;
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      final doc = await firestore
          .collection('user_admin')
          .doc(currUserId)
          .get();

      if (!doc.exists) {
        throw Exception('User profile missing in Firestore');
      }

      final data = doc.data()!;
      currUserId = data['id'];

      final fingerprint = data['password_fingerprint'];
      if (fingerprint != null) {
        await secureStorage.write(
          key: 'password_fingerprint',
          value: fingerprint,
        );
      }
    } catch (e) {
      print('❌ Load user profile error: $e');
    }
  }

  Future<void> logout() async {
    _setLoading(true);
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

      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );
      await user.reauthenticateWithCredential(cred);

      await user.updatePassword(newPassword);

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
      print('⚠️ Password diganti master → logout');
      await analytics.logEvent(
        name: 'auto_logout_password_changed',
        parameters: {'user_id': currUserId ?? 'unknown'},
      );
      await logout();
    }
  }

  Future<void> _clearLocal() async {
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
