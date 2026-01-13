import '../entities/quote.dart';
import '../repositories/quotes_repository.dart';

class LikeQuote {
  final QuotesRepository repository;

  LikeQuote(this.repository);

  Future<void> call(Quote quote) async {
    return await repository.likeQuote(quote);
  }
}
