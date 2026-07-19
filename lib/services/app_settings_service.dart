import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsService {
  static const _darkModeKey = 'dark_mode';
  static const _ukOnlyKey = 'uk_only';
  static const _geminiApiKey = 'gemini_api_key';

  Future<bool> loadDarkMode() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_darkModeKey) ?? false;
  }

  Future<void> saveDarkMode(bool value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_darkModeKey, value);
  }

  Future<bool> loadUkOnly() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_ukOnlyKey) ?? true;
  }

  Future<void> saveUkOnly(bool value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_ukOnlyKey, value);
  }

  Future<String> loadGeminiApiKey() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_geminiApiKey) ?? '';
  }

  Future<void> saveGeminiApiKey(String value) async {
    final preferences = await SharedPreferences.getInstance();
    final cleaned = value.trim();

    if (cleaned.isEmpty) {
      await preferences.remove(_geminiApiKey);
      return;
    }

    await preferences.setString(_geminiApiKey, cleaned);
  }
}