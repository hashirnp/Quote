import '../entities/quote.dart';
import '../repositories/quotes_repository.dart';

class SearchQuotes {
  final QuotesRepository repository;

  SearchQuotes(this.repository);

  Future<List<Quote>> call({
    required String query,
    String? categoryId,
    String? author,
  }) async {
    return await repository.searchQuotes(
      query: query,
      categoryId: categoryId,
      author: author,
    );
  }
}

