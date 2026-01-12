import '../entities/quote.dart';
import '../repositories/quotes_repository.dart';

class GetFavoriteQuotes {
  final QuotesRepository repository;

  GetFavoriteQuotes(this.repository);

  Future<List<Quote>> call() async {
    return await repository.getFavoriteQuotes();
  }
}

