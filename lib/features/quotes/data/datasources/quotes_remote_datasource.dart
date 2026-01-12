import '../../../../core/network/network_client.dart';
import '../../../../core/errors/failures.dart';
import '../models/quote_model.dart';

abstract class QuotesRemoteDataSource {
  Future<QuoteModel> getRandomQuote();
}

class QuotesRemoteDataSourceImpl implements QuotesRemoteDataSource {
  final NetworkClient networkClient;

  QuotesRemoteDataSourceImpl(this.networkClient);

  @override
  Future<QuoteModel> getRandomQuote() async {
    try {
      final response = await networkClient.get('random');
      if (response.data != null &&
          response.data is List &&
          (response.data as List).isNotEmpty) {
        return QuoteModel.fromJson(response.data[0]);
      }
      throw const ServerFailure('No quote data received');
    } catch (e) {
      if (e is Failure) {
        rethrow;
      }
      throw NetworkFailure(e.toString());
    }
  }
}
