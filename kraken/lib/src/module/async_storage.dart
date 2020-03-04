import 'package:shared_preferences/shared_preferences.dart';

class AsyncStorage {
  static Future<SharedPreferences> _prefs;

  /// Loads and parses the [SharedPreferences] for this app from disk.
  ///
  /// Because this is reading from disk, it shouldn't be awaited in
  /// performance-sensitive blocks.
  static Future<SharedPreferences> _getPrefs() {
    if (_prefs == null) _prefs = SharedPreferences.getInstance();
    return _prefs;
  }

  static Future<bool> setItem(String key, String value) async {
    SharedPreferences prefs = await _getPrefs();
    return prefs.setString(key, value);
  }

  static Future<String> getItem(String key) async {
    SharedPreferences prefs = await _getPrefs();
    return prefs.getString(key);
  }

  static Future<bool> removeItem(String key) async {
    SharedPreferences prefs = await _getPrefs();
    return prefs.remove(key);
  }

  static Future<Set<String>> getAllKeys() async {
    SharedPreferences prefs = await _getPrefs();
    return prefs.getKeys();
  }

  static Future<bool> clear() async {
    SharedPreferences prefs = await _getPrefs();
    return prefs.clear();
  }
}
