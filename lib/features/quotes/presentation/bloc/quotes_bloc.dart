import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/quote.dart';
import '../../domain/usecases/get_random_quote.dart';
import '../../domain/usecases/get_daily_quote.dart';
import '../../domain/usecases/save_favorite_quote.dart';
import '../../domain/usecases/get_favorite_quotes.dart';
import '../../domain/usecases/remove_favorite_quote.dart';
import '../../domain/usecases/like_quote.dart';
import '../../domain/usecases/unlike_quote.dart';
import '../../domain/repositories/quotes_repository.dart';

part 'quotes_event.dart';
part 'quotes_state.dart';

/// Optimized QuotesBloc with:
/// - In-memory caching for likes and favorites
/// - Optimistic updates
/// - Reduced server calls
/// - Unified state management
class QuotesBloc extends Bloc<QuotesEvent, QuotesState> {
  final GetRandomQuote getRandomQuote;
  final GetDailyQuote getDailyQuote;
  final SaveFavoriteQuote saveFavoriteQuote;
  final GetFavoriteQuotes getFavoriteQuotes;
  final RemoveFavoriteQuote removeFavoriteQuote;
  final LikeQuote likeQuote;
  final UnlikeQuote unlikeQuote;
  final QuotesRepository repository;

  // In-memory cache for likes and favorites
  final Set<String> _likedQuoteIds = {};
  final Set<String> _favoriteQuoteIds = {};
  List<Quote> _cachedFavorites = [];

  // Track if initial load is done
  bool _likesLoaded = false;
  bool _favoritesLoaded = false;

  QuotesBloc({
    required this.getRandomQuote,
    required this.getDailyQuote,
    required this.saveFavoriteQuote,
    required this.getFavoriteQuotes,
    required this.removeFavoriteQuote,
    required this.likeQuote,
    required this.unlikeQuote,
    required this.repository,
  }) : super(QuotesInitial()) {
    on<GetRandomQuoteEvent>(_onGetRandomQuote);
    on<GetDailyQuoteEvent>(_onGetDailyQuote);
    on<SaveFavoriteQuoteEvent>(_onSaveFavoriteQuote);
    on<GetFavoriteQuotesEvent>(_onGetFavoriteQuotes);
    on<RemoveFavoriteQuoteEvent>(_onRemoveFavoriteQuote);
    on<LikeQuoteEvent>(_onLikeQuote);
    on<UnlikeQuoteEvent>(_onUnlikeQuote);
    on<LoadLikedQuotesEvent>(_onLoadLikedQuotes);
    on<LoadFavoritesEvent>(_onLoadFavorites);
    on<RefreshLikesAndFavoritesEvent>(_onRefreshLikesAndFavorites);
  }

  /// Get quote identifier (consistent format)
  String _getQuoteId(Quote quote) {
    if (quote.id.isNotEmpty) {
      return quote.id;
    }
    return '${quote.text}|||${quote.author}';
  }

  /// Check if quote is liked (from cache)
  bool _isQuoteLiked(Quote quote) {
    return _likedQuoteIds.contains(_getQuoteId(quote));
  }

  /// Check if quote is favorited (from cache)
  bool _isQuoteFavorite(Quote quote) {
    return _favoriteQuoteIds.contains(_getQuoteId(quote));
  }

  /// Enrich quote with like/favorite status from cache
  Quote _enrichQuote(Quote quote) {
    return quote.copyWith(
      isLiked: _isQuoteLiked(quote),
      isFavorite: _isQuoteFavorite(quote),
    );
  }

  Future<void> _onGetRandomQuote(
    GetRandomQuoteEvent event,
    Emitter<QuotesState> emit,
  ) async {
    emit(QuotesLoading());
    try {
      final quote = await getRandomQuote();
      // Use cached data instead of server calls
      final enrichedQuote = _enrichQuote(quote);
      emit(QuotesLoaded(
        quote: enrichedQuote,
        isFavorite: enrichedQuote.isFavorite ?? false,
      ));
    } catch (e) {
      emit(QuotesError(message: e.toString()));
    }
  }

  Future<void> _onGetDailyQuote(
    GetDailyQuoteEvent event,
    Emitter<QuotesState> emit,
  ) async {
    emit(QuotesLoading());
    try {
      final quote = await getDailyQuote();
      // Use cached data instead of server calls
      final enrichedQuote = _enrichQuote(quote);
      emit(QuotesLoaded(
        quote: enrichedQuote,
        isFavorite: enrichedQuote.isFavorite ?? false,
      ));
    } catch (e) {
      emit(QuotesError(message: e.toString()));
    }
  }

