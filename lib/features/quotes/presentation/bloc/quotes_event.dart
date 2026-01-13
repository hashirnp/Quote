part of 'quotes_bloc.dart';

abstract class QuotesEvent extends Equatable {
  const QuotesEvent();

  @override
  List<Object> get props => [];
}

class GetRandomQuoteEvent extends QuotesEvent {}

class SaveFavoriteQuoteEvent extends QuotesEvent {
  final Quote quote;

  const SaveFavoriteQuoteEvent(this.quote);

  @override
  List<Object> get props => [quote];
}

class GetFavoriteQuotesEvent extends QuotesEvent {}

class RemoveFavoriteQuoteEvent extends QuotesEvent {
  final Quote quote;

  const RemoveFavoriteQuoteEvent(this.quote);

  @override
  List<Object> get props => [quote];
}

class LikeQuoteEvent extends QuotesEvent {
  final Quote quote;

  const LikeQuoteEvent(this.quote);

  @override
  List<Object> get props => [quote];
}

class UnlikeQuoteEvent extends QuotesEvent {
  final Quote quote;

  const UnlikeQuoteEvent(this.quote);

  @override
  List<Object> get props => [quote];
}

class LoadLikedQuotesEvent extends QuotesEvent {
  const LoadLikedQuotesEvent();
}

class GetDailyQuoteEvent extends QuotesEvent {
  const GetDailyQuoteEvent();
}

class LoadFavoritesEvent extends QuotesEvent {
  const LoadFavoritesEvent();
}

class RefreshLikesAndFavoritesEvent extends QuotesEvent {
  const RefreshLikesAndFavoritesEvent();
}
