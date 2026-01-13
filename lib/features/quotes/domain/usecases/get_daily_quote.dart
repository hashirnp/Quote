import '../entities/quote.dart';
import '../repositories/quotes_repository.dart';

class GetDailyQuote {
  final QuotesRepository repository;

  GetDailyQuote(this.repository);

  Future<Quote> call() async {
    // Calculate day of year (1-365)
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final dayOfYear = now.difference(startOfYear).inDays + 1;
    
    return await repository.getDailyQuote(dayOfYear);
  }
}

