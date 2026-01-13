import '../entities/quote.dart';
import '../repositories/quotes_repository.dart';

class GetQuotes {
  final QuotesRepository repository;

  GetQuotes(this.repository);

  Future<List<Quote>> call({
    int page = 1,
    int limit = 20,
    String? categoryId,
    String? searchQuery,
    String? author,
  }) async {
    return await repository.getQuotes(
      page: page,
      limit: limit,
      categoryId: categoryId,
      searchQuery: searchQuery,
      author: author,
    );
  }
}

