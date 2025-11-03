import 'package:flutter/material.dart';
import '../model/change_password.dart';

class ChangePasswordProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<bool> changePassword(ChangePasswordModel model) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulasi panggilan API
      await Future.delayed(const Duration(seconds: 2));

      // Validasi sederhana, ganti sesuai API kamu
      if (model.newPassword == model.confirmPassword &&
          model.newPassword.length >= 6) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
