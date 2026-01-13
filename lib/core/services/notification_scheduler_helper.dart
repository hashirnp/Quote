import 'package:quote/features/quotes/domain/repositories/quotes_repository.dart';

/// Data class for passing quote data to isolate
class QuoteScheduleData {
  final int dayOfYear;
  final int dayOffset;
  final DateTime targetDate;
  final int hour;
  final int minute;

  QuoteScheduleData({
    required this.dayOfYear,
    required this.dayOffset,
    required this.targetDate,
    required this.hour,
    required this.minute,
  });

  Map<String, dynamic> toJson() => {
        'dayOfYear': dayOfYear,
        'dayOffset': dayOffset,
        'targetDate': {
          'year': targetDate.year,
          'month': targetDate.month,
          'day': targetDate.day,
        },
        'hour': hour,
        'minute': minute,
      };

  static QuoteScheduleData fromJson(Map<String, dynamic> json) {
    final date = json['targetDate'] as Map<String, dynamic>;
    return QuoteScheduleData(
      dayOfYear: json['dayOfYear'] as int,
      dayOffset: json['dayOffset'] as int,
      targetDate: DateTime(
        date['year'] as int,
        date['month'] as int,
        date['day'] as int,
      ),
      hour: json['hour'] as int,
      minute: json['minute'] as int,
    );
  }
}

/// Result class for quote fetch result
class QuoteFetchResult {
  final int dayOffset;
  final String? quoteText;
  final String? author;
  final bool success;

  QuoteFetchResult({
    required this.dayOffset,
    this.quoteText,
    this.author,
    required this.success,
  });
}

/// Helper function to fetch quotes in isolate
/// This function runs in a separate isolate to avoid blocking the UI
Future<List<QuoteFetchResult>> fetchQuotesForNotifications(
  List<QuoteScheduleData> scheduleData,
  QuotesRepository repository,
) async {
  final results = <QuoteFetchResult>[];

  for (final data in scheduleData) {
    try {
      final quote = await repository.getDailyQuote(data.dayOfYear);
      results.add(QuoteFetchResult(
        dayOffset: data.dayOffset,
        quoteText: quote.text,
        author: quote.author,
        success: true,
      ));
    } catch (e) {
      // If fetching fails, use fallback
      results.add(QuoteFetchResult(
        dayOffset: data.dayOffset,
        quoteText: 'Your daily inspiration awaits',
        author: 'Quote App',
        success: false,
      ));
    }
  }

  return results;
}
