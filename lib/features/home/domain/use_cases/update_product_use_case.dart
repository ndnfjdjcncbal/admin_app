import 'dart:io';

import '../repositories/catalog_repository.dart';

class UpdateProductUseCase {
  const UpdateProductUseCase(this._repository);

  final CatalogRepository _repository;

  Future<void> call({
    required int id,
    required int categoryId,
    required String name,
    required String arabicName,
    required String price,
    required String description,
    required String arabicDescription,
    required int count,
    required String color,
    required String arabicColor,
    required String location,
    required String arabicLocation,
    File? image,
  }) {
    return _repository.updateProduct(
      id: id,
      categoryId: categoryId,
      name: name,
      arabicName: arabicName,
      price: price,
      description: description,
      arabicDescription: arabicDescription,
      count: count,
      color: color,
      arabicColor: arabicColor,
      location: location,
      arabicLocation: arabicLocation,
      image: image,
    );
  }
}
