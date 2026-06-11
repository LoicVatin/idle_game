import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static const String _tutorial = "tutorial";

  // Set Value (Generic)
  static Future<void> _setValue<T>(String key, T value) async {
    final pref = SharedPreferencesAsync();
    if (value is String) {
      await pref.setString(key, value);
    } else if (value is List<String>) {
      await pref.setStringList(key, value);
    } else if (value is int) {
      await pref.setInt(key, value);
    } else if (value is bool) {
      await pref.setBool(key, value);
    } else if (value is double) {
      await pref.setDouble(key, value);
    } else {
      throw Exception('Unsupported type');
    }
  }

  // Get Value (Generic)
  static Future<T?> _getValue<T>(String key) async {
    final pref = SharedPreferencesAsync();
    if (T == String) {
      return await pref.getString(key) as T?;
    } else if (T == List<String>) {
      return await pref.getStringList(key) as T?;
    } else if (T == int) {
      return await pref.getInt(key) as T?;
    } else if (T == bool) {
      return await pref.getBool(key) as T?;
    } else if (T == double) {
      return await pref.getDouble(key) as T?;
    } else {
      throw Exception('Unsupported type');
    }
  }

  // Tutorial at startup
  static Future<bool> isTutorialAtStartupDismissed() async {
    return await _getValue<bool>(_tutorial) ?? false;
  }

  static void dismissTutorial() {
    _setValue<bool>(_tutorial, true);
  }
}
