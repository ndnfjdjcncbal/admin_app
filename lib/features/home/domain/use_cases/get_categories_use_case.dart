import '../entities/catalog_entities.dart';
import '../repositories/catalog_repository.dart';

class GetCategoriesUseCase {
  const GetCategoriesUseCase(this._repository);

  final CatalogRepository _repository;

  Future<List<CatalogCategory>> call() {
    return _repository.getCategories();
  }
}
