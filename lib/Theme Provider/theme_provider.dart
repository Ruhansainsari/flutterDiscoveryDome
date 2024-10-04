import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme(bool isDarkMode) {
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    //when the toggleTheme method is called
    // it updates _themeMode and triggers notifyListeners().
    // causes MaterialApp to rebuild, applying the new theme.
  }
}
