import 'package:flutter/material.dart';

class AppColors {
  /// Warm cream from the Foodridge illustration wallpaper.
  static const Color canvas = Color(0xFFFDF6E9);
  static const Color ink = Color(0xFF3C2A21);
  static const Color sage = Color(0xFF5E734C);
  static const Color primary = Color(0xFF5E734C);
  static const Color secondary = Color(0xFFC9844A);
  static const Color providerPrimary = Color(0xFF5B6E4E);

  static const Color gold = Color(0xFFC5A059);
  static const Color goldBright = Color(0xFFD4AF37);
  static const Color chinguBlack = Color(0xFF0B0B0B);
  static const Color chinguCard = Color(0xFF141414);
  static const Color chinguBorder = Color(0xFF333333);
  static const Color liveRed = Color(0xFFE53935);

  static const Color vendingBg = Color(0xFF0B140E);
  static const Color vendingCard = Color(0xFF122018);
  static const Color vendingAccent = Color(0xFF8FCBB0);
  static const Color vendingLeaf = Color(0xFF3D8B6E);
}

class AppTheme {
  static const Color primary = AppColors.primary;
  static const Color secondary = AppColors.secondary;
  static const Color providerPrimary = AppColors.providerPrimary;

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.canvas,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.sage,
        brightness: Brightness.light,
        surface: AppColors.canvas,
        primary: AppColors.sage,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.canvas,
        foregroundColor: AppColors.ink,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: const Color(0xFFFFFBF3),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.sage,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  static ThemeData get chinguDark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.chinguBlack,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.gold,
        secondary: AppColors.goldBright,
        surface: AppColors.chinguCard,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.chinguBlack,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}
