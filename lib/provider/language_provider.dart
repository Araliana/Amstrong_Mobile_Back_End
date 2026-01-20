import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/utils/app_strings.dart';

class LanguageProvider with ChangeNotifier {
  Locale _appLocale = const Locale('id'); // Default Bahasa Indonesia

  Locale get appLocale => _appLocale;

  LanguageProvider() {
    _loadLanguage();
  }

  // Mengambil teks berdasarkan key
  String getText(String key) {
    String languageCode = _appLocale.languageCode;
    return AppStrings.languages[languageCode]?[key] ?? key;
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString('language_code');
    if (savedCode != null) {
      _appLocale = Locale(savedCode);
      notifyListeners();
    }
  }

  Future<void> changeLanguage(Locale type) async {
    final prefs = await SharedPreferences.getInstance();
    if (_appLocale == type) return;
    
    if (type == const Locale('en')) {
      _appLocale = const Locale('en');
      await prefs.setString('language_code', 'en');
    } else {
      _appLocale = const Locale('id');
      await prefs.setString('language_code', 'id');
    }
    notifyListeners();
  }
}