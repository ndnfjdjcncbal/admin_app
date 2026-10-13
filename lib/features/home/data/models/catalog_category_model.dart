import '../../domain/entities/catalog_entities.dart';

class CatalogCategoryModel extends CatalogCategory {
  const CatalogCategoryModel({
    required super.datetime,
    required super.id,
    required super.name,
    required super.arabicName,
    super.image,
  });

  factory CatalogCategoryModel.fromJson(Map<String, dynamic> json) {
    return CatalogCategoryModel(
      id: int.tryParse(json['category_id']?.toString() ?? '') ?? 0,
      name: json['category_name']?.toString() ?? '',
      arabicName: json['category_name_ar']?.toString() ?? '',
      image: json['category_image']?.toString(),
      datetime: '${json['category_datetime']?.toString() ?? ''}',
    );
  }

  factory CatalogCategoryModel.fromEntity(CatalogCategory category) {
    return CatalogCategoryModel(
      id: category.id,
      name: category.name,
      arabicName: category.arabicName,
      image: category.image,
      datetime: category.datetime,
    );
  }

  CatalogCategory toEntity() {
    return CatalogCategory(
      datetime: datetime,
      id: id,
      name: name,
      arabicName: arabicName,
      image: image,
    );
  }
}
