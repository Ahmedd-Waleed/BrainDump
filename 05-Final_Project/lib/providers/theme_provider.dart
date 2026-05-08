/// Theme Provider
///
/// Manages the app's light/dark/system theme mode.
/// Persists choice to SharedPreferences.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _key = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  String get label {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  ThemeProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    if (saved == 'light') _themeMode = ThemeMode.light;
    if (saved == 'dark') _themeMode = ThemeMode.dark;
    if (saved == 'system') _themeMode = ThemeMode.system;
    notifyListeners();
  }

  Future<void> setTheme(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final value = mode == ThemeMode.light
        ? 'light'
        : mode == ThemeMode.dark
            ? 'dark'
            : 'system';
    await prefs.setString(_key, value);
  }

  Future<void> setFromLabel(String label) async {
    switch (label) {
      case 'Light':
        await setTheme(ThemeMode.light);
        break;
      case 'Dark':
        await setTheme(ThemeMode.dark);
        break;
      default:
        await setTheme(ThemeMode.system);
    }
  }
}
