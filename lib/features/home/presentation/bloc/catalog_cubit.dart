import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/catalog_repository.dart';
import 'catalog_state.dart';

class CatalogCubit extends Cubit<CatalogState> {
  CatalogCubit(this._repository)
    : super(
        CatalogState(
          productImageRevision: DateTime.now().microsecondsSinceEpoch,
        ),
      );

  final CatalogRepository _repository;

  Future<void> loadCategories() async {
    emit(state.copyWith(categoriesLoading: true, clearCategoriesError: true));
    try {
      final categories = await _repository.getCategories();
      emit(state.copyWith(categories: categories, categoriesLoading: false));
    } catch (error) {
      emit(
        state.copyWith(
          categoriesLoading: false,
          categoriesError: error.toString(),
        ),
      );
    }
  }

  Future<void> loadProducts(int categoryId) async {
    emit(state.copyWith(productsLoading: true, clearProductsError: true));
    try {
      final products = await _repository.getProducts(categoryId);
      emit(state.copyWith(products: products, productsLoading: false));
    } catch (error) {
      emit(
        state.copyWith(productsLoading: false, productsError: error.toString()),
      );
    }
  }

  Future<void> addCategory({
    required String name,
    required String arabicName,
    required File image,
  }) async {
    await _runOperation(() async {
      await _repository.addCategory(
        name: name,
        arabicName: arabicName,
        image: image,
      );
      await loadCategories();
      emit(
        state.copyWith(categoryImageRevision: state.categoryImageRevision + 1),
      );
    });
  }

  Future<void> updateCategory({
    required int id,
    required String name,
    required String arabicName,
    File? image,
  }) async {
    await _runOperation(() async {
      await _repository.updateCategory(
        id: id,
        name: name,
        arabicName: arabicName,
        image: image,
      );
      await loadCategories();
      if (image != null) {
        emit(
          state.copyWith(
            categoryImageRevision: state.categoryImageRevision + 1,
          ),
        );
      }
    });
  }

  Future<void> deleteCategory(int id) async {
    await _runOperation(() async {
      await _repository.deleteCategory(id);
      await loadCategories();
    });
  }

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
    await _runOperation(() async {
      await _repository.addProduct(
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
      await loadProducts(categoryId);
    });
  }

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
    await _runOperation(() async {
      await _repository.updateProduct(
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
      await loadProducts(categoryId);
      if (image != null) {
        emit(
          state.copyWith(productImageRevision: state.productImageRevision + 1),
        );
      }
    });
  }

  Future<void> deleteProduct(int id, int categoryId) async {
    await _runOperation(() async {
      await _repository.deleteProduct(id);
      await loadProducts(categoryId);
    });
  }

  Future<void> _runOperation(Future<void> Function() action) async {
    emit(state.copyWith(operationLoading: true));
    try {
      await action();
      emit(state.copyWith(operationLoading: false));
    } catch (_) {
      emit(state.copyWith(operationLoading: false));
      rethrow;
    }
  }
}