  Future<void> _onSaveFavoriteQuote(
    SaveFavoriteQuoteEvent event,
    Emitter<QuotesState> emit,
  ) async {
    final quoteId = _getQuoteId(event.quote);

    // Skip if already favorited
    if (_favoriteQuoteIds.contains(quoteId)) {
      return;
    }

    // Optimistic update: update cache immediately
    _favoriteQuoteIds.add(quoteId);
    // Create a new Quote entity (not QuoteModel) to ensure type consistency
    final enrichedQuote = _enrichQuote(event.quote);
    _cachedFavorites.add(Quote(
      id: enrichedQuote.id,
      text: enrichedQuote.text,
      author: enrichedQuote.author,
      authorImage: enrichedQuote.authorImage,
      categoryId: enrichedQuote.categoryId,
      categoryName: enrichedQuote.categoryName,
      likes: enrichedQuote.likes,
      shares: enrichedQuote.shares,
      isFavorite: true,
      isLiked: enrichedQuote.isLiked,
    ));

    // Always emit a state to trigger UI rebuilds
    // Create a new list instance with new timestamp to ensure Equatable sees it as different
    final updatedFavorites = List<Quote>.from(_cachedFavorites);

    // Update current state if applicable
    if (state is QuotesLoaded) {
      final currentState = state as QuotesLoaded;
      if (_getQuoteId(currentState.quote) == quoteId) {
        emit(currentState.copyWith(
          quote: currentState.quote.copyWith(isFavorite: true),
          isFavorite: true,
        ));
      } else {
        // Emit FavoritesLoaded with new timestamp to trigger rebuilds in quote cards
        emit(FavoritesLoaded(quotes: updatedFavorites));
      }
    } else {
      // Always emit FavoritesLoaded with new timestamp to trigger rebuilds in quote cards
      emit(FavoritesLoaded(quotes: updatedFavorites));
    }

    // Sync to server in background (don't await)
    saveFavoriteQuote(event.quote).catchError((error) {
      // Rollback on error
      _favoriteQuoteIds.remove(quoteId);
      _cachedFavorites.removeWhere((q) => _getQuoteId(q) == quoteId);

      // Revert state
      if (state is QuotesLoaded) {
        final currentState = state as QuotesLoaded;
        if (_getQuoteId(currentState.quote) == quoteId) {
          emit(currentState.copyWith(
            quote: currentState.quote.copyWith(isFavorite: false),
            isFavorite: false,
          ));
        }
      }

      if (state is FavoritesLoaded) {
        emit(FavoritesLoaded(quotes: List.from(_cachedFavorites)));
      }
    });
  }

  Future<void> _onGetFavoriteQuotes(
    GetFavoriteQuotesEvent event,
    Emitter<QuotesState> emit,
  ) async {
    // Return cached data if available
    if (_favoritesLoaded && _cachedFavorites.isNotEmpty) {
      emit(FavoritesLoaded(quotes: List.from(_cachedFavorites)));
      return;
    }

    emit(FavoritesLoading());
    try {
      final quotes = await getFavoriteQuotes();
      // Convert all quotes to Quote entities (not QuoteModel) for consistency
      _cachedFavorites = quotes
          .map((q) => Quote(
                id: q.id,
                text: q.text,
                author: q.author,
                authorImage: q.authorImage,
                categoryId: q.categoryId,
                categoryName: q.categoryName,
                likes: q.likes,
                shares: q.shares,
                isFavorite: true,
                isLiked: q.isLiked,
              ))
          .toList();
      _favoritesLoaded = true;

      // Update cache
      _favoriteQuoteIds.clear();
      for (final quote in _cachedFavorites) {
        _favoriteQuoteIds.add(_getQuoteId(quote));
      }

      emit(FavoritesLoaded(quotes: List.from(_cachedFavorites)));
    } catch (e) {
      emit(QuotesError(message: e.toString()));
    }
  }

