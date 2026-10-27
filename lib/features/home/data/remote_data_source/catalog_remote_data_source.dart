import 'dart:io';

import 'package:adminapp/core/constants/api_client/link_api.dart';
import 'package:adminapp/core/network/api_consumer.dart';
import 'package:adminapp/core/services/Mysevice.dart';
import 'package:dio/dio.dart';

class CatalogRemoteDataSource {
  CatalogRemoteDataSource(this._api, this._myService);

  final ApiConsumer _api;
  final Myservice _myService;

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
  }) async {
    final values = <String, dynamic>{
      'category_name': name,
      'category_name_ar': arabicName,
      'category_image': await MultipartFile.fromFile(
        image.path,
        filename: image.path.split(Platform.pathSeparator).last,
      ),
      'user_id': _requireUserId(),
    };
    return _api.post(ApiConstants.addcategory, data: FormData.fromMap(values));
  }

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
      if (!await image.exists()) {
        throw const FormatException(
          'The selected category image is unavailable.',
        );
      }
      values['category_image'] = await MultipartFile.fromFile(
        image.path,
        filename: image.path.split(Platform.pathSeparator).last,
      );
    }
    return _api.post(ApiConstants.editcategory, data: FormData.fromMap(values));
  }

  Future<Response> deleteCategory(int id) => _api.post(
    ApiConstants.deletecategory,
    data: FormData.fromMap({'category_id': id, 'user_id': _requireUserId()}),
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
    )..['itemscolor_id'] = id;
    if (image != null) {
      if (!await image.exists()) {
        throw const FormatException(
          'The selected product image is unavailable.',
        );
      }
      values['items_image'] = await MultipartFile.fromFile(
        image.path,
        filename: image.path.split(Platform.pathSeparator).last,
      );
    }
    return _api.post(ApiConstants.editproduct, data: FormData.fromMap(values));
  }

  Future<Response> deleteProduct(int variationId) => _api.post(
    ApiConstants.deleteproduct,
    data: FormData.fromMap({
      'itemscolor_id': variationId,
      'user_id': _requireUserId(),
    }),
  );

  String _requireUserId() {
    final userId = _myService.sharedPreferences.getString('user_id');
    if (userId == null || userId.isEmpty) {
      throw StateError('You must log in before deleting catalog items.');
    }
    return userId;
  }

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
      'namecolor_en': color,
      'namecolor_ar': arabicColor,
      'itemscolor_quantity': count,
      'itemscolor_locationen': location,
      'itemscolor_locationar': arabicLocation,
    };
  }
}
