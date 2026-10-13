import 'dart:convert';
import 'dart:io';

import '../models/catalog_category_model.dart';
import '../models/catalog_product_model.dart';
import '../remote_data_source/catalog_remote_data_source.dart';
import '../../domain/entities/catalog_entities.dart';
import '../../domain/repositories/catalog_repository.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  CatalogRepositoryImpl(this._remoteDataSource);

  final CatalogRemoteDataSource _remoteDataSource;

  @override
  Future<List<CatalogCategory>> getCategories() async {
    final response = await _remoteDataSource.getCategories();
    final payload = _responseList(response.data);
    return payload
        .map((item) => CatalogCategoryModel.fromJson(item).toEntity())
        .toList();
  }

  @override
  Future<List<CatalogProduct>> getProducts(int categoryId) async {
    final response = await _remoteDataSource.getProductsForCategory(categoryId);
    final payload = _responseList(response.data);
    return payload
        .map((item) => CatalogProductModel.fromJson(item).toEntity())
        .toList();
  }

  @override
  Future<void> addCategory({
    required String name,
    required String arabicName,
    required File image,
  }) async {
    await _remoteDataSource.addCategory(
      name: name,
      arabicName: arabicName,
      image: image,
    );
  }

  @override
  Future<void> updateCategory({
    required int id,
    required String name,
    required String arabicName,
    File? image,
  }) async {
    await _remoteDataSource.updateCategory(
      id: id,
      name: name,
      arabicName: arabicName,
      image: image,
    );
  }

  @override
  Future<void> deleteCategory(int id) async {
    await _remoteDataSource.deleteCategory(id);
  }

  @override
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
  }) async {
    await _remoteDataSource.addProduct(
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

  @override
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
  }) async {
    await _remoteDataSource.updateProduct(
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

  @override
  Future<void> deleteProduct(int id) async {
    await _remoteDataSource.deleteProduct(id);
  }

  List<Map<String, dynamic>> _responseList(dynamic response) {
    dynamic decoded = response;
    if (response is String) {
      var json = response.trimLeft();
      while (json.startsWith('\uFEFF')) {
        json = json.substring(1).trimLeft();
      }
      decoded = jsonDecode(json);
    }

    final payload = decoded is List
        ? decoded
        : decoded is Map
        ? decoded['data']
        : null;
    if (payload is! List) {
      throw const FormatException('The server response is invalid.');
    }
    return payload.map((item) {
      if (item is! Map) {
        throw const FormatException(
          'The server response contains an invalid item.',
        );
      }
      return Map<String, dynamic>.from(item);
    }).toList();
  }
}
