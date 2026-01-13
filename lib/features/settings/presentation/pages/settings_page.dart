import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/constants.dart';
import '../bloc/settings_bloc.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    context.read<SettingsBloc>().add(const LoadSettingsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsBloc, SettingsState>(
      listener: (context, state) {
        if (state is SettingsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${AppStrings.errorSyncingSettings}: ${state.message}',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
        if (state is SettingsLoading) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              title: Text(
                AppStrings.settings,
                style: GoogleFonts.poppins(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is SettingsError) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              title: Text(
                AppStrings.settings,
                style: GoogleFonts.poppins(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            body: Center(
              child: Text(
                'Error: ${state.message}',
                style: GoogleFonts.poppins(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),
          );
        }

        if (state is SettingsLoaded) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              title: Text(
                AppStrings.settings,
                style: GoogleFonts.poppins(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              actions: [
                if (state.isSyncing)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.cloud_upload),
                    onPressed: () {
                      context.read<SettingsBloc>().add(const SyncSettingsEvent());
                    },
                    tooltip: AppStrings.syncToProfile,
                  ),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildThemeModeSection(state),
                const SizedBox(height: 24),
                _buildAccentColorSection(state),
                const SizedBox(height: 24),
                _buildFontSizeSection(state),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildThemeModeSection(SettingsLoaded state) {
    return _buildSection(
      title: AppStrings.appearance,
      children: [
        ListTile(
          leading: Icon(
            state.themeMode == ThemeModeOption.dark
                ? Icons.dark_mode
                : state.themeMode == ThemeModeOption.light
                    ? Icons.light_mode
                    : Icons.brightness_auto,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text(
            AppStrings.themeMode,
            style: GoogleFonts.poppins(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            _getThemeModeName(state.themeMode),
            style: GoogleFonts.poppins(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontSize: 14,
            ),
          ),
          trailing: DropdownButton<ThemeModeOption>(
            value: state.themeMode,
            underline: const SizedBox(),
            items: ThemeModeOption.values.map((mode) {
              return DropdownMenuItem(
                value: mode,
                child: Text(_getThemeModeName(mode)),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                context.read<SettingsBloc>().add(UpdateThemeModeEvent(value));
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAccentColorSection(SettingsLoaded state) {
    return _buildSection(
      title: AppStrings.accentColor,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            children: AccentColor.values.map((color) {
              final isSelected = state.accentColor == color;
              final accentColorValue = ThemeColors.getAccentColor(color);
              return GestureDetector(
                onTap: () {
                  context.read<SettingsBloc>().add(UpdateAccentColorEvent(color));
                },
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: accentColorValue,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 30,
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            ThemeColors.getAccentColorName(state.accentColor),
            style: GoogleFonts.poppins(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildFontSizeSection(SettingsLoaded state) {
    return _buildSection(
      title: AppStrings.fontSize,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Small',
                    style: GoogleFonts.poppins(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '${state.fontSize.toInt()}',
                    style: GoogleFonts.poppins(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Large',
                    style: GoogleFonts.poppins(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              Slider(
                value: state.fontSize,
                min: AppConstants.minFontSize,
                max: AppConstants.maxFontSize,
                divisions: 12,
                label: '${state.fontSize.toInt()}',
                onChanged: (value) {
                  context.read<SettingsBloc>().add(UpdateFontSizeEvent(value));
                },
              ),
              const SizedBox(height: 16),
              // Preview
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Preview: "The only way to do great work is to love what you do."',
                  style: GoogleFonts.poppins(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: state.fontSize,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  String _getThemeModeName(ThemeModeOption mode) {
    switch (mode) {
      case ThemeModeOption.dark:
        return 'Dark';
      case ThemeModeOption.light:
        return 'Light';
      case ThemeModeOption.system:
        return 'System';
    }
  }
}

