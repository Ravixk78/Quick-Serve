import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryColor = Color(0xFF0D1B2A);
  static const Color secondaryColor = Color(0xFFE9C46A);
  static const Color accentColor = Color(0xFF1B263B);

  static const Color primaryNavy = primaryColor;
  static const Color lightNavy = accentColor;
  static const Color premiumGold = secondaryColor;

  // Light Mode Colors
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color lightCard = Colors.white;
  static const Color lightTextPrimary = Color(
    0xFF0D1B2A,
  ); // Dark for light mode
  static const Color lightTextSecondary = Color(0xFF475569);

  // Dark Mode Colors
  static const Color darkBg = Color(0xFF0B121E);
  static const Color darkCard = Color(0xFF1B263B);
  static const Color darkTextPrimary = Colors.white; // White for dark mode
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  // Status Colors
  static const Color successColor = Color(0xFF2A9D8F);
  static const Color warningColor = Color(0xFFF4A261);
  static const Color errorColor = Color(0xFFE76F51);
  static const Color infoColor = Color(0xFF457B9D);
  static const Color accentGreen = Color(0xFF48BB78); // For success states

  // --- LIGHT THEME ---
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: lightBg,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: lightCard,
      onSurface: lightTextPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: primaryColor),
      titleTextStyle: TextStyle(
        color: primaryColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryColor,
      unselectedItemColor: Color(0xFF94A3B8),
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: lightTextPrimary,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: lightTextPrimary,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        color: lightTextPrimary,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(color: lightTextPrimary),
      bodyMedium: TextStyle(color: lightTextSecondary),
      bodySmall: TextStyle(color: lightTextSecondary),
    ),
  );

  // --- DARK THEME ---
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: secondaryColor,
    scaffoldBackgroundColor: darkBg,
    colorScheme: const ColorScheme.dark(
      primary: secondaryColor,
      secondary: secondaryColor,
      surface: darkCard,
      onSurface: darkTextPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkBg,
      selectedItemColor: secondaryColor,
      unselectedItemColor:
          Colors.white70, // White text for bottom bar in dark mode
      selectedLabelStyle: TextStyle(
        fontWeight: FontWeight.bold,
        color: secondaryColor,
      ),
      unselectedLabelStyle: TextStyle(color: Colors.white70),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: darkTextPrimary,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: darkTextPrimary,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        color: darkTextPrimary,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(color: darkTextPrimary),
      bodyMedium: TextStyle(color: darkTextSecondary),
      bodySmall: TextStyle(color: darkTextSecondary),
    ),
  );
}
