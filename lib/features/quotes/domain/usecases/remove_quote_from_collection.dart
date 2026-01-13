import '../entities/quote.dart';
import '../repositories/quotes_repository.dart';

class RemoveQuoteFromCollection {
  final QuotesRepository repository;

  RemoveQuoteFromCollection(this.repository);

  Future<void> call(String collectionId, Quote quote) async {
    return await repository.removeQuoteFromCollection(collectionId, quote);
  }
}

