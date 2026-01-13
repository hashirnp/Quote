import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_client.dart';
import '../models/category_model.dart';
import '../models/quote_model.dart';

abstract class QuotesRemoteDataSource {
  Future<QuoteModel> getRandomQuote();
  Future<QuoteModel> getDailyQuote(int dayOfYear);
  Future<List<QuoteModel>> getQuotes({
    int page = 1,
    int limit = 20,
    String? categoryId,
    String? searchQuery,
    String? author,
  });
  Future<List<CategoryModel>> getCategories();
  Future<List<QuoteModel>> searchQuotes({
    required String query,
    String? categoryId,
    String? author,
  });
  Future<List<String>> getAuthors({String? searchQuery});
}

class QuotesRemoteDataSourceImpl implements QuotesRemoteDataSource {
  final SupabaseClient _supabase;
  final NetworkClient _networkClient; // Keep for ZenQuotes API

  QuotesRemoteDataSourceImpl(this._supabase, this._networkClient);

  @override
  Future<QuoteModel> getRandomQuote() async {
    try {
      // Try Supabase first, fallback to ZenQuotes API
      try {
        final response = await _supabase
            .from('quotes')
            .select()
            .limit(1)
            .order('random()')
            .maybeSingle();

        if (response != null) {
          return QuoteModel.fromJson(response);
        }
      } catch (_) {
        // If Supabase fails, fall through to ZenQuotes API
      }

      // Fallback to ZenQuotes API
      final apiResponse = await _networkClient.get('random');
      if (apiResponse.data != null &&
          apiResponse.data is List &&
          (apiResponse.data as List).isNotEmpty) {
        final data = apiResponse.data[0] as Map<String, dynamic>;
        return QuoteModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: data['q'] ?? '',
          author: data['a'] ?? 'Unknown',
        );
      }
      throw const ServerFailure('No quote data received');
    } catch (e) {
      if (e is Failure) {
        rethrow;
      }
      throw NetworkFailure(e.toString());
    }
  }

  @override
  Future<QuoteModel> getDailyQuote(int dayOfYear) async {
    try {
      // Get all quotes to determine total count
      final allQuotes = await _supabase
          .from('quotes')
          .select('id')
          .order('id');
      
      final totalQuotes = (allQuotes as List).length;
      if (totalQuotes == 0) {
        throw const ServerFailure('No quotes available');
      }

      // Use modulo to ensure we get a quote index within range (1-365 maps to 0 to totalQuotes-1)
      // dayOfYear is 1-365, we need to map it to a valid index
      final quoteIndex = (dayOfYear - 1) % totalQuotes;

      // Fetch the quote at that index (ordered by id for consistency)
      final response = await _supabase
          .from('quotes')
          .select()
          .order('id')
          .range(quoteIndex, quoteIndex)
          .maybeSingle();

      if (response != null) {
        return QuoteModel.fromJson(response);
      }

      // Fallback to random quote if specific index fails
      return await getRandomQuote();
    } catch (e) {
      if (e is Failure) {
        rethrow;
      }
      // Fallback to random quote on error
      return await getRandomQuote();
    }
  }

  @override
  Future<List<QuoteModel>> getQuotes({
    int page = 1,
    int limit = 20,
    String? categoryId,
    String? searchQuery,
    String? author,
  }) async {
    try {
      var query = _supabase.from('quotes').select();

      if (categoryId != null && categoryId.isNotEmpty) {
        query = query.eq('category_id', categoryId);
      }

      if (author != null && author.isNotEmpty) {
        query = query.ilike('author', '%$author%');
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or(
          'text.ilike.%$searchQuery%,author.ilike.%$searchQuery%',
        );
      }

      final from = (page - 1) * limit;
      final to = from + limit - 1;

      final data =
          await query.order('created_at', ascending: false).range(from, to);

      if (data.isEmpty) {
        return [];
      }

      return (data as List)
          .map((json) => QuoteModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is Failure) {
        rethrow;
      }
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final data = await _supabase.from('categories').select();
      if (data.isEmpty) {
        return [];
      }

      return (data as List)
          .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is Failure) {
        rethrow;
      }
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<QuoteModel>> searchQuotes({
    required String query,
    String? categoryId,
    String? author,
  }) async {
    try {
      var supabaseQuery = _supabase.from('quotes').select();

      if (categoryId != null) {
        supabaseQuery = supabaseQuery.eq('category_id', categoryId);
      }

      if (author != null && author.isNotEmpty) {
        supabaseQuery = supabaseQuery.ilike('author', '%$author%');
      }

      if (query.isNotEmpty) {
        supabaseQuery = supabaseQuery.or(
          'text.ilike.%$query%,author.ilike.%$query%',
        );
      }

      final data =
          await supabaseQuery.order('created_at', ascending: false).limit(50);

      if (data.isEmpty) {
        return [];
      }

      return (data as List)
          .map((json) => QuoteModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is Failure) {
        rethrow;
      }
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<String>> getAuthors({String? searchQuery}) async {
    try {
      var query = _supabase.from('quotes').select('author');

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.ilike('author', '%$searchQuery%');
      }

      final data = await query;

      if (data.isEmpty) {
        return [];
      }

      final authors = (data as List)
          .map((json) => (json as Map<String, dynamic>)['author'] as String)
          .toSet()
          .toList();

      return authors..sort();
    } catch (e) {
      if (e is Failure) {
        rethrow;
      }
      throw ServerFailure(e.toString());
    }
  }
}
