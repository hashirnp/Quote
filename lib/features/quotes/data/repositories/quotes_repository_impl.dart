import '../../../../core/errors/failures.dart';
import '../../domain/entities/quote.dart';
import '../../domain/repositories/quotes_repository.dart';
import '../datasources/quotes_remote_datasource.dart';
import '../datasources/quotes_local_datasource.dart';
import '../models/quote_model.dart';

class QuotesRepositoryImpl implements QuotesRepository {
  final QuotesRemoteDataSource remoteDataSource;
  final QuotesLocalDataSource localDataSource;

  QuotesRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Quote> getRandomQuote() async {
    try {
      final quoteModel = await remoteDataSource.getRandomQuote();
      return quoteModel;
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> saveFavoriteQuote(Quote quote) async {
    try {
      final quoteModel = QuoteModel(text: quote.text, author: quote.author);
      await localDataSource.saveFavoriteQuote(quoteModel);
    } on Failure {
      rethrow;
    } catch (e) {
      throw CacheFailure(e.toString());
    }
  }

  @override
  Future<List<Quote>> getFavoriteQuotes() async {
    try {
      final quotes = await localDataSource.getFavoriteQuotes();
      return quotes;
    } on Failure {
      rethrow;
    } catch (e) {
      throw CacheFailure(e.toString());
    }
  }

  @override
  Future<void> removeFavoriteQuote(Quote quote) async {
    try {
      final quoteModel = QuoteModel(text: quote.text, author: quote.author);
      await localDataSource.removeFavoriteQuote(quoteModel);
    } on Failure {
      rethrow;
    } catch (e) {
      throw CacheFailure(e.toString());
    }
  }
}

