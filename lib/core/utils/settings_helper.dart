import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/settings/presentation/bloc/settings_bloc.dart';
import '../utils/constants.dart';

class SettingsHelper {
  /// Get current font size from settings, or return default
  static double getFontSize(BuildContext context) {
    final settingsState = context.read<SettingsBloc>().state;
    if (settingsState is SettingsLoaded) {
      return settingsState.fontSize;
    }
    return AppConstants.defaultFontSize;
  }

  /// Get current font size from settings bloc state
  static double getFontSizeFromState(SettingsState state) {
    if (state is SettingsLoaded) {
      return state.fontSize;
    }
    return AppConstants.defaultFontSize;
  }
}
