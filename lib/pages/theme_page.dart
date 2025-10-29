// theme_page.dart

import 'package:flutter/material.dart';

class AppTheme {
  // 🎨 Warna utama aplikasi
  static const Color primaryColor = Color(0xFF800000); // Maroon elegan
  static const Color secondaryColor = Color(0xFFD4A373); // Beige keemasan lembut
  static const Color backgroundColor = Color(0xFFFDFBF7); // Putih krem lembut
  static const Color cardColor = Color(0xFFFFFFFF); // Putih bersih
  static const Color textPrimaryColor = Color(0xFF2E2E2E); // Abu gelap natural
  static const Color textSecondaryColor = Color(0xFF7A7A7A); // Abu lembut netral

  // 🌈 Gradient opsional (Maroon → Beige)
  static const LinearGradient mainGradient = LinearGradient(
    colors: [primaryColor, secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 🌕 Tema Terang
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    cardColor: cardColor,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      background: backgroundColor,
      surface: cardColor,
      onPrimary: Colors.white,
      onSecondary: textPrimaryColor,
      onBackground: textPrimaryColor,
      onSurface: textPrimaryColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 2,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 20,
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        color: textPrimaryColor,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: TextStyle(
        color: textSecondaryColor,
        fontSize: 14,
      ),
      titleLarge: TextStyle(
        color: textPrimaryColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      labelLarge: TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hintStyle: const TextStyle(color: textSecondaryColor),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: secondaryColor, width: 1.2),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );

  // ✅✅✅ SEMUA GETTER 'null' DI BAWAH INI SUDAH DIHAPUS ✅✅✅
}