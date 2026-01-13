import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../../core/utils/constants.dart';
import '../../domain/repositories/settings_repository.dart';

// Events
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettingsEvent extends SettingsEvent {
  const LoadSettingsEvent();
}

class UpdateThemeModeEvent extends SettingsEvent {
  final ThemeModeOption themeMode;
  const UpdateThemeModeEvent(this.themeMode);
}

class UpdateAccentColorEvent extends SettingsEvent {
  final AccentColor accentColor;
  const UpdateAccentColorEvent(this.accentColor);
}

class UpdateFontSizeEvent extends SettingsEvent {
  final double fontSize;
  const UpdateFontSizeEvent(this.fontSize);
}

class SyncSettingsEvent extends SettingsEvent {
  const SyncSettingsEvent();
}

// States
abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final ThemeModeOption themeMode;
  final AccentColor accentColor;
  final double fontSize;
  final bool isSyncing;

  const SettingsLoaded({
    required this.themeMode,
    required this.accentColor,
    required this.fontSize,
    this.isSyncing = false,
  });

  SettingsLoaded copyWith({
    ThemeModeOption? themeMode,
    AccentColor? accentColor,
    double? fontSize,
    bool? isSyncing,
  }) {
    return SettingsLoaded(
      themeMode: themeMode ?? this.themeMode,
      accentColor: accentColor ?? this.accentColor,
      fontSize: fontSize ?? this.fontSize,
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }

  @override
  List<Object?> get props => [themeMode, accentColor, fontSize, isSyncing];
}

class SettingsError extends SettingsState {
  final String message;
  const SettingsError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository repository;
  final StorageService storageService;

  SettingsBloc({
    required this.repository,
    required this.storageService,
  }) : super(SettingsLoading()) {
    on<LoadSettingsEvent>(_onLoadSettings);
    on<UpdateThemeModeEvent>(_onUpdateThemeMode);
    on<UpdateAccentColorEvent>(_onUpdateAccentColor);
    on<UpdateFontSizeEvent>(_onUpdateFontSize);
    on<SyncSettingsEvent>(_onSyncSettings);
  }

  Future<void> _onLoadSettings(
    LoadSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      // Load from local storage
      final themeModeString = await storageService.getString(
        AppConstants.themeModeKey,
      );
      final accentColorString = await storageService.getString(
        AppConstants.accentColorKey,
      );
      final fontSizeString = await storageService.getString(
        AppConstants.fontSizeKey,
      );

      final themeMode = themeModeString != null
          ? ThemeModeOption.values.firstWhere(
              (e) => e.toString() == themeModeString,
              orElse: () => ThemeModeOption.dark,
            )
          : ThemeModeOption.dark;

      final accentColor = accentColorString != null
          ? AccentColor.values.firstWhere(
              (e) => e.toString() == accentColorString,
              orElse: () => AccentColor.blue,
            )
          : AccentColor.blue;

      final fontSize = fontSizeString != null
          ? double.parse(fontSizeString)
          : 16.0; // Default font size

      emit(SettingsLoaded(
        themeMode: themeMode,
        accentColor: accentColor,
        fontSize: fontSize,
      ));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onUpdateThemeMode(
    UpdateThemeModeEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await storageService.saveString(
        AppConstants.themeModeKey,
        event.themeMode.toString(),
      );

      if (state is SettingsLoaded) {
        final currentState = state as SettingsLoaded;
        emit(currentState.copyWith(themeMode: event.themeMode));
      }
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onUpdateAccentColor(
    UpdateAccentColorEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await storageService.saveString(
        AppConstants.accentColorKey,
        event.accentColor.toString(),
      );

      if (state is SettingsLoaded) {
        final currentState = state as SettingsLoaded;
        emit(currentState.copyWith(accentColor: event.accentColor));
      }
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onUpdateFontSize(
    UpdateFontSizeEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await storageService.saveString(
        AppConstants.fontSizeKey,
        event.fontSize.toString(),
      );

      if (state is SettingsLoaded) {
        final currentState = state as SettingsLoaded;
        emit(currentState.copyWith(fontSize: event.fontSize));
      }
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onSyncSettings(
    SyncSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      if (state is SettingsLoaded) {
        final currentState = state as SettingsLoaded;
        emit(currentState.copyWith(isSyncing: true));

        await repository.syncSettings(
          themeMode: currentState.themeMode,
          accentColor: currentState.accentColor,
          fontSize: currentState.fontSize,
        );

        emit(currentState.copyWith(isSyncing: false));
      }
    } catch (e) {
      if (state is SettingsLoaded) {
        final currentState = state as SettingsLoaded;
        emit(currentState.copyWith(isSyncing: false));
      }
      emit(SettingsError(e.toString()));
    }
  }
}

