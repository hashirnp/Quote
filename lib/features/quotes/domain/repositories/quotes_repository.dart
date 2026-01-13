import '../entities/quote.dart';
import '../entities/category.dart';
import '../entities/collection.dart';

abstract class QuotesRepository {
  Future<Quote> getRandomQuote();
  Future<Quote> getDailyQuote(int dayOfYear);
  Future<void> saveFavoriteQuote(Quote quote);
  Future<List<Quote>> getFavoriteQuotes();
  Future<void> removeFavoriteQuote(Quote quote);

  // New methods for browsing
  Future<List<Quote>> getQuotes({
    int page = 1,
    int limit = 20,
    String? categoryId,
    String? searchQuery,
    String? author,
  });

  Future<List<Category>> getCategories();
  Future<List<Quote>> searchQuotes({
    required String query,
    String? categoryId,
    String? author,
  });

  Future<List<String>> getAuthors({String? searchQuery});

  // Collections methods
  Future<List<Collection>> getCollections();
  Future<Collection> createCollection({
    required String name,
    String? description,
    String? color,
    String? icon,
  });
  Future<void> updateCollection(Collection collection);
  Future<void> deleteCollection(String collectionId);
  Future<List<Quote>> getCollectionQuotes(String collectionId);
  Future<void> addQuoteToCollection(String collectionId, Quote quote);
  Future<void> removeQuoteFromCollection(String collectionId, Quote quote);
  Future<bool> isQuoteInCollection(String collectionId, Quote quote);

  // Likes methods
  Future<void> likeQuote(Quote quote);
  Future<void> unlikeQuote(Quote quote);
  Future<bool> isQuoteLiked(Quote quote);
  Future<int> getQuoteLikeCount(Quote quote);
  Future<List<String>> getLikedQuoteIds();
}
