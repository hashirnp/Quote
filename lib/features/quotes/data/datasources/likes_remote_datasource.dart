import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/quote.dart';

abstract class LikesRemoteDataSource {
  Future<void> likeQuote(Quote quote);
  Future<void> unlikeQuote(Quote quote);
  Future<bool> isQuoteLiked(Quote quote);
  Future<int> getQuoteLikeCount(Quote quote);
  Future<List<String>> getLikedQuoteIds();
}

class LikesRemoteDataSourceImpl implements LikesRemoteDataSource {
  final SupabaseClient _supabase;

  LikesRemoteDataSourceImpl(this._supabase);

  String? get _userId => _supabase.auth.currentUser?.id;

  @override
  Future<void> likeQuote(Quote quote) async {
    try {
      if (_userId == null) {
        throw const ServerFailure('User not authenticated');
      }

      // Check if already liked
      final existing = await _supabase
          .from('quote_likes')
          .select('id')
          .eq('user_id', _userId!)
          .eq('quote_id',
              quote.id.isNotEmpty ? quote.id : 'temp_${quote.hashCode}')
          .maybeSingle();

      if (existing == null) {
        // Insert like
        await _supabase.from('quote_likes').insert({
          'user_id': _userId!,
          'quote_id': quote.id.isNotEmpty ? quote.id : 'temp_${quote.hashCode}',
          'quote_text': quote.text,
          'quote_author': quote.author,
        });
      }
    } catch (e) {
      if (e is Failure) {
        rethrow;
      }
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> unlikeQuote(Quote quote) async {
    try {
      if (_userId == null) {
        throw const ServerFailure('User not authenticated');
      }

      // Remove like
      await _supabase.from('quote_likes').delete().eq('user_id', _userId!).eq(
          'quote_id',
          quote.id.isNotEmpty ? quote.id : 'temp_${quote.hashCode}');
    } catch (e) {
      if (e is Failure) {
        rethrow;
      }
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<bool> isQuoteLiked(Quote quote) async {
    try {
      if (_userId == null) {
        return false;
      }

      final data = await _supabase
          .from('quote_likes')
          .select('id')
          .eq('user_id', _userId!)
          .eq('quote_id',
              quote.id.isNotEmpty ? quote.id : 'temp_${quote.hashCode}')
          .maybeSingle();

      return data != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<int> getQuoteLikeCount(Quote quote) async {
    try {
      if (quote.id.isEmpty) {
        // For quotes without ID, count likes by text/author
        final countData = await _supabase
            .from('quote_likes')
            .select()
            .eq('quote_text', quote.text)
            .eq('quote_author', quote.author);

        return (countData as List).length;
      }

      // Get count from quotes table
      final data = await _supabase
          .from('quotes')
          .select('likes')
          .eq('id', quote.id)
          .maybeSingle();

      return (data?['likes'] as int?) ?? 0;
    } catch (e) {
      return quote.likes ?? 0;
    }
  }

  @override
  Future<List<String>> getLikedQuoteIds() async {
    try {
      if (_userId == null) {
        return [];
      }

      final data = await _supabase
          .from('quote_likes')
          .select('quote_id, quote_text, quote_author')
          .eq('user_id', _userId!);

      // Convert to list of quote IDs
      // For quotes with ID, use the ID; for quotes without ID, use text|||author format
      final List<String> likedIds = [];
      for (final item in data) {
        final quoteId = item['quote_id'] as String? ?? '';
        final quoteText = item['quote_text'] as String? ?? '';
        final quoteAuthor = item['quote_author'] as String? ?? '';

        if (quoteId.isNotEmpty && !quoteId.startsWith('temp_')) {
          likedIds.add(quoteId);
        } else if (quoteText.isNotEmpty && quoteAuthor.isNotEmpty) {
          likedIds.add('$quoteText|||$quoteAuthor');
        }
      }

      return likedIds;
    } catch (e) {
      return [];
    }
  }
}
