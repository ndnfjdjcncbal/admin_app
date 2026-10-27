import 'dart:convert';
import 'dart:io';

import 'package:adminapp/core/network/api_consumer.dart';
import 'package:adminapp/core/services/Mysevice.dart';
import 'package:adminapp/features/home/data/models/catalog_category_model.dart';
import 'package:adminapp/features/home/data/models/catalog_product_model.dart';
import 'package:adminapp/features/home/data/remote_data_source/catalog_remote_data_source.dart';
import 'package:adminapp/features/home/data/repositories/catalog_repository_impl.dart';
import 'package:adminapp/features/home/presentation/bloc/catalog_cubit.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Catalog response parsing', () {
    test('parses category fields from the API response', () {
      final category = CatalogCategoryModel.fromJson({
        'category_id': '7',
        'category_image': 'بنطلون.png',
        'category_datetime': '2026-08-16 17:18:55',
        'category_name': 'Pant',
        'category_name_ar': 'بنطلون',
      });

      expect(category.id, 7);
      expect(category.name, 'Pant');
      expect(category.arabicName, 'بنطلون');
      expect(category.image, 'بنطلون.png');
      expect(category.datetime, '2026-08-16 17:18:55');
    });

    test('parses category image aliases and ignores null strings', () {
      final category = CatalogCategoryModel.fromJson({
        'category_id': '8',
        'category_image': 'null',
        'image_url': ' categories/shoes.png ',
        'category_datetime': '',
      });

      expect(category.image, 'categories/shoes.png');

      final categoryWithoutImage = CatalogCategoryModel.fromJson({
        'category_id': '9',
        'category_image': 'null',
        'image': '',
        'category_datetime': '',
      });
      expect(categoryWithoutImage.image, isNull);
    });

    test('refreshes category image URLs after adding a category', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final cubit = CatalogCubit(
        CatalogRepositoryImpl(
          _FakeCatalogRemoteDataSource(
            jsonEncode([
              {
                'category_id': '10',
                'category_name': 'New category',
                'category_name_ar': 'قسم جديد',
                'category_image': 'new-category.png',
              },
            ]),
            preferences,
          ),
        ),
      );

      await cubit.addCategory(
        name: 'New category',
        arabicName: 'قسم جديد',
        image: File('unused.png'),
      );

      expect(cubit.state.categories.single.image, 'new-category.png');
      expect(cubit.state.categoryImageRevision, 1);
      await cubit.close();
    });

    test('parses category list when the JSON response starts with BOM', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final repository = CatalogRepositoryImpl(
        _FakeCatalogRemoteDataSource(
          '\uFEFF\uFEFF${jsonEncode({
            'status': 'success',
            'data': [
              {'category_id': '7', 'category_name': 'Pant', 'category_name_ar': 'بنطلون', 'category_image': 'بنطلون.png', 'category_datetime': '2026-08-16 17:18:55'},
            ],
          })}',
          preferences,
        ),
      );

      final categories = await repository.getCategories();

      expect(categories, hasLength(1));
      expect(categories.single.id, 7);
      expect(categories.single.name, 'Pant');
    });

    test(
      'parses product images and nested list payloads when data is wrapped',
      () async {
        SharedPreferences.setMockInitialValues({});
        final preferences = await SharedPreferences.getInstance();
        final repository = CatalogRepositoryImpl(
          _FakeCatalogRemoteDataSource(
            jsonEncode({
              'status': 'success',
              'data': {
                'items': [
                  {
                    'item_id': '55',
                    'items_name': 'Shoes',
                    'item_image': 'null',
                    'image_url': '  products/shoes.png  ',
                    'itemscolor_quantity': '3',
                    'namecolor_en': 'null',
                  },
                ],
              },
            }),
            preferences,
          ),
        );

        final products = await repository.getProducts(1);

        expect(products, hasLength(1));
        expect(products.single.id, 55);
        expect(products.single.name, 'Shoes');
        expect(products.single.count, 3);
        expect(products.single.image, 'products/shoes.png');
        expect(products.single.color, isEmpty);
      },
    );

    test('parses product color and stock fields', () {
      final product = CatalogProductModel.fromJson({
        'itemscolor_id': '31',
        'namecolor_ar': 'ازرق فاتح',
        'namecolor_en': 'baby blue',
        'item_id': '3222',
        'items_image': 'pant.png',
        'itemscolor_quantity': '1',
        'itemscolor_locationar': 'New York',
        'itemscolor_locationen': 'New York',
        'items_categort': '2',
      });

      expect(product.id, 3222);
      expect(product.colorVariantId, 31);
      expect(product.color, 'baby blue');
      expect(product.arabicColor, 'ازرق فاتح');
      expect(product.count, 1);
      expect(product.categoryId, 2);
      expect(product.image, 'pant.png');
      expect(product.toEntity().image, 'pant.png');
    });
  });
}

class _FakeCatalogRemoteDataSource extends CatalogRemoteDataSource {
  _FakeCatalogRemoteDataSource(this.responseData, SharedPreferences preferences)
    : super(_FakeApiConsumer(), Myservice(sharedPreferences: preferences));

  final dynamic responseData;

  @override
  Future<Response> getCategories() async {
    return Response(
      requestOptions: RequestOptions(path: ''),
      data: responseData,
    );
  }

  @override
  Future<Response> getProductsForCategory(int categoryId) async {
    return Response(
      requestOptions: RequestOptions(path: ''),
      data: responseData,
    );
  }

  @override
  Future<Response> addCategory({
    required String name,
    required String arabicName,
    required File image,
  }) async {
    return Response(
      requestOptions: RequestOptions(path: ''),
      data: '{}',
    );
  }
}

class _FakeApiConsumer implements ApiConsumer {
  @override
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return Response(
      requestOptions: RequestOptions(path: path),
      data: '{}',
    );
  }

  @override
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return Response(
      requestOptions: RequestOptions(path: path),
      data: '{}',
    );
  }

  @override
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return Response(
      requestOptions: RequestOptions(path: path),
      data: '{}',
    );
  }

  @override
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return Response(
      requestOptions: RequestOptions(path: path),
      data: '{}',
    );
  }

  @override
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return Response(
      requestOptions: RequestOptions(path: path),
      data: '{}',
    );
  }
}
