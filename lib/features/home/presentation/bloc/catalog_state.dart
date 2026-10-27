import '../../domain/entities/catalog_entities.dart';

class CatalogState {
  const CatalogState({
    this.categories = const [],
    this.products = const [],
    this.categoriesLoading = false,
    this.productsLoading = false,
    this.operationLoading = false,
    this.categoryImageRevision = 0,
    this.productImageRevision = 0,
    this.categoriesError,
    this.productsError,
  });

  final List<CatalogCategory> categories;
  final List<CatalogProduct> products;
  final bool categoriesLoading;
  final bool productsLoading;
  final bool operationLoading;
  final int categoryImageRevision;
  final int productImageRevision;
  final String? categoriesError;
  final String? productsError;

  CatalogState copyWith({
    List<CatalogCategory>? categories,
    List<CatalogProduct>? products,
    bool? categoriesLoading,
    bool? productsLoading,
    bool? operationLoading,
    int? categoryImageRevision,
    int? productImageRevision,
    String? categoriesError,
    String? productsError,
    bool clearCategoriesError = false,
    bool clearProductsError = false,
  }) {
    return CatalogState(
      categories: categories ?? this.categories,
      products: products ?? this.products,
      categoriesLoading: categoriesLoading ?? this.categoriesLoading,
      productsLoading: productsLoading ?? this.productsLoading,
      operationLoading: operationLoading ?? this.operationLoading,
      categoryImageRevision:
          categoryImageRevision ?? this.categoryImageRevision,
      productImageRevision: productImageRevision ?? this.productImageRevision,
      categoriesError: clearCategoriesError
          ? null
          : categoriesError ?? this.categoriesError,
      productsError: clearProductsError
          ? null
          : productsError ?? this.productsError,
    );
  }
}
