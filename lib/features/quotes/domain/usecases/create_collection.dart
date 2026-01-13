import '../entities/collection.dart';
import '../repositories/quotes_repository.dart';

class CreateCollection {
  final QuotesRepository repository;

  CreateCollection(this.repository);

  Future<Collection> call({
    required String name,
    String? description,
    String? color,
    String? icon,
  }) async {
    return await repository.createCollection(
      name: name,
      description: description,
      color: color,
      icon: icon,
    );
  }
}

