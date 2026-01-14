import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme_colors.dart';

class ThemeService {
  static ThemeData getTheme({
    required bool isDarkMode,
    required AccentColor accentColor,
  }) {
    final accent = ThemeColors.getAccentColor(accentColor);

    if (isDarkMode) {
      return _buildDarkTheme(accent);
    } else {
      return _buildLightTheme(accent);
    }
  }

  static ThemeData _buildDarkTheme(Color accent) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: ThemeColors.darkBackground,
      primaryColor: accent,
      colorScheme: ColorScheme.dark(
        primary: accent,
        surface: ThemeColors.darkCardBackground,
        onSurface: ThemeColors.darkTextPrimary,
        onPrimary: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: ThemeColors.darkBackground,
        elevation: 0,
        iconTheme: IconThemeData(color: ThemeColors.darkTextPrimary),
        titleTextStyle: TextStyle(
          color: ThemeColors.darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: ThemeColors.darkCardBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.poppins(
          color: ThemeColors.darkTextPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: GoogleFonts.poppins(
          color: ThemeColors.darkTextPrimary,
          fontSize: 18,
        ),
        bodyMedium: GoogleFonts.poppins(
          color: ThemeColors.darkTextSecondary,
          fontSize: 16,
        ),
        bodySmall: GoogleFonts.poppins(
          color: ThemeColors.darkTextSecondary,
          fontSize: 14,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(accent),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return accent.withValues(alpha: 0.5);
          }
          return Colors.grey.withValues(alpha: 0.3);
        }),
      ),
    );
  }

  static ThemeData _buildLightTheme(Color accent) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: ThemeColors.lightBackground,
      primaryColor: accent,
      colorScheme: ColorScheme.light(
        primary: accent,
        surface: ThemeColors.lightCardBackground,
        onSurface: ThemeColors.lightTextPrimary,
        onPrimary: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: ThemeColors.lightBackground,
        elevation: 0,
        iconTheme: IconThemeData(color: ThemeColors.lightTextPrimary),
        titleTextStyle: TextStyle(
          color: ThemeColors.lightTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: ThemeColors.lightCardBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.poppins(
          color: ThemeColors.lightTextPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: GoogleFonts.poppins(
          color: ThemeColors.lightTextPrimary,
          fontSize: 18,
        ),
        bodyMedium: GoogleFonts.poppins(
          color: ThemeColors.lightTextSecondary,
          fontSize: 16,
        ),
        bodySmall: GoogleFonts.poppins(
          color: ThemeColors.lightTextSecondary,
          fontSize: 14,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(accent),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return accent.withValues(alpha: 0.5);
          }
          return Colors.grey.withValues(alpha: 0.3);
        }),
      ),
    );
  }
}
