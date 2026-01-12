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
}

class FavoritesLoading extends QuotesState {}

class FavoritesLoaded extends QuotesState {
  final List<Quote> quotes;

  const FavoritesLoaded({required this.quotes});

  @override
  List<Object> get props => [quotes];
}

class QuotesError extends QuotesState {
  final String message;

  const QuotesError({required this.message});

  @override
  List<Object> get props => [message];
}

