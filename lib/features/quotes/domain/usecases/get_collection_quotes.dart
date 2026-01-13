import '../entities/quote.dart';
import '../repositories/quotes_repository.dart';

class GetCollectionQuotes {
  final QuotesRepository repository;

  GetCollectionQuotes(this.repository);

  Future<List<Quote>> call(String collectionId) async {
    return await repository.getCollectionQuotes(collectionId);
  }
}

