import '../repositories/quotes_repository.dart';

class GetAuthors {
  final QuotesRepository repository;

  GetAuthors(this.repository);

  Future<List<String>> call({String? searchQuery}) async {
    return await repository.getAuthors(searchQuery: searchQuery);
  }
}

