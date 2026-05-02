import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;

  bool get isDarkMode => _isDarkMode;
  bool get notificationsEnabled => _notificationsEnabled;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool('darkMode') ?? false;
      _notificationsEnabled = prefs.getBool('notifications') ?? true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  Future<void> setDarkMode(bool value) async {
    try {
      _isDarkMode = value;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('darkMode', value);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving dark mode: $e');
    }
  }

  Future<void> setNotifications(bool value) async {
    try {
      _notificationsEnabled = value;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications', value);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving notifications: $e');
    }
  }

  Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing data: $e');
    }
  }

  Future<String> exportData(String jsonData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final exportKey = 'export_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString(exportKey, jsonData);
      return exportKey;
    } catch (e) {
      debugPrint('Error exporting data: $e');
      return '';
    }
  }
}
