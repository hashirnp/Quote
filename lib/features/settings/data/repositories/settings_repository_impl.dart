import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SupabaseClient supabaseClient;

  SettingsRepositoryImpl({required this.supabaseClient});

  @override
  Future<void> syncSettings({
    required ThemeModeOption themeMode,
    required AccentColor accentColor,
    required double fontSize,
  }) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw const ServerFailure('User not authenticated');
      }

      await supabaseClient.from('user_settings').upsert({
        'user_id': user.id,
        'theme_mode': themeMode.toString(),
        'accent_color': accentColor.toString(),
        'font_size': fontSize,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      if (e is Failure) {
        rethrow;
      }
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>?> getSettingsFromProfile() async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        return null;
      }

      final response = await supabaseClient
          .from('user_settings')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      return response;
    } catch (e) {
      return null;
    }
  }
}

