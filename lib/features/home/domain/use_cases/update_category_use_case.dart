import 'dart:io';

import '../repositories/catalog_repository.dart';

class UpdateCategoryUseCase {
  const UpdateCategoryUseCase(this._repository);

  final CatalogRepository _repository;

  Future<void> call({
    required int id,
    required String name,
    required String arabicName,
    File? image,
  }) {
    return _repository.updateCategory(
      id: id,
      name: name,
      arabicName: arabicName,
      image: image,
    );
  }
}
