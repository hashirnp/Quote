import '../entities/quote.dart';
import '../repositories/quotes_repository.dart';

class RemoveFavoriteQuote {
  final QuotesRepository repository;

  RemoveFavoriteQuote(this.repository);

  Future<void> call(Quote quote) async {
    return await repository.removeFavoriteQuote(quote);
  }
}