  Future<void> _onRemoveFavoriteQuote(
    RemoveFavoriteQuoteEvent event,
    Emitter<QuotesState> emit,
  ) async {
    final quoteId = _getQuoteId(event.quote);

    // Skip if already not favorited
    if (!_favoriteQuoteIds.contains(quoteId)) {
      return;
    }

    // Optimistic update: update cache immediately
    _favoriteQuoteIds.remove(quoteId);
    _cachedFavorites.removeWhere((q) => _getQuoteId(q) == quoteId);

    // Always emit a state to trigger UI rebuilds
    // Create a new list instance to ensure Equatable sees it as different
    final updatedFavorites = List<Quote>.from(_cachedFavorites);

    // Update current state if applicable
    if (state is QuotesLoaded) {
      final currentState = state as QuotesLoaded;
      if (_getQuoteId(currentState.quote) == quoteId) {
        emit(currentState.copyWith(
          quote: currentState.quote.copyWith(isFavorite: false),
          isFavorite: false,
        ));
      } else {
        // Emit FavoritesLoaded to trigger rebuilds in quote cards
        emit(FavoritesLoaded(quotes: updatedFavorites));
      }
    } else {
      // Always emit FavoritesLoaded to trigger rebuilds in quote cards
      emit(FavoritesLoaded(quotes: updatedFavorites));
    }

    // Sync to server in background (don't await)
    removeFavoriteQuote(event.quote).catchError((error) {
      // Rollback on error
      _favoriteQuoteIds.add(quoteId);
      final enrichedQuote = _enrichQuote(event.quote);
      _cachedFavorites.add(Quote(
        id: enrichedQuote.id,
        text: enrichedQuote.text,
        author: enrichedQuote.author,
        authorImage: enrichedQuote.authorImage,
        categoryId: enrichedQuote.categoryId,
        categoryName: enrichedQuote.categoryName,
        likes: enrichedQuote.likes,
        shares: enrichedQuote.shares,
        isFavorite: true,
        isLiked: enrichedQuote.isLiked,
      ));

      // Revert state
      if (state is FavoritesLoaded) {
        emit(FavoritesLoaded(quotes: List.from(_cachedFavorites)));
      }

      if (state is QuotesLoaded) {
        final currentState = state as QuotesLoaded;
        if (_getQuoteId(currentState.quote) == quoteId) {
          emit(currentState.copyWith(
            quote: currentState.quote.copyWith(isFavorite: true),
            isFavorite: true,
          ));
        }
      }
    });
  }

  Future<void> _onLikeQuote(
    LikeQuoteEvent event,
    Emitter<QuotesState> emit,
  ) async {
    final quoteId = _getQuoteId(event.quote);
    final wasLiked = _likedQuoteIds.contains(quoteId);

    // Skip if already liked
    if (wasLiked) {
      return;
    }

    // Optimistic update: update cache immediately
    _likedQuoteIds.add(quoteId);

    // Always emit a state to trigger UI rebuilds
    // Create a new list instance to ensure Equatable sees it as different
    final updatedFavorites = List<Quote>.from(_cachedFavorites);

    if (state is QuotesLoaded) {
      final currentState = state as QuotesLoaded;
      if (_getQuoteId(currentState.quote) == quoteId) {
        emit(currentState.copyWith(
          quote: currentState.quote.copyWith(isLiked: true),
        ));
      } else {
        // Emit FavoritesLoaded to trigger rebuilds in quote cards
        emit(FavoritesLoaded(quotes: updatedFavorites));
      }
    } else {
      // Always emit FavoritesLoaded to trigger rebuilds in quote cards
      emit(FavoritesLoaded(quotes: updatedFavorites));
    }

    // Sync to server in background (don't await)
    likeQuote(event.quote).catchError((error) {
      // Rollback on error
      _likedQuoteIds.remove(quoteId);

      // Revert state - emit to trigger rebuilds
      if (state is QuotesLoaded) {
        final currentState = state as QuotesLoaded;
        if (_getQuoteId(currentState.quote) == quoteId) {
          emit(currentState.copyWith(
            quote: currentState.quote.copyWith(isLiked: false),
          ));
        } else {
          emit(currentState);
        }
      } else if (state is FavoritesLoaded) {
        emit(FavoritesLoaded(quotes: List.from(_cachedFavorites)));
      } else {
        emit(FavoritesLoaded(quotes: List.from(_cachedFavorites)));
      }
    });
  }

