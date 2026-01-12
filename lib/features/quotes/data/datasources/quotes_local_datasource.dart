import '../../../../core/storage/storage_service.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/errors/failures.dart';
import '../models/quote_model.dart';

abstract class QuotesLocalDataSource {
  Future<void> saveFavoriteQuote(QuoteModel quote);
  Future<List<QuoteModel>> getFavoriteQuotes();
  Future<void> removeFavoriteQuote(QuoteModel quote);
}

class QuotesLocalDataSourceImpl implements QuotesLocalDataSource {
  final StorageService storageService;

  QuotesLocalDataSourceImpl(this.storageService);

  @override
  Future<void> saveFavoriteQuote(QuoteModel quote) async {
    try {
      final favorites = await getFavoriteQuotes();
      final quoteString = quote.toString();

      // Check if quote already exists
      final exists = favorites.any((q) => q.toString() == quoteString);
      if (!exists) {
        favorites.add(quote);
        final quotesList = favorites.map((q) => q.toString()).toList();
        await storageService.saveStringList(
          AppConstants.favoritesKey,
          quotesList,
        );
      }
    } catch (e) {
      throw CacheFailure('Failed to save favorite quote: ${e.toString()}');
    }
  }

  @override
  Future<List<QuoteModel>> getFavoriteQuotes() async {
    try {
      final quotesList = await storageService.getStringList(
        AppConstants.favoritesKey,
      );
      return quotesList.map((q) => QuoteModel.fromString(q)).toList();
    } catch (e) {
      throw CacheFailure('Failed to get favorite quotes: ${e.toString()}');
    }
  }

  @override
  Future<void> removeFavoriteQuote(QuoteModel quote) async {
    try {
      final favorites = await getFavoriteQuotes();
      favorites.removeWhere((q) => q.toString() == quote.toString());
      final quotesList = favorites.map((q) => q.toString()).toList();
      await storageService.saveStringList(
        AppConstants.favoritesKey,
        quotesList,
      );
    } catch (e) {
      throw CacheFailure('Failed to remove favorite quote: ${e.toString()}');
    }
  }
}
