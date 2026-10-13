import 'dart:io';

import 'package:adminapp/core/constants/api_client/link_api.dart';
import 'package:adminapp/core/network/api_consumer.dart';
import 'package:dio/dio.dart';

class CatalogRemoteDataSource {
  CatalogRemoteDataSource(this._api);

  final ApiConsumer _api;

  Future<Response> getCategories() => _api.get(
    ApiConstants.getcategory,
    options: Options(responseType: ResponseType.plain),
  );

  Future<Response> getProductsForCategory(int categoryId) => _api.post(
    ApiConstants.getitemsforcategoty,
    data: FormData.fromMap({'category_id': categoryId}),
    options: Options(responseType: ResponseType.plain),
  );

  Future<Response> addCategory({
    required String name,
    required String arabicName,
    required File image,
  }) => _api.post(
    ApiConstants.addcategory,
    data: FormData.fromMap({
      'category_name': name,
      'category_name_ar': arabicName,
      'category_image': MultipartFile.fromFile(image.path),
    }),
  );

  Future<Response> updateCategory({
    required int id,
    required String name,
    required String arabicName,
    File? image,
  }) async {
    final values = <String, dynamic>{
      'category_id': id,
      'category_name': name,
      'category_name_ar': arabicName,
    };
    if (image != null) {
      values['category_image'] = await MultipartFile.fromFile(image.path);
    }
    return _api.post(ApiConstants.editcategory, data: FormData.fromMap(values));
  }

  Future<Response> deleteCategory(int id) => _api.post(
    ApiConstants.deletecategory,
    data: FormData.fromMap({'category_id': id}),
  );

  Future<Response> addProduct({
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
    final values = _productValues(
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
    );
    values['items_image'] = await MultipartFile.fromFile(image.path);
    return _api.post(ApiConstants.addproduct, data: FormData.fromMap(values));
  }

  Future<Response> updateProduct({
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
    final values = _productValues(
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
    )..['items_id'] = id;
    if (image != null) {
      values['items_image'] = await MultipartFile.fromFile(image.path);
    }
    return _api.post(ApiConstants.editproduct, data: FormData.fromMap(values));
  }

  Future<Response> deleteProduct(int id) => _api.post(
    ApiConstants.deleteproduct,
    data: FormData.fromMap({'items_id': id}),
  );

  Map<String, dynamic> _productValues({
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
  }) {
    return {
      'items_name': name,
      'itemname_AR': arabicName,
      'items_price': price,
      'items_categort': categoryId,
      'items_desc': description,
      'items_descAr': arabicDescription,
      'items_count': count,
      'items_color': color,
      'items_colorar': arabicColor,
      'items_location': location,
      'items_locationar': arabicLocation,
    };
  }
}
