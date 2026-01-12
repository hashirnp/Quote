import '../entities/quote.dart';
import '../repositories/quotes_repository.dart';

class SaveFavoriteQuote {
  final QuotesRepository repository;

  SaveFavoriteQuote(this.repository);

  Future<void> call(Quote quote) async {
    return await repository.saveFavoriteQuote(quote);
  }
}

