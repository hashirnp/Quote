import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/quote.dart';
import '../../domain/usecases/get_random_quote.dart';
import '../../domain/usecases/save_favorite_quote.dart';
import '../../domain/usecases/get_favorite_quotes.dart';
import '../../domain/usecases/remove_favorite_quote.dart';

part 'quotes_event.dart';
part 'quotes_state.dart';

class QuotesBloc extends Bloc<QuotesEvent, QuotesState> {
  final GetRandomQuote getRandomQuote;
  final SaveFavoriteQuote saveFavoriteQuote;
  final GetFavoriteQuotes getFavoriteQuotes;
  final RemoveFavoriteQuote removeFavoriteQuote;

  QuotesBloc({
    required this.getRandomQuote,
    required this.saveFavoriteQuote,
    required this.getFavoriteQuotes,
    required this.removeFavoriteQuote,
  }) : super(QuotesInitial()) {
    on<GetRandomQuoteEvent>(_onGetRandomQuote);
    on<SaveFavoriteQuoteEvent>(_onSaveFavoriteQuote);
    on<GetFavoriteQuotesEvent>(_onGetFavoriteQuotes);
    on<RemoveFavoriteQuoteEvent>(_onRemoveFavoriteQuote);
  }

  Future<void> _onGetRandomQuote(
    GetRandomQuoteEvent event,
    Emitter<QuotesState> emit,
  ) async {
    emit(QuotesLoading());
    try {
      final quote = await getRandomQuote();
      // Check if quote is already favorited
      final favorites = await getFavoriteQuotes();
      final isFavorite = favorites.any(
        (q) => q.text == quote.text && q.author == quote.author,
      );
      emit(QuotesLoaded(quote: quote, isFavorite: isFavorite));
    } catch (e) {
      emit(QuotesError(message: e.toString()));
    }
  }

  Future<void> _onSaveFavoriteQuote(
    SaveFavoriteQuoteEvent event,
    Emitter<QuotesState> emit,
  ) async {
    try {
      await saveFavoriteQuote(event.quote);
      if (state is QuotesLoaded) {
        final currentState = state as QuotesLoaded;
        emit(QuotesLoaded(quote: currentState.quote, isFavorite: true));
      } else if (state is FavoritesLoaded) {
        // Refresh favorites list if we're on favorites page
        add(GetFavoriteQuotesEvent());
      }
    } catch (e) {
      emit(QuotesError(message: e.toString()));
    }
  }

  Future<void> _onGetFavoriteQuotes(
    GetFavoriteQuotesEvent event,
    Emitter<QuotesState> emit,
  ) async {
    emit(FavoritesLoading());
    try {
      final quotes = await getFavoriteQuotes();
      emit(FavoritesLoaded(quotes: quotes));
    } catch (e) {
      emit(QuotesError(message: e.toString()));
    }
  }

  Future<void> _onRemoveFavoriteQuote(
    RemoveFavoriteQuoteEvent event,
    Emitter<QuotesState> emit,
  ) async {
    try {
      await removeFavoriteQuote(event.quote);
      if (state is FavoritesLoaded) {
        final currentState = state as FavoritesLoaded;
        final updatedQuotes = List<Quote>.from(currentState.quotes)
          ..removeWhere((q) => q.text == event.quote.text && q.author == event.quote.author);
        emit(FavoritesLoaded(quotes: updatedQuotes));
      } else if (state is QuotesLoaded) {
        // Update home page if the removed quote is the current one
        final currentState = state as QuotesLoaded;
        if (currentState.quote.text == event.quote.text &&
            currentState.quote.author == event.quote.author) {
          emit(QuotesLoaded(quote: currentState.quote, isFavorite: false));
        }
      }
    } catch (e) {
      emit(QuotesError(message: e.toString()));
    }
  }
}

