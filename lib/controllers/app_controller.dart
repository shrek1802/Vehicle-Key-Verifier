import 'package:flutter/material.dart';

import '../services/app_settings_service.dart';

class AppController extends ChangeNotifier {
  AppController(this._settingsService);

  final AppSettingsService _settingsService;

  bool _isReady = false;
  bool _darkMode = false;
  bool _ukOnly = true;
  String _geminiApiKey = '';

  bool get isReady => _isReady;
  bool get darkMode => _darkMode;
  bool get ukOnly => _ukOnly;
  String get geminiApiKey => _geminiApiKey;
  bool get hasGeminiApiKey => _geminiApiKey.trim().isNotEmpty;

  Future<void> initialise() async {
    _darkMode = await _settingsService.loadDarkMode();
    _ukOnly = await _settingsService.loadUkOnly();
    _geminiApiKey = await _settingsService.loadGeminiApiKey();
    _isReady = true;
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _darkMode = value;
    notifyListeners();
    await _settingsService.saveDarkMode(value);
  }

  Future<void> setUkOnly(bool value) async {
    _ukOnly = value;
    notifyListeners();
    await _settingsService.saveUkOnly(value);
  }

  Future<void> setGeminiApiKey(String value) async {
    _geminiApiKey = value.trim();
    notifyListeners();
    await _settingsService.saveGeminiApiKey(_geminiApiKey);
  }
}