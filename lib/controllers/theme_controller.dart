import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ThemeController extends ChangeNotifier {
  late Box _themeBox;
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeController() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    _themeBox = await Hive.openBox('settings');
    _isDarkMode = _themeBox.get('darkMode', defaultValue: false);
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _themeBox.put('darkMode', _isDarkMode);
    notifyListeners();
  }
}
