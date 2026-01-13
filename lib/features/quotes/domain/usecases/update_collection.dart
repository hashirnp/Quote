import '../entities/collection.dart';
import '../repositories/quotes_repository.dart';

class UpdateCollection {
  final QuotesRepository repository;

  UpdateCollection(this.repository);

  Future<void> call(Collection collection) async {
    return await repository.updateCollection(collection);
  }
}

