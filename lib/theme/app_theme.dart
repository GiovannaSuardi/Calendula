import 'package:flutter/material.dart';

/// Tema pensato per persone anziane: testo grande, alto contrasto,
/// pulsanti ampi e facili da toccare.
class AppTheme {
  // Arancione calendula come colore principale.
  static const Color calendula = Color(0xFFE8890C);

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: calendula,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFFFFBF5),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 22),
        bodyMedium: TextStyle(fontSize: 20),
        labelLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        titleTextStyle: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        toolbarHeight: 72,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        labelStyle: TextStyle(fontSize: 20),
        hintStyle: TextStyle(fontSize: 20),
        errorStyle: TextStyle(fontSize: 18),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 64),
          textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
