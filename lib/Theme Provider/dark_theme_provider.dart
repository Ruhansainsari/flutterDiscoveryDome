import 'package:flutter/material.dart';

class DarkThemeProvider {
  // ValueNotifier to track if dark mode is enabled
  static ValueNotifier<bool> darkTheme = ValueNotifier(false);

  static void toggleTheme(bool isDarkMode) {
    darkTheme.value = isDarkMode;
  }
}
