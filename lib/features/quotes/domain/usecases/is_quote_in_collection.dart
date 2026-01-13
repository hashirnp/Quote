import '../entities/quote.dart';
import '../repositories/quotes_repository.dart';

class IsQuoteInCollection {
  final QuotesRepository repository;

  IsQuoteInCollection(this.repository);

  Future<bool> call(String collectionId, Quote quote) async {
    return await repository.isQuoteInCollection(collectionId, quote);
  }
}

