import '../../../../core/errors/failures.dart';
import '../../domain/entities/quote.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/collection.dart';
import '../../domain/repositories/quotes_repository.dart';
import '../datasources/quotes_remote_datasource.dart';
import '../datasources/quotes_local_datasource.dart';
import '../datasources/favorites_remote_datasource.dart';
import '../datasources/collections_remote_datasource.dart';
import '../datasources/likes_remote_datasource.dart';
import '../models/quote_model.dart';

class QuotesRepositoryImpl implements QuotesRepository {
  final QuotesRemoteDataSource remoteDataSource;
  final QuotesLocalDataSource localDataSource;
  final FavoritesRemoteDataSource favoritesRemoteDataSource;
  final CollectionsRemoteDataSource collectionsRemoteDataSource;
  final LikesRemoteDataSource likesRemoteDataSource;

  QuotesRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.favoritesRemoteDataSource,
    required this.collectionsRemoteDataSource,
    required this.likesRemoteDataSource,
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
  Future<Quote> getDailyQuote(int dayOfYear) async {
    try {
      final quoteModel = await remoteDataSource.getDailyQuote(dayOfYear);
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
      // Try to save to Supabase first (cloud sync)
      try {
        await favoritesRemoteDataSource.saveFavoriteQuote(quote);
      } catch (e) {
        // If user is not logged in, fallback to local storage
        if (e is ServerFailure && e.message.contains('not authenticated')) {
          final quoteModel = QuoteModel(
            id: quote.id,
            text: quote.text,
            author: quote.author,
            categoryId: quote.categoryId,
            categoryName: quote.categoryName,
          );
          await localDataSource.saveFavoriteQuote(quoteModel);
        } else {
          rethrow;
        }
      }
    } on Failure {
      rethrow;
    } catch (e) {
      throw const CacheFailure('Failed to save favorite');
    }
  }

  @override
  Future<List<Quote>> getFavoriteQuotes() async {
    try {
      // Try to get from Supabase first (cloud sync)
      try {
        final quotes = await favoritesRemoteDataSource.getFavoriteQuotes();
        return quotes;
      } catch (e) {
        // If user is not logged in, fallback to local storage
        if (e is ServerFailure && e.message.contains('not authenticated')) {
          final quotes = await localDataSource.getFavoriteQuotes();
          return quotes;
        } else {
          rethrow;
        }
      }
    } on Failure {
      rethrow;
    } catch (e) {
      throw const CacheFailure('Failed to load favorites');
    }
  }

  @override
  Future<void> removeFavoriteQuote(Quote quote) async {
    try {
      // Try to remove from Supabase first (cloud sync)
      try {
        await favoritesRemoteDataSource.removeFavoriteQuote(quote);
      } catch (e) {
        // If user is not logged in, fallback to local storage
        if (e is ServerFailure && e.message.contains('not authenticated')) {
          final quoteModel = QuoteModel(
            id: quote.id,
            text: quote.text,
            author: quote.author,
          );
          await localDataSource.removeFavoriteQuote(quoteModel);
        } else {
          rethrow;
        }
      }
    } on Failure {
      rethrow;
    } catch (e) {
      throw const CacheFailure('Failed to remove favorite');
    }
  }

  @override
  Future<List<Quote>> getQuotes({
    int page = 1,
    int limit = 20,
    String? categoryId,
    String? searchQuery,
    String? author,
  }) async {
    try {
      final quotes = await remoteDataSource.getQuotes(
        page: page,
        limit: limit,
        categoryId: categoryId,
        searchQuery: searchQuery,
        author: author,
      );
      return quotes;
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<Category>> getCategories() async {
    try {
      final categories = await remoteDataSource.getCategories();
      return categories;
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<Quote>> searchQuotes({
    required String query,
    String? categoryId,
    String? author,
  }) async {
    try {
      final quotes = await remoteDataSource.searchQuotes(
        query: query,
        categoryId: categoryId,
        author: author,
      );
      return quotes;
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<String>> getAuthors({String? searchQuery}) async {
    try {
      final authors = await remoteDataSource.getAuthors(
        searchQuery: searchQuery,
      );
      return authors;
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  // Collections methods
  @override
  Future<List<Collection>> getCollections() async {
    try {
      final collections = await collectionsRemoteDataSource.getCollections();
      return collections;
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<Collection> createCollection({
    required String name,
    String? description,
    String? color,
    String? icon,
  }) async {
    try {
      final collection = await collectionsRemoteDataSource.createCollection(
        name: name,
        description: description,
        color: color,
        icon: icon,
      );
      return collection;
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> updateCollection(Collection collection) async {
    try {
      await collectionsRemoteDataSource.updateCollection(collection);
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> deleteCollection(String collectionId) async {
    try {
      await collectionsRemoteDataSource.deleteCollection(collectionId);
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<Quote>> getCollectionQuotes(String collectionId) async {
    try {
      final quotes = await collectionsRemoteDataSource.getCollectionQuotes(
        collectionId,
      );
      return quotes;
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> addQuoteToCollection(String collectionId, Quote quote) async {
    try {
      await collectionsRemoteDataSource.addQuoteToCollection(
        collectionId,
        quote,
      );
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> removeQuoteFromCollection(
    String collectionId,
    Quote quote,
  ) async {
    try {
      await collectionsRemoteDataSource.removeQuoteFromCollection(
        collectionId,
        quote,
      );
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<bool> isQuoteInCollection(String collectionId, Quote quote) async {
    try {
      return await collectionsRemoteDataSource.isQuoteInCollection(
        collectionId,
        quote,
      );
    } catch (e) {
      // If check fails, return false
      return false;
    }
  }

  // Likes methods
  @override
  Future<void> likeQuote(Quote quote) async {
    try {
      await likesRemoteDataSource.likeQuote(quote);
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> unlikeQuote(Quote quote) async {
    try {
      await likesRemoteDataSource.unlikeQuote(quote);
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<bool> isQuoteLiked(Quote quote) async {
    try {
      return await likesRemoteDataSource.isQuoteLiked(quote);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<int> getQuoteLikeCount(Quote quote) async {
    try {
      return await likesRemoteDataSource.getQuoteLikeCount(quote);
    } catch (e) {
      return quote.likes ?? 0;
    }
  }

  @override
  Future<List<String>> getLikedQuoteIds() async {
    try {
      return await likesRemoteDataSource.getLikedQuoteIds();
    } catch (e) {
      return [];
    }
  }
}
