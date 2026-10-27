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
      id: _intValue(json, const ['category_id', 'id']),
      name: _stringValue(json, const ['category_name', 'name', 'category_name_en']),
      arabicName: _stringValue(json, const ['category_name_ar', 'name_ar']),
      image: _imageValue(json),
      datetime: _stringValue(json, const ['category_datetime', 'created_at', 'date']),
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

  static int _intValue(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) continue;
      if (value is num) return value.toInt();

      final text = value.toString().trim();
      if (text.isEmpty || text.toLowerCase() == 'null') continue;

      final parsed = int.tryParse(text);
      if (parsed != null) return parsed;
    }
    return 0;
  }

  static String _stringValue(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) continue;

      final text = value.toString().trim();
      if (text.isEmpty || text.toLowerCase() == 'null') continue;
      return text;
    }
    return '';
  }

  static String? _imageValue(Map<String, dynamic> json) {
    for (final key in const ['category_image', 'image_url', 'image']) {
      final value = json[key];
      if (value == null) continue;

      final trimmed = value.toString().trim();
      if (trimmed.isNotEmpty && trimmed.toLowerCase() != 'null') return trimmed;
    }
    return null;
  }
}
