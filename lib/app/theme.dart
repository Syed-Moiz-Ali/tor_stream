import 'package:flutter/material.dart';

class TorStreamTheme {
  static const Color _seedColor = Color(0xFF7C6EF8);
  static const Color _surfaceDark = Color(0xFF0D0D14);
  static const Color _surfaceCard = Color(0xFF13131F);

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seedColor,
        brightness: Brightness.dark,
        surface: _surfaceDark,
      ),
      scaffoldBackgroundColor: _surfaceDark,
      cardTheme: CardThemeData(
        color: _surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _surfaceDark,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _surfaceCard,
        selectedItemColor: _seedColor,
        unselectedItemColor: Color(0xFF6B6B80),
      ),
      fontFamily: 'Roboto',
    );
  }
}
