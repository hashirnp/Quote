import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../features/quotes/domain/repositories/quotes_repository.dart';
import '../../features/quotes/presentation/pages/main_page.dart';
import '../../main.dart';
import '../di/injection_container.dart';
import '../storage/storage_service.dart';
import '../utils/constants.dart';
import 'notification_scheduler_helper.dart';
import 'widget_service.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final StorageService _storageService;
  QuotesRepository? _quotesRepository;

  NotificationService({required StorageService storageService})
      : _storageService = storageService;

  void setQuotesRepository(QuotesRepository repository) {
    _quotesRepository = repository;
  }

  Future<void> initialize() async {
    // Initialize timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(
        tz.getLocation('Asia/Kolkata')); // Indian Standard Time (IST)

    // Android initialization settings
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Initialization settings
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions for iOS
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Navigate to browse page (index 0) when notification is tapped
    try {
      final context = navigatorKey.currentContext;
      if (context != null) {
        // Use a post-frame callback to ensure navigation happens after build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _navigateToBrowsePage(context);
        });
      }
    } catch (e) {
      debugPrint('Error handling notification tap: $e');
    }
  }

  void _navigateToBrowsePage(BuildContext context) {
    try {
      // Find MainPageState in widget tree and set index to 0 (BrowsePage)
      final mainPageState = context.findAncestorStateOfType<MainPageState>();
      if (mainPageState != null) {
        mainPageState.setCurrentIndex(0);
      } else {
        // If MainPage is not in tree, it will be shown by AuthGuard
        // The index will default to 0 (BrowsePage) which is what we want
        debugPrint(
            'MainPage not found in widget tree, will default to index 0');
      }
    } catch (e) {
      debugPrint('Error navigating to browse page: $e');
    }
  }

  Future<void> scheduleDailyQuoteNotification({
    required TimeOfDay notificationTime,
  }) async {
    // Cancel existing notifications
    await cancelAllNotifications();

    if (_quotesRepository == null) {
      // If repository is not set, schedule with placeholder
      await _schedulePlaceholderNotification(notificationTime);
      return;
    }

    // Get notification time
    final hour = notificationTime.hour;
    final minute = notificationTime.minute;

    // Schedule notifications for the next 5 days
    // This ensures notifications work even if app is closed for several days
    final now = tz.TZDateTime.now(tz.local);
    final today = DateTime(now.year, now.month, now.day);

    // Prepare schedule data for all days
    final scheduleDataList = <QuoteScheduleData>[];

    for (int dayOffset = 0; dayOffset < 5; dayOffset++) {
      final targetDate = today.add(Duration(days: dayOffset));
      final scheduledDate = tz.TZDateTime(
        tz.local,
        targetDate.year,
        targetDate.month,
        targetDate.day,
        hour,
        minute,
      );

      // Skip if time has already passed today
      if (dayOffset == 0 && scheduledDate.isBefore(now)) {
        continue;
      }

      // Calculate day of year for this date
      final startOfYear = DateTime(targetDate.year, 1, 1);
      final dayOfYear = targetDate.difference(startOfYear).inDays + 1;

      scheduleDataList.add(QuoteScheduleData(
        dayOfYear: dayOfYear,
        dayOffset: dayOffset,
        targetDate: targetDate,
        hour: hour,
        minute: minute,
      ));
    }

    // Fetch quotes in isolate to avoid blocking UI
    // Note: We can't pass repository directly to isolate, so we'll fetch on main thread
    // but in a non-blocking way using unawaited futures
    await _scheduleNotificationsInBackground(scheduleDataList, now);

    // Update widget with today's quote
    try {
      final widgetService = getIt<WidgetService>();
      await widgetService.updateIfNeeded();
    } catch (e) {
      // Widget service might not be available, ignore
      debugPrint('Error updating widget from notification scheduling: $e');
    }

    // Save notification time preference
    await _storageService.saveString(
      AppConstants.notificationTimeKey,
      '$hour:$minute',
    );
  }

  Future<void> _scheduleNotificationsInBackground(
    List<QuoteScheduleData> scheduleDataList,
    tz.TZDateTime now,
  ) async {
    // Use microtask to yield to event loop and keep UI responsive
    // Process in smaller batches with yields between them
    const batchSize = 2; // Small batches for maximum responsiveness

    for (int i = 0; i < scheduleDataList.length; i += batchSize) {
      // Yield to event loop before processing each batch
      await Future.microtask(() {});

      final batch = scheduleDataList.skip(i).take(batchSize).toList();

      // Process batch in parallel
      await Future.wait(
        batch.map((data) => _fetchAndScheduleQuote(data, now)),
      );

      // Small delay to allow UI updates
      if (i + batchSize < scheduleDataList.length) {
        await Future.delayed(const Duration(milliseconds: 20));
      }
    }
  }

  Future<void> _fetchAndScheduleQuote(
    QuoteScheduleData data,
    tz.TZDateTime now,
  ) async {
    final scheduledDate = tz.TZDateTime(
      tz.local,
      data.targetDate.year,
      data.targetDate.month,
      data.targetDate.day,
      data.hour,
      data.minute,
    );

    try {
      // Fetch the daily quote for this specific day
      final quote = await _quotesRepository!.getDailyQuote(data.dayOfYear);

      // Schedule notification with the actual quote
      await _scheduleNotificationForDate(
        scheduledDate,
        quote.text,
        quote.author,
        data.dayOffset,
      );
    } catch (e) {
      // If fetching fails, use a fallback message
      await _scheduleNotificationForDate(
        scheduledDate,
        'Your daily inspiration awaits',
        'Quote App',
        data.dayOffset,
      );
    }
  }

  Future<void> _scheduleNotificationForDate(
    tz.TZDateTime scheduledDate,
    String quoteText,
    String author,
    int notificationId,
  ) async {
    // Android notification details
    const androidDetails = AndroidNotificationDetails(
      'daily_quote_channel',
      'Daily Quote',
      channelDescription: 'Notifications for daily inspirational quotes',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    // iOS notification details
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    // Notification details
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Schedule the notification
    // Use inexactAllowWhileIdle to avoid requiring SCHEDULE_EXACT_ALARM permission
    // For daily notifications, inexact alarms are sufficient and more battery-friendly
    await _notifications.zonedSchedule(
      notificationId, // Unique ID for each day
      'Quote of the Day',
      '$quoteText\n\n— $author',
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> _schedulePlaceholderNotification(
    TimeOfDay notificationTime,
  ) async {
    final hour = notificationTime.hour;
    final minute = notificationTime.minute;

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _scheduleNotificationForDate(
      scheduledDate,
      'Your daily inspiration awaits',
      'Quote App',
      0,
    );
  }

  Future<TimeOfDay?> getNotificationTime() async {
    final timeString = await _storageService.getString(
      AppConstants.notificationTimeKey,
    );

    if (timeString == null) {
      return const TimeOfDay(hour: 8, minute: 0); // Default 8:00 AM
    }

    final parts = timeString.split(':');
    if (parts.length == 2) {
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }

    return const TimeOfDay(hour: 8, minute: 0);
  }

  Future<bool> isNotificationEnabled() async {
    final enabled = await _storageService.getString(
      AppConstants.notificationEnabledKey,
    );
    return enabled != 'false'; // Default to enabled
  }

  Future<void> setNotificationEnabled(bool enabled) async {
    await _storageService.saveString(
      AppConstants.notificationEnabledKey,
      enabled.toString(),
    );

    if (!enabled) {
      await cancelAllNotifications();
    }
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Reschedule notifications to ensure they're current
  /// Call this when app opens to refresh notifications
  Future<void> rescheduleNotificationsIfNeeded() async {
    final isEnabled = await isNotificationEnabled();
    if (!isEnabled || _quotesRepository == null) {
      return;
    }

    final time = await getNotificationTime();
    if (time != null) {
      await scheduleDailyQuoteNotification(notificationTime: time);
    }
  }

  Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'daily_quote_channel',
      'Daily Quote',
      channelDescription: 'Notifications for daily inspirational quotes',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      999, // Unique ID for instant notifications
      title,
      body,
      notificationDetails,
    );
  }
}
