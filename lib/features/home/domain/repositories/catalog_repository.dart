import 'dart:io';

import '../entities/catalog_entities.dart';

abstract class CatalogRepository {
  Future<List<CatalogCategory>> getCategories();
  Future<List<CatalogProduct>> getProducts(int categoryId);
  Future<void> addCategory({
    required String name,
    required String arabicName,
    required File image,
  });
  Future<void> updateCategory({
    required int id,
    required String name,
    required String arabicName,
    File? image,
  });
  Future<void> deleteCategory(int id);
  Future<void> addProduct({
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
    required File image,
  });
  Future<void> updateProduct({
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
  });
  Future<void> deleteProduct(int id);
}
