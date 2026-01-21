import 'dart:convert';
import 'package:azkari_app/models/display_setting_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  static const String _settingsKey = 'display_settings';
  DisplaySettingsModel _settings = DisplaySettingsModel();

  /* ================================
     LOAD SETTINGS
  ================================= */
  Future<DisplaySettingsModel> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? settingsJson = prefs.getString(_settingsKey);

      if (settingsJson != null) {
        _settings = DisplaySettingsModel.fromJson(json.decode(settingsJson));
      }

      return _settings;
    } catch (e) {
      print('Error loading settings: $e');
      return DisplaySettingsModel();
    }
  }

  /* ================================
     SAVE SETTINGS
  ================================= */
  Future<void> saveSettings(DisplaySettingsModel settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _settings = settings;
      await prefs.setString(_settingsKey, json.encode(settings.toJson()));
    } catch (e) {
      print('Error saving settings: $e');
    }
  }

  /* ================================
     GET CURRENT SETTINGS
  ================================= */
  DisplaySettingsModel get settings => _settings;
}
