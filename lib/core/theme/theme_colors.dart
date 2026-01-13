import 'package:flutter/material.dart';

enum ThemeModeOption {
  dark,
  light,
  system,
}

enum AccentColor {
  blue,
  purple,
  green,
  orange,
}

class ThemeColors {
  // Accent Colors
  static const Color blue = Color(0xFF4A90E2);
  static const Color purple = Color(0xFF9B59B6);
  static const Color green = Color(0xFF2ECC71);
  static const Color orange = Color(0xFFE67E22);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xff10192b);
  static const Color darkCardBackground = Color(0xff141b26);
  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Color(0xFFB0B0B0);

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color lightCardBackground = Colors.white;
  static const Color lightTextPrimary = Color(0xFF1A1A1A);
  static const Color lightTextSecondary = Color(0xFF666666);

  static Color getAccentColor(AccentColor accent) {
    switch (accent) {
      case AccentColor.blue:
        return blue;
      case AccentColor.purple:
        return purple;
      case AccentColor.green:
        return green;
      case AccentColor.orange:
        return orange;
    }
  }

  static String getAccentColorName(AccentColor accent) {
    switch (accent) {
      case AccentColor.blue:
        return 'Blue';
      case AccentColor.purple:
        return 'Purple';
      case AccentColor.green:
        return 'Green';
      case AccentColor.orange:
        return 'Orange';
    }
  }
}

