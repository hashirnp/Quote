import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xff0135aed);
  static const Color darkBackground = Color(0xff10192b);
  static const Color cardBackground = Color(0xff141b26);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0B0B0);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      primaryColor: primaryBlue,
      colorScheme: const ColorScheme.dark(
        primary: primaryBlue,
        surface: cardBackground,
        onSurface: textPrimary,
        onPrimary: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.poppins(
            color: textPrimary, fontSize: 24, fontWeight: FontWeight.bold),
        bodyLarge: GoogleFonts.poppins(color: textPrimary, fontSize: 18),
        bodyMedium: GoogleFonts.poppins(color: textSecondary, fontSize: 16),
        bodySmall: GoogleFonts.poppins(color: textSecondary, fontSize: 14),
      ),
    );
  }
}
