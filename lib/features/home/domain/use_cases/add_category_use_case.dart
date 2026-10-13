import 'dart:io';

import '../repositories/catalog_repository.dart';

class AddCategoryUseCase {
  const AddCategoryUseCase(this._repository);

  final CatalogRepository _repository;

  Future<void> call({
    required String name,
    required String arabicName,
    required File image,
  }) {
    return _repository.addCategory(
      name: name,
      arabicName: arabicName,
      image: image,
    );
  }
}
