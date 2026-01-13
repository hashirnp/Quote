import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/quotes/domain/repositories/quotes_repository.dart';
import '../utils/constants.dart';

class WidgetService {
  final QuotesRepository quotesRepository;
  final SharedPreferences sharedPreferences;

  WidgetService({
    required this.quotesRepository,
    required this.sharedPreferences,
  });

  /// Initialize the widget service
  Future<void> initialize() async {
    try {
      // Set app group ID for iOS (required for widget data sharing)
      await HomeWidget.setAppGroupId('group.com.quote.app');
    } catch (e) {
      // App group might not be set up yet (iOS), continue anyway
      // Android doesn't need app groups
      debugPrint('Widget service initialization: $e');
    }
  }

  /// Calculate day of year (1-365)
  int _getDayOfYear() {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    return now.difference(startOfYear).inDays + 1;
  }

  /// Update widget with daily quote
  Future<void> updateDailyQuote() async {
    try {
      final dayOfYear = _getDayOfYear();
      final quote = await quotesRepository.getDailyQuote(dayOfYear);

      debugPrint(
          'Updating widget with quote: ${quote.text.substring(0, quote.text.length > 50 ? 50 : quote.text.length)}... by ${quote.author}');

      // Save quote data to widget (home_widget uses SharedPreferences)
      await HomeWidget.saveWidgetData<String>('quote_text', quote.text);
      await HomeWidget.saveWidgetData<String>('quote_author', quote.author);
      await HomeWidget.saveWidgetData<String>('quote_id', quote.id);
      await HomeWidget.saveWidgetData<String>(
        'last_updated',
        DateTime.now().toIso8601String(),
      );
      await HomeWidget.saveWidgetData<int>('day_of_year', dayOfYear);

      // Also save directly to SharedPreferences as backup (for Android widget)
      // Flutter SharedPreferences stores keys with "flutter." prefix automatically
      // So 'widget_quote_text' becomes 'flutter.widget_quote_text' in FlutterSharedPreferences
      await sharedPreferences.setString('widget_quote_text', quote.text);
      await sharedPreferences.setString('widget_quote_author', quote.author);

      // Force commit to ensure data is written immediately
      await sharedPreferences.reload();

      debugPrint(
          'Saved to SharedPreferences: quote_text=${quote.text.substring(0, quote.text.length > 30 ? 30 : quote.text.length)}...');
      debugPrint('Saved to SharedPreferences: quote_author=${quote.author}');

      // Update widget UI - this triggers the widget to refresh
      try {
        await HomeWidget.updateWidget(
          name: 'DailyQuoteWidget',
          androidName: 'DailyQuoteWidgetProvider',
          iOSName: 'DailyQuoteWidget',
        );
        debugPrint('Widget update triggered via HomeWidget');
      } catch (e) {
        debugPrint('Error calling HomeWidget.updateWidget: $e');
        // Widget update will happen automatically on next refresh cycle
      }

      // Save last update date
      await sharedPreferences.setString(
        AppConstants.lastDailyQuoteDateKey,
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      debugPrint('Error updating widget: $e');
    }
  }

  /// Check if widget needs update (daily)
  Future<bool> needsUpdate() async {
    try {
      final lastUpdateString = sharedPreferences.getString(
        AppConstants.lastDailyQuoteDateKey,
      );

      if (lastUpdateString == null) {
        return true;
      }

      final lastUpdate = DateTime.parse(lastUpdateString);
      final now = DateTime.now();

      // Update if it's a new day
      return now.year != lastUpdate.year ||
          now.month != lastUpdate.month ||
          now.day != lastUpdate.day;
    } catch (e) {
      return true;
    }
  }

  /// Update widget if needed
  Future<void> updateIfNeeded() async {
    if (await needsUpdate()) {
      await updateDailyQuote();
    }
  }
}
