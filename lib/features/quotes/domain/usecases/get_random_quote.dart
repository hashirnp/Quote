import '../entities/quote.dart';
import '../repositories/quotes_repository.dart';

class GetRandomQuote {
  final QuotesRepository repository;

  GetRandomQuote(this.repository);

  Future<Quote> call() async {
    return await repository.getRandomQuote();
  }
}

