import 'package:flutter/material.dart';

class TorStreamTheme {
  static const Color seedColor = Color(0xFF7C6EF8);
  static const Color surfaceDark = Color(0xFF0A0A12);
  static const Color surfaceCard = Color(0xFF12121E);
  static const Color surfaceElevated = Color(0xFF1A1A2E);
  static const Color accentGreen = Color(0xFF2ECC71);
  static const Color accentAmber = Color(0xFFFFB347);
  static const Color accentRed = Color(0xFFE74C3C);
  static const Color textSecondary = Color(0xFF8B8B9E);
  static const Color dividerColor = Color(0xFF1E1E30);

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
        surface: surfaceDark,
        primary: seedColor,
      ),
      scaffoldBackgroundColor: surfaceDark,
      fontFamily: 'Roboto',

      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceDark,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
      ),

      cardTheme: CardThemeData(
        color: surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: dividerColor, width: 0.5),
        ),
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.symmetric(vertical: 5),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceCard,
        indicatorColor: seedColor.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((_) => const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        )),
      ),

      tabBarTheme: const TabBarThemeData(
        indicatorColor: seedColor,
        labelColor: seedColor,
        unselectedLabelColor: textSecondary,
        labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: seedColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: seedColor,
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: seedColor.withValues(alpha: 0.1),
        labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: seedColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentRed),
        ),
        hintStyle: TextStyle(color: textSecondary.withValues(alpha: 0.6)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 0.5,
        space: 0,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.5),
        headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: -0.3),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: -0.2),
        titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, letterSpacing: -0.1),
        titleSmall: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.2),
        bodyLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, letterSpacing: 0.1),
        bodyMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, letterSpacing: 0.1),
        labelLarge: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.3),
        labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.3),
      ),
    );
  }
}
