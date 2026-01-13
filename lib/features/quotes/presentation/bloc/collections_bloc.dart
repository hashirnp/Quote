import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/collection.dart';
import '../../domain/entities/quote.dart';
import '../../domain/usecases/get_collections.dart';
import '../../domain/usecases/create_collection.dart';
import '../../domain/usecases/update_collection.dart';
import '../../domain/usecases/delete_collection.dart';
import '../../domain/usecases/get_collection_quotes.dart';
import '../../domain/usecases/add_quote_to_collection.dart';
import '../../domain/usecases/remove_quote_from_collection.dart';
import '../../domain/usecases/is_quote_in_collection.dart';

part 'collections_event.dart';
part 'collections_state.dart';

class CollectionsBloc extends Bloc<CollectionsEvent, CollectionsState> {
  final GetCollections getCollections;
  final CreateCollection createCollection;
  final UpdateCollection updateCollection;
  final DeleteCollection deleteCollection;
  final GetCollectionQuotes getCollectionQuotes;
  final AddQuoteToCollection addQuoteToCollection;
  final RemoveQuoteFromCollection removeQuoteFromCollection;
  final IsQuoteInCollection isQuoteInCollection;

  CollectionsBloc({
    required this.getCollections,
    required this.createCollection,
    required this.updateCollection,
    required this.deleteCollection,
    required this.getCollectionQuotes,
    required this.addQuoteToCollection,
    required this.removeQuoteFromCollection,
    required this.isQuoteInCollection,
  }) : super(CollectionsInitial()) {
    on<LoadCollectionsEvent>(_onLoadCollections);
    on<CreateCollectionEvent>(_onCreateCollection);
    on<UpdateCollectionEvent>(_onUpdateCollection);
    on<DeleteCollectionEvent>(_onDeleteCollection);
    on<LoadCollectionQuotesEvent>(_onLoadCollectionQuotes);
    on<AddQuoteToCollectionEvent>(_onAddQuoteToCollection);
    on<RemoveQuoteFromCollectionEvent>(_onRemoveQuoteFromCollection);
    on<CheckQuoteInCollectionEvent>(_onCheckQuoteInCollection);
    on<UpdateCollectionQuotesEvent>(_onUpdateCollectionQuotes);
  }

  Future<void> _onLoadCollections(
    LoadCollectionsEvent event,
    Emitter<CollectionsState> emit,
  ) async {
    emit(CollectionsLoading());
    try {
      final collections = await getCollections();
      emit(CollectionsLoaded(collections: collections));
    } catch (e) {
      emit(CollectionsError(message: e.toString()));
    }
  }

  Future<void> _onCreateCollection(
    CreateCollectionEvent event,
    Emitter<CollectionsState> emit,
  ) async {
    try {
      final collection = await createCollection(
        name: event.name,
        description: event.description,
        color: event.color,
        icon: event.icon,
      );

      if (state is CollectionsLoaded) {
        final currentState = state as CollectionsLoaded;
        emit(CollectionsLoaded(
          collections: [collection, ...currentState.collections],
        ));
      } else {
        emit(CollectionsLoaded(collections: [collection]));
      }
    } catch (e) {
      emit(CollectionsError(message: e.toString()));
    }
  }

  Future<void> _onUpdateCollection(
    UpdateCollectionEvent event,
    Emitter<CollectionsState> emit,
  ) async {
    try {
      await updateCollection(event.collection);

      if (state is CollectionsLoaded) {
        final currentState = state as CollectionsLoaded;
        final updatedCollections = currentState.collections.map((c) {
          return c.id == event.collection.id ? event.collection : c;
        }).toList();
        emit(CollectionsLoaded(collections: updatedCollections));
      }
    } catch (e) {
      emit(CollectionsError(message: e.toString()));
    }
  }

  Future<void> _onDeleteCollection(
    DeleteCollectionEvent event,
    Emitter<CollectionsState> emit,
  ) async {
    try {
      await deleteCollection(event.collectionId);

      if (state is CollectionsLoaded) {
        final currentState = state as CollectionsLoaded;
        final updatedCollections = currentState.collections
            .where((c) => c.id != event.collectionId)
            .toList();
        emit(CollectionsLoaded(collections: updatedCollections));
      }
    } catch (e) {
      emit(CollectionsError(message: e.toString()));
    }
  }

  Future<void> _onLoadCollectionQuotes(
    LoadCollectionQuotesEvent event,
    Emitter<CollectionsState> emit,
  ) async {
    // Only emit loading if we're not already showing quotes for this collection
    if (state is! CollectionQuotesLoaded ||
        (state as CollectionQuotesLoaded).collectionId != event.collectionId) {
      emit(CollectionsLoading());
    }
    try {
      final quotes = await getCollectionQuotes(event.collectionId);
      emit(CollectionQuotesLoaded(
        collectionId: event.collectionId,
        quotes: quotes,
      ));
    } catch (e) {
      emit(CollectionsError(message: e.toString()));
    }
  }

  Future<void> _onAddQuoteToCollection(
    AddQuoteToCollectionEvent event,
    Emitter<CollectionsState> emit,
  ) async {
    try {
      await addQuoteToCollection(event.collectionId, event.quote);

      if (state is CollectionQuotesLoaded) {
        final currentState = state as CollectionQuotesLoaded;
        if (currentState.collectionId == event.collectionId) {
          emit(CollectionQuotesLoaded(
            collectionId: event.collectionId,
            quotes: [event.quote, ...currentState.quotes],
          ));
        }
      }
    } catch (e) {
      emit(CollectionsError(message: e.toString()));
    }
  }

  Future<void> _onRemoveQuoteFromCollection(
    RemoveQuoteFromCollectionEvent event,
    Emitter<CollectionsState> emit,
  ) async {
    try {
      await removeQuoteFromCollection(event.collectionId, event.quote);

      if (state is CollectionQuotesLoaded) {
        final currentState = state as CollectionQuotesLoaded;
        if (currentState.collectionId == event.collectionId) {
          final updatedQuotes = currentState.quotes
              .where((q) =>
                  (q.id.isNotEmpty &&
                      event.quote.id.isNotEmpty &&
                      q.id != event.quote.id) ||
                  (q.id.isEmpty || event.quote.id.isEmpty) &&
                      (q.text != event.quote.text ||
                          q.author != event.quote.author))
              .toList();
          emit(CollectionQuotesLoaded(
            collectionId: event.collectionId,
            quotes: updatedQuotes,
          ));
        }
      }
    } catch (e) {
      // Don't emit error, just log it
      // The quote might not be in the collection or there's a network issue
    }
  }

  Future<void> _onCheckQuoteInCollection(
    CheckQuoteInCollectionEvent event,
    Emitter<CollectionsState> emit,
  ) async {
    try {
      await isQuoteInCollection(
        event.collectionId,
        event.quote,
      );
      // This event doesn't change state, just checks
      // The result can be used by the UI directly
    } catch (e) {
      // Silently fail check
    }
  }

  Future<void> _onUpdateCollectionQuotes(
    UpdateCollectionQuotesEvent event,
    Emitter<CollectionsState> emit,
  ) async {
    // Simply update the quotes in the collection without reloading from server
    if (state is CollectionQuotesLoaded) {
      final currentState = state as CollectionQuotesLoaded;
      if (currentState.collectionId == event.collectionId) {
        emit(CollectionQuotesLoaded(
          collectionId: event.collectionId,
          quotes: event.quotes,
        ));
      }
    }
  }
}
