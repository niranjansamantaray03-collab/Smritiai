
import 'package:flutter/material.dart';

class SmritiTheme {
  SmritiTheme._();

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF526D82),
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          const Color(0xFFF7F8FA),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.w800,
          color: Colors.black87,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        margin: const EdgeInsets.symmetric(
          vertical: 6,
        ),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(18),
        ),
      ),
      elevatedButtonTheme:
          ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize:
              const Size.fromHeight(64),
          padding:
              const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme:
          OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize:
              const Size.fromHeight(64),
          padding:
              const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme:
          InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(16),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
        ),
        headlineSmall: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.w800,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          fontSize: 18,
          height: 1.35,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          height: 1.35,
        ),
      ),
    );
  }
}
