import '../entities/quote.dart';

abstract class QuotesRepository {
  Future<Quote> getRandomQuote();
  Future<void> saveFavoriteQuote(Quote quote);
  Future<List<Quote>> getFavoriteQuotes();
  Future<void> removeFavoriteQuote(Quote quote);
}

