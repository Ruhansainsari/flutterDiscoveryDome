import 'package:flutter/material.dart';
import 'Theme Provider/dark_theme_provider.dart';
import 'Views/login_screen.dart';

void main() {
  runApp(DiscoveryDomeApp());
}

class DiscoveryDomeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: DarkThemeProvider.darkTheme, // Listen for theme changes
      builder: (context, isDarkMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: isDarkMode ? Brightness.dark : Brightness.light,
            primarySwatch: Colors.purple,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: LoginScreen(),
        );
      },
    );
  }
}
