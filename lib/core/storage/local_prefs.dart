import 'package:shared_preferences/shared_preferences.dart';

class LocalPrefs {
  static const keyRole = 'role';
  static const keyProfileCompleted = 'profileCompleted';
  static const keyLanguage = 'language';
  static const keyName = 'name';
  static const keyPhone = 'phone';
  static const keyWard = 'ward';
  static const keyCity = 'city';

  static Future<void> setString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  static Future<void> setBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  static Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<bool?> getBool(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
