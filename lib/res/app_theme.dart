import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF07569E);

  // ألوان النصوص الجديدة
  static const Color darkNavy = Color(0xFF0F172A);
  static const Color normalText = Color(0xFF1E293B);
  static const Color mutedText = Color(0xFF52657A);

  static const Color accentRed = Color(0xFFD72638);
  static const Color pageBackground = Color(0xFFF4F7FB);
  static const Color borderColor = Color(0xFFE3E9F0);
  static const Color successGreen = Color(0xFF16765C);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: pageBackground,

      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: accentRed,
        surface: Colors.white,
        onSurface: darkNavy,
        onSurfaceVariant: normalText,
        outline: borderColor,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: darkNavy,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: darkNavy,
          fontSize: 20,
          height: 1.2,
          fontWeight: FontWeight.w800,
        ),
      ),

      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: darkNavy,
          fontSize: 30,
          height: 1.2,
          fontWeight: FontWeight.w900,
        ),
        headlineMedium: TextStyle(
          color: darkNavy,
          fontSize: 24,
          height: 1.2,
          fontWeight: FontWeight.w900,
        ),
        headlineSmall: TextStyle(
          color: darkNavy,
          fontSize: 21,
          height: 1.25,
          fontWeight: FontWeight.w800,
        ),
        titleLarge: TextStyle(
          color: darkNavy,
          fontSize: 20,
          height: 1.25,
          fontWeight: FontWeight.w800,
        ),
        titleMedium: TextStyle(
          color: darkNavy,
          fontSize: 16,
          height: 1.3,
          fontWeight: FontWeight.w800,
        ),
        titleSmall: TextStyle(
          color: darkNavy,
          fontSize: 14,
          height: 1.3,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: TextStyle(
          color: normalText,
          fontSize: 15,
          height: 1.45,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: TextStyle(
          color: normalText,
          fontSize: 13.5,
          height: 1.4,
          fontWeight: FontWeight.w500,
        ),
        bodySmall: TextStyle(
          color: mutedText,
          fontSize: 11.5,
          height: 1.35,
          fontWeight: FontWeight.w600,
        ),
        labelLarge: TextStyle(
          color: darkNavy,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
        labelMedium: TextStyle(
          color: normalText,
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
        ),
        labelSmall: TextStyle(
          color: mutedText,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),

      listTileTheme: const ListTileThemeData(
        textColor: normalText,
        iconColor: primaryBlue,
        titleTextStyle: TextStyle(
          color: darkNavy,
          fontSize: 14,
          height: 1.25,
          fontWeight: FontWeight.w800,
        ),
        subtitleTextStyle: TextStyle(
          color: mutedText,
          fontSize: 11,
          height: 1.35,
          fontWeight: FontWeight.w600,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: primaryBlue, width: 1.6),
        ),
        labelStyle: const TextStyle(
          color: normalText,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: const TextStyle(
          color: Color(0xFF66758A),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),

      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: borderColor),
        ),
      ),

      dividerTheme: const DividerThemeData(color: borderColor, thickness: 1),
    );
  }
}
