import 'dart:convert';

import 'package:adminapp/core/network/api_consumer.dart';
import 'package:adminapp/features/home/data/models/catalog_category_model.dart';
import 'package:adminapp/features/home/data/models/catalog_product_model.dart';
import 'package:adminapp/features/home/data/remote_data_source/catalog_remote_data_source.dart';
import 'package:adminapp/features/home/data/repositories/catalog_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

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

    test('parses category list when the JSON response starts with BOM', () async {
      final repository = CatalogRepositoryImpl(
        _FakeCatalogRemoteDataSource(
          '\uFEFF\uFEFF${jsonEncode({
            'status': 'success',
            'data': [
              {'category_id': '7', 'category_name': 'Pant', 'category_name_ar': 'بنطلون', 'category_image': 'بنطلون.png', 'category_datetime': '2026-08-16 17:18:55'},
            ],
          })}',
        ),
      );

      final categories = await repository.getCategories();

      expect(categories, hasLength(1));
      expect(categories.single.id, 7);
      expect(categories.single.name, 'Pant');
    });

    test('parses product color and stock fields', () {
      final product = CatalogProductModel.fromJson({
        'itemscolor_id': '31',
        'namecolor_ar': 'ازرق فاتح',
        'namecolor_en': 'baby blue',
        'item_id': '3222',
        'item_image': 'uploads/products/pant.png',
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
      expect(product.image, 'uploads/products/pant.png');
      expect(product.toEntity().image, 'uploads/products/pant.png');
    });
  });
}

class _FakeCatalogRemoteDataSource extends CatalogRemoteDataSource {
  _FakeCatalogRemoteDataSource(this.responseData) : super(_FakeApiConsumer());

  final dynamic responseData;

  @override
  Future<Response> getCategories() async {
    return Response(
      requestOptions: RequestOptions(path: ''),
      data: responseData,
    );
  }
}

class _FakeApiConsumer implements ApiConsumer {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
