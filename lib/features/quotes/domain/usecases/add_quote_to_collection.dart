import '../entities/quote.dart';
import '../repositories/quotes_repository.dart';

class AddQuoteToCollection {
  final QuotesRepository repository;

  AddQuoteToCollection(this.repository);

  Future<void> call(String collectionId, Quote quote) async {
    return await repository.addQuoteToCollection(collectionId, quote);
  }
}