  Future<void> _onUnlikeQuote(
    UnlikeQuoteEvent event,
    Emitter<QuotesState> emit,
  ) async {
    final quoteId = _getQuoteId(event.quote);
    final wasLiked = _likedQuoteIds.contains(quoteId);

    // Skip if already unliked
    if (!wasLiked) {
      return;
    }

    // Optimistic update: update cache immediately
    _likedQuoteIds.remove(quoteId);

    // Always emit a state to trigger UI rebuilds
    // Create a new list instance to ensure Equatable sees it as different
    final updatedFavorites = List<Quote>.from(_cachedFavorites);

    if (state is QuotesLoaded) {
      final currentState = state as QuotesLoaded;
      if (_getQuoteId(currentState.quote) == quoteId) {
        emit(currentState.copyWith(
          quote: currentState.quote.copyWith(isLiked: false),
        ));
      } else {
        // Emit FavoritesLoaded to trigger rebuilds in quote cards
        emit(FavoritesLoaded(quotes: updatedFavorites));
      }
    } else {
      // Always emit FavoritesLoaded to trigger rebuilds in quote cards
      emit(FavoritesLoaded(quotes: updatedFavorites));
    }

    // Sync to server in background (don't await)
    unlikeQuote(event.quote).catchError((error) {
      // Rollback on error
      _likedQuoteIds.add(quoteId);

      // Revert state - emit to trigger rebuilds
      if (state is QuotesLoaded) {
        final currentState = state as QuotesLoaded;
        if (_getQuoteId(currentState.quote) == quoteId) {
          emit(currentState.copyWith(
            quote: currentState.quote.copyWith(isLiked: true),
          ));
        } else {
          emit(currentState);
        }
      } else if (state is FavoritesLoaded) {
        emit(FavoritesLoaded(quotes: List.from(_cachedFavorites)));
      } else {
        emit(FavoritesLoaded(quotes: List.from(_cachedFavorites)));
      }
    });
  }

  Future<void> _onLoadLikedQuotes(
    LoadLikedQuotesEvent event,
    Emitter<QuotesState> emit,
  ) async {
    // Skip if already loaded
    if (_likesLoaded) {
      return;
    }

    try {
      final likedIds = await repository.getLikedQuoteIds();
      _likedQuoteIds.clear();
      _likedQuoteIds.addAll(likedIds);
      _likesLoaded = true;

      // Update current quote if loaded
      if (state is QuotesLoaded) {
        final currentState = state as QuotesLoaded;
        emit(currentState.copyWith(
          quote: _enrichQuote(currentState.quote),
        ));
      }
    } catch (e) {
      // Silently fail - cache will be empty, will work offline
      _likesLoaded = true; // Mark as loaded to prevent retries
    }
  }

  Future<void> _onLoadFavorites(
    LoadFavoritesEvent event,
    Emitter<QuotesState> emit,
  ) async {
    // Skip if already loaded
    if (_favoritesLoaded) {
      return;
    }

    try {
      final quotes = await getFavoriteQuotes();
      // Convert all quotes to Quote entities (not QuoteModel) for consistency
      _cachedFavorites = quotes
          .map((q) => Quote(
                id: q.id,
                text: q.text,
                author: q.author,
                authorImage: q.authorImage,
                categoryId: q.categoryId,
                categoryName: q.categoryName,
                likes: q.likes,
                shares: q.shares,
                isFavorite: true,
                isLiked: q.isLiked,
              ))
          .toList();
      _favoritesLoaded = true;

      // Update cache
      _favoriteQuoteIds.clear();
      for (final quote in _cachedFavorites) {
        _favoriteQuoteIds.add(_getQuoteId(quote));
      }

      // Update current quote if loaded
      if (state is QuotesLoaded) {
        final currentState = state as QuotesLoaded;
        emit(currentState.copyWith(
          quote: _enrichQuote(currentState.quote),
        ));
      }
    } catch (e) {
      // Silently fail - cache will be empty, will work offline
      _favoritesLoaded = true; // Mark as loaded to prevent retries
    }
  }

  Future<void> _onRefreshLikesAndFavorites(
    RefreshLikesAndFavoritesEvent event,
    Emitter<QuotesState> emit,
  ) async {
    // Reset flags to force reload
    _likesLoaded = false;
    _favoritesLoaded = false;

    // Load both in parallel
    await Future.wait([
      _onLoadLikedQuotes(const LoadLikedQuotesEvent(), emit),
      _onLoadFavorites(const LoadFavoritesEvent(), emit),
    ]);
  }

  /// Public method to check if quote is liked (for external use)
  bool isQuoteLiked(Quote quote) {
    return _isQuoteLiked(quote);
  }

  /// Public method to check if quote is favorited (for external use)
  bool isQuoteFavorite(Quote quote) {
    return _isQuoteFavorite(quote);
  }
}
