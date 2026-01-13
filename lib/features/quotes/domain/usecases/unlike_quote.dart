import '../entities/quote.dart';
import '../repositories/quotes_repository.dart';

class UnlikeQuote {
  final QuotesRepository repository;

  UnlikeQuote(this.repository);

  Future<void> call(Quote quote) async {
    return await repository.unlikeQuote(quote);
  }
}
