import '../entities/catalog_entities.dart';
import '../repositories/catalog_repository.dart';

class GetProductsUseCase {
  const GetProductsUseCase(this._repository);

  final CatalogRepository _repository;

  Future<List<CatalogProduct>> call(int categoryId) {
    return _repository.getProducts(categoryId);
  }
}
