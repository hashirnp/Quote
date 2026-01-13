import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quote/features/quotes/presentation/pages/main_page.dart';

import 'core/di/injection_container.dart';
import 'core/navigation/auth_guard.dart';
import 'core/services/notification_service.dart';
import 'core/services/widget_service.dart';
import 'core/theme/theme_service.dart';
import 'core/theme/theme_colors.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/quotes/domain/repositories/quotes_repository.dart';
import 'features/quotes/presentation/bloc/browse_quotes_bloc.dart';
import 'features/quotes/presentation/bloc/collections_bloc.dart';
import 'features/quotes/presentation/bloc/quotes_bloc.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';

// Global navigator key for navigation from notification service
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencyInjection();

  // Initialize notifications
  final notificationService = getIt<NotificationService>();
  await notificationService.initialize();

  // Set quotes repository for notification service
  final quotesRepository = getIt<QuotesRepository>();
  notificationService.setQuotesRepository(quotesRepository);

  // Initialize widget service
  final widgetService = getIt<WidgetService>();
  await widgetService.initialize();

  // Update widget immediately on app start (don't wait for needsUpdate check)
  // This ensures widget has data even on first launch
  widgetService.updateDailyQuote().catchError((error) {
    debugPrint('Error updating widget on startup: $error');
  });

  // Schedule daily notifications if enabled (in background to avoid blocking)
  final isEnabled = await notificationService.isNotificationEnabled();
  if (isEnabled) {
    final time = await notificationService.getNotificationTime() ??
        const TimeOfDay(hour: 8, minute: 0);
    // Schedule notifications for next 5 days with actual daily quotes
    // Don't await - let it run in background
    notificationService
        .scheduleDailyQuoteNotification(
      notificationTime: time,
    )
        .catchError((error) {
      // Silently handle errors during scheduling
      debugPrint('Error scheduling notifications: $error');
    });
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => getIt<AuthBloc>()..add(CheckAuthStatusEvent()),
        ),
        BlocProvider<QuotesBloc>(
          create: (_) => getIt<QuotesBloc>(),
        ),
        BlocProvider<BrowseQuotesBloc>(
          create: (_) => getIt<BrowseQuotesBloc>(),
        ),
        BlocProvider<CollectionsBloc>(
          create: (_) => getIt<CollectionsBloc>(),
        ),
        BlocProvider<SettingsBloc>(
          create: (_) => getIt<SettingsBloc>()..add(const LoadSettingsEvent()),
        ),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settingsState) {
          // Get theme settings
          final accentColor = settingsState is SettingsLoaded
              ? settingsState.accentColor
              : AccentColor.blue;

          final themeMode = settingsState is SettingsLoaded
              ? (settingsState.themeMode == ThemeModeOption.dark
                  ? ThemeMode.dark
                  : settingsState.themeMode == ThemeModeOption.light
                      ? ThemeMode.light
                      : ThemeMode.system)
              : ThemeMode.dark;

          return MaterialApp(
            navigatorKey: navigatorKey,
            title: 'Quote App',
            debugShowCheckedModeBanner: false,
            theme: ThemeService.getTheme(
              isDarkMode: false,
              accentColor: accentColor,
            ),
            darkTheme: ThemeService.getTheme(
              isDarkMode: true,
              accentColor: accentColor,
            ),
            themeMode: themeMode,
            home: const AuthGuard(),
            // Handle deep links from widget
            onGenerateRoute: (settings) {
              if (settings.name == '/daily' ||
                  settings.name?.startsWith('quoteapp://daily') == true) {
                // Navigate to browse page (index 0) which shows daily quote
                return MaterialPageRoute(
                  builder: (_) => const MainPage(),
                );
              }
              return null;
            },
          );
        },
      ),
    );
  }
}
