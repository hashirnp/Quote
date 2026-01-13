import '../entities/collection.dart';
import '../repositories/quotes_repository.dart';

class GetCollections {
  final QuotesRepository repository;

  GetCollections(this.repository);

  Future<List<Collection>> call() async {
    return await repository.getCollections();
  }
}

