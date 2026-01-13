part of 'collections_bloc.dart';

abstract class CollectionsEvent extends Equatable {
  const CollectionsEvent();

  @override
  List<Object> get props => [];
}

class LoadCollectionsEvent extends CollectionsEvent {
  const LoadCollectionsEvent();
}

class CreateCollectionEvent extends CollectionsEvent {
  final String name;
  final String? description;
  final String? color;
  final String? icon;

  const CreateCollectionEvent({
    required this.name,
    this.description,
    this.color,
    this.icon,
  });

  @override
  List<Object> get props => [
        name,
        description ?? '',
        color ?? '',
        icon ?? '',
      ];
}

class UpdateCollectionEvent extends CollectionsEvent {
  final Collection collection;

  const UpdateCollectionEvent({required this.collection});

  @override
  List<Object> get props => [collection];
}

class DeleteCollectionEvent extends CollectionsEvent {
  final String collectionId;

  const DeleteCollectionEvent({required this.collectionId});

  @override
  List<Object> get props => [collectionId];
}

class LoadCollectionQuotesEvent extends CollectionsEvent {
  final String collectionId;

  const LoadCollectionQuotesEvent({required this.collectionId});

  @override
  List<Object> get props => [collectionId];
}

class AddQuoteToCollectionEvent extends CollectionsEvent {
  final String collectionId;
  final Quote quote;

  const AddQuoteToCollectionEvent({
    required this.collectionId,
    required this.quote,
  });

  @override
  List<Object> get props => [collectionId, quote];
}

class RemoveQuoteFromCollectionEvent extends CollectionsEvent {
  final String collectionId;
  final Quote quote;

  const RemoveQuoteFromCollectionEvent({
    required this.collectionId,
    required this.quote,
  });

  @override
  List<Object> get props => [collectionId, quote];
}

class CheckQuoteInCollectionEvent extends CollectionsEvent {
  final String collectionId;
  final Quote quote;

  const CheckQuoteInCollectionEvent({
    required this.collectionId,
    required this.quote,
  });

  @override
  List<Object> get props => [collectionId, quote];
}

class UpdateCollectionQuotesEvent extends CollectionsEvent {
  final String collectionId;
  final List<Quote> quotes;

  const UpdateCollectionQuotesEvent({
    required this.collectionId,
    required this.quotes,
  });

  @override
  List<Object> get props => [collectionId, quotes];
}
