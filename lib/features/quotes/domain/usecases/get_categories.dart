import '../entities/category.dart';
import '../repositories/quotes_repository.dart';

class GetCategories {
  final QuotesRepository repository;

  GetCategories(this.repository);

  Future<List<Category>> call() async {
    return await repository.getCategories();
  }
}

