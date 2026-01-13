import '../../../../core/theme/theme_colors.dart';

abstract class SettingsRepository {
  Future<void> syncSettings({
    required ThemeModeOption themeMode,
    required AccentColor accentColor,
    required double fontSize,
  });

  Future<Map<String, dynamic>?> getSettingsFromProfile();
}

