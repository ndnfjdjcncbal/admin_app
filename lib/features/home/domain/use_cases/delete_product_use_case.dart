import '../repositories/catalog_repository.dart';

class DeleteProductUseCase {
  const DeleteProductUseCase(this._repository);

  final CatalogRepository _repository;

  Future<void> call(int id) {
    return _repository.deleteProduct(id);
  }
}
