part of 'collections_bloc.dart';

abstract class CollectionsState extends Equatable {
  const CollectionsState();

  @override
  List<Object> get props => [];
}

class CollectionsInitial extends CollectionsState {}

class CollectionsLoading extends CollectionsState {}

class CollectionsLoaded extends CollectionsState {
  final List<Collection> collections;

  const CollectionsLoaded({required this.collections});

  @override
  List<Object> get props => [collections];
}

class CollectionQuotesLoaded extends CollectionsState {
  final String collectionId;
  final List<Quote> quotes;

  const CollectionQuotesLoaded({
    required this.collectionId,
    required this.quotes,
  });

  @override
  List<Object> get props => [collectionId, quotes];
}

class CollectionsError extends CollectionsState {
  final String message;

  const CollectionsError({required this.message});

  @override
  List<Object> get props => [message];
}

