import '../repositories/quotes_repository.dart';

class DeleteCollection {
  final QuotesRepository repository;

  DeleteCollection(this.repository);

  Future<void> call(String collectionId) async {
    return await repository.deleteCollection(collectionId);
  }
}

