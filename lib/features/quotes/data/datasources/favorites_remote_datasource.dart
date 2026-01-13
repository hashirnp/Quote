import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failures.dart';
import '../models/quote_model.dart';
import '../../domain/entities/quote.dart';

abstract class FavoritesRemoteDataSource {
  Future<void> saveFavoriteQuote(Quote quote);
  Future<List<QuoteModel>> getFavoriteQuotes();
  Future<void> removeFavoriteQuote(Quote quote);
  Future<bool> isQuoteFavorite(Quote quote);
}

class FavoritesRemoteDataSourceImpl implements FavoritesRemoteDataSource {
  final SupabaseClient _supabase;

  FavoritesRemoteDataSourceImpl(this._supabase);

  String? get _userId => _supabase.auth.currentUser?.id;

  @override
  Future<void> saveFavoriteQuote(Quote quote) async {
    try {
      if (_userId == null) {
        throw const ServerFailure('User not authenticated');
      }

      final data = {
        'user_id': _userId!,
        'quote_text': quote.text,
        'quote_author': quote.author,
      };
      if (quote.id.isNotEmpty) {
        data['quote_id'] = quote.id;
      }
      await _supabase.from('user_favorites').upsert(data);
    } catch (e) {
      if (e is Failure) {
        rethrow;
      }
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<QuoteModel>> getFavoriteQuotes() async {
    try {
      if (_userId == null) {
        return [];
      }

      final data = await _supabase
          .from('user_favorites')
          .select()
          .eq('user_id', _userId!)
          .order('created_at', ascending: false);

      if (data.isEmpty) {
        return [];
      }

      return (data as List).map((json) {
        return QuoteModel(
          id: json['quote_id']?.toString() ?? json['id']?.toString() ?? '',
          text: json['quote_text'] ?? '',
          author: json['quote_author'] ?? '',
          isFavorite: true,
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
  Future<void> removeFavoriteQuote(Quote quote) async {
    try {
      if (_userId == null) {
        throw const ServerFailure('User not authenticated');
      }

      if (quote.id.isNotEmpty) {
        await _supabase
            .from('user_favorites')
            .delete()
            .eq('user_id', _userId!)
            .eq('quote_id', quote.id);
      } else {
        // Fallback: match by text and author
        await _supabase
            .from('user_favorites')
            .delete()
            .eq('user_id', _userId!)
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
  Future<bool> isQuoteFavorite(Quote quote) async {
    try {
      if (_userId == null) {
        return false;
      }

      if (quote.id.isNotEmpty) {
        final data = await _supabase
            .from('user_favorites')
            .select('id')
            .eq('user_id', _userId!)
            .eq('quote_id', quote.id)
            .maybeSingle();

        return data != null;
      } else {
        // Fallback: match by text and author
        final data = await _supabase
            .from('user_favorites')
            .select('id')
            .eq('user_id', _userId!)
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

