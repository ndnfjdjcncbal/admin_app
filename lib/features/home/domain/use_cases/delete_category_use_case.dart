import '../repositories/catalog_repository.dart';

class DeleteCategoryUseCase {
  const DeleteCategoryUseCase(this._repository);

  final CatalogRepository _repository;

  Future<void> call(int id) {
    return _repository.deleteCategory(id);
  }
}
