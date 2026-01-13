part of 'quotes_bloc.dart';

abstract class QuotesState extends Equatable {
  const QuotesState();

  @override
  List<Object> get props => [];
}

class QuotesInitial extends QuotesState {}

class QuotesLoading extends QuotesState {}

class QuotesLoaded extends QuotesState {
  final Quote quote;
  final bool isFavorite;

  const QuotesLoaded({
    required this.quote,
    this.isFavorite = false,
  });

  @override
  List<Object> get props => [quote, isFavorite];

  QuotesLoaded copyWith({
    Quote? quote,
    bool? isFavorite,
  }) {
    return QuotesLoaded(
      quote: quote ?? this.quote,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

class FavoritesLoading extends QuotesState {}

class FavoritesLoaded extends QuotesState {
  final List<Quote> quotes;
  final int timestamp; // Add timestamp to ensure state is always different

  FavoritesLoaded({
    required this.quotes,
    int? timestamp,
  }) : timestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch;

  @override
  List<Object> get props => [quotes, timestamp];
}

class QuotesError extends QuotesState {
  final String message;

  const QuotesError({required this.message});

  @override
  List<Object> get props => [message];
}

// State to track all liked quotes (maintains persistent like status)
class LikedQuotesState extends QuotesState {
  final Set<String> likedQuoteIds;

  const LikedQuotesState({required this.likedQuoteIds});

  @override
  List<Object> get props => [likedQuoteIds];

  LikedQuotesState copyWith({
    Set<String>? likedQuoteIds,
  }) {
    return LikedQuotesState(
      likedQuoteIds: likedQuoteIds ?? this.likedQuoteIds,
    );
  }
}
