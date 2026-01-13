import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failures.dart';
import '../models/collection_model.dart';
import '../models/quote_model.dart';
import '../../domain/entities/collection.dart';
import '../../domain/entities/quote.dart';

abstract class CollectionsRemoteDataSource {
  Future<List<CollectionModel>> getCollections();
  Future<CollectionModel> createCollection({
    required String name,
    String? description,
    String? color,
    String? icon,
  });
  Future<void> updateCollection(Collection collection);
  Future<void> deleteCollection(String collectionId);
  Future<List<QuoteModel>> getCollectionQuotes(String collectionId);
  Future<void> addQuoteToCollection(String collectionId, Quote quote);
  Future<void> removeQuoteFromCollection(String collectionId, Quote quote);
  Future<bool> isQuoteInCollection(String collectionId, Quote quote);
}

class CollectionsRemoteDataSourceImpl implements CollectionsRemoteDataSource {
  final SupabaseClient _supabase;

  CollectionsRemoteDataSourceImpl(this._supabase);

  String? get _userId => _supabase.auth.currentUser?.id;

  @override
  Future<List<CollectionModel>> getCollections() async {
    try {
      if (_userId == null) {
        return [];
      }

      final data = await _supabase
          .from('collections')
          .select()
          .eq('user_id', _userId!)
          .order('created_at', ascending: false);

      if (data.isEmpty) {
        return [];
      }

      // Get quote counts for each collection
      final collectionsWithCounts = await Future.wait(
        (data as List).map((json) async {
          final collectionId = json['id']?.toString() ?? '';
          if (collectionId.isEmpty) {
            return CollectionModel.fromJson({
              ...json,
              'quote_count': 0,
            });
          }
          
          final quoteCountData = await _supabase
              .from('collection_quotes')
              .select()
              .eq('collection_id', collectionId);
          
          final quoteCount = (quoteCountData as List).length;
          
          return CollectionModel.fromJson({
            ...json,
            'quote_count': quoteCount,
          });
        }),
      );

      return collectionsWithCounts;
    } catch (e) {
      if (e is Failure) {
        rethrow;
      }
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<CollectionModel> createCollection({
    required String name,
    String? description,
    String? color,
    String? icon,
  }) async {
    try {
      if (_userId == null) {
        throw const ServerFailure('User not authenticated');
      }

      final insertData = {
        'user_id': _userId!,
        'name': name,
      };
      if (description != null) insertData['description'] = description;
      if (color != null) insertData['color'] = color;
      if (icon != null) insertData['icon'] = icon;
      
      final data = await _supabase
          .from('collections')
          .insert(insertData)
          .select()
          .single();

      return CollectionModel.fromJson({
        ...data,
        'quote_count': 0,
      });
    } catch (e) {
      if (e is Failure) {
        rethrow;
      }
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> updateCollection(Collection collection) async {
    try {
      if (_userId == null) {
        throw const ServerFailure('User not authenticated');
      }

      final updateData = <String, dynamic>{
        'name': collection.name,
      };
      if (collection.description != null) {
        updateData['description'] = collection.description!;
      }
      if (collection.color != null) {
        updateData['color'] = collection.color!;
      }
      if (collection.icon != null) {
        updateData['icon'] = collection.icon!;
      }
      
      await _supabase
          .from('collections')
          .update(updateData)
          .eq('id', collection.id)
          .eq('user_id', _userId!);
    } catch (e) {
      if (e is Failure) {
        rethrow;
      }
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> deleteCollection(String collectionId) async {
    try {
      if (_userId == null) {
        throw const ServerFailure('User not authenticated');
      }

      await _supabase
          .from('collections')
          .delete()
          .eq('id', collectionId)
          .eq('user_id', _userId!);
    } catch (e) {
      if (e is Failure) {
        rethrow;
      }
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<QuoteModel>> getCollectionQuotes(String collectionId) async {
    try {
      if (_userId == null) {
        return [];
      }

      // Verify collection belongs to user
      final collection = await _supabase
          .from('collections')
          .select('id')
          .eq('id', collectionId)
          .eq('user_id', _userId!)
          .maybeSingle();

      if (collection == null) {
        return [];
      }

      final data = await _supabase
          .from('collection_quotes')
          .select()
          .eq('collection_id', collectionId)
          .order('created_at', ascending: false);

      if (data.isEmpty) {
        return [];
      }

      return (data as List).map((json) {
        return QuoteModel(
          id: json['quote_id']?.toString() ?? json['id']?.toString() ?? '',
          text: json['quote_text'] ?? '',
          author: json['quote_author'] ?? '',
        );
      }).toList();
    } catch (e) {
      if (e is Failure) {
        rethrow;
      }
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> addQuoteToCollection(String collectionId, Quote quote) async {
    try {
      if (_userId == null) {
        throw const ServerFailure('User not authenticated');
      }

      // Verify collection belongs to user
      final collection = await _supabase
          .from('collections')
          .select('id')
          .eq('id', collectionId)
          .eq('user_id', _userId!)
          .maybeSingle();

      if (collection == null) {
        throw const ServerFailure('Collection not found');
      }

      final insertData = {
        'collection_id': collectionId,
        'quote_text': quote.text,
        'quote_author': quote.author,
      };
      if (quote.id.isNotEmpty) {
        insertData['quote_id'] = quote.id;
      }
      await _supabase.from('collection_quotes').upsert(insertData);
    } catch (e) {
      if (e is Failure) {
        rethrow;
      }
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> removeQuoteFromCollection(
    String collectionId,
    Quote quote,
  ) async {
    try {
      if (_userId == null) {
        throw const ServerFailure('User not authenticated');
      }

      if (quote.id.isNotEmpty) {
        await _supabase
            .from('collection_quotes')
            .delete()
            .eq('collection_id', collectionId)
            .eq('quote_id', quote.id);
      } else {
        // Fallback: match by text and author
        await _supabase
            .from('collection_quotes')
            .delete()
            .eq('collection_id', collectionId)
            .eq('quote_text', quote.text)
            .eq('quote_author', quote.author);
      }
    } catch (e) {
      if (e is Failure) {
        rethrow;
      }
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<bool> isQuoteInCollection(String collectionId, Quote quote) async {
    try {
      if (_userId == null) {
        return false;
      }

      if (quote.id.isNotEmpty) {
        final data = await _supabase
            .from('collection_quotes')
            .select('id')
            .eq('collection_id', collectionId)
            .eq('quote_id', quote.id)
            .maybeSingle();

        return data != null;
      } else {
        // Fallback: match by text and author
        final data = await _supabase
            .from('collection_quotes')
            .select('id')
            .eq('collection_id', collectionId)
            .eq('quote_text', quote.text)
            .eq('quote_author', quote.author)
            .maybeSingle();

        return data != null;
      }
    } catch (e) {
      // If check fails, return false
      return false;
    }
  }
}

