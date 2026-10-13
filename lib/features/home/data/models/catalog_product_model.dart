import '../../domain/entities/catalog_entities.dart';

class CatalogProductModel extends CatalogProduct {
  const CatalogProductModel({
    required super.id,
    required super.name,
    required super.arabicName,
    required super.price,
    required super.categoryId,
    super.image,
    super.description,
    super.arabicDescription,
    super.count,
    super.color,
    super.arabicColor,
    super.location,
    super.arabicLocation,
    super.colorVariantId,
  });

  factory CatalogProductModel.fromJson(Map<String, dynamic> json) {
    return CatalogProductModel(
      id: _intValue(json, const ['items_id', 'item_id']),
      name: json['items_name']?.toString() ?? '',
      arabicName: json['itemname_AR']?.toString() ?? '',
      price: json['items_price']?.toString() ?? '',
      categoryId: _intValue(json, const ['items_categort', 'category_id']),
      image: _nullableStringValue(json, const [
        'items_image',
        'item_image',
        'product_image',
        'image_url',
        'image',
      ]),
      description: json['items_desc']?.toString() ?? '',
      arabicDescription: json['items_descAr']?.toString() ?? '',
      count: _intValue(json, const ['itemscolor_quantity', 'items_count']),
      color: _stringValue(json, const ['namecolor_en', 'items_color']),
      arabicColor: _stringValue(json, const ['namecolor_ar', 'items_colorar']),
      location: _stringValue(json, const [
        'itemscolor_locationen',
        'items_location',
      ]),
      arabicLocation: _stringValue(json, const [
        'itemscolor_locationar',
        'items_locationar',
      ]),
      colorVariantId: _intValue(json, const ['itemscolor_id']),
    );
  }

  factory CatalogProductModel.fromEntity(CatalogProduct product) {
    return CatalogProductModel(
      id: product.id,
      name: product.name,
      arabicName: product.arabicName,
      price: product.price,
      categoryId: product.categoryId,
      image: product.image,
      description: product.description,
      arabicDescription: product.arabicDescription,
      count: product.count,
      color: product.color,
      arabicColor: product.arabicColor,
      location: product.location,
      arabicLocation: product.arabicLocation,
      colorVariantId: product.colorVariantId,
    );
  }

  CatalogProduct toEntity() {
    return CatalogProduct(
      id: id,
      name: name,
      arabicName: arabicName,
      price: price,
      categoryId: categoryId,
      image: image,
      description: description,
      arabicDescription: arabicDescription,
      count: count,
      color: color,
      arabicColor: arabicColor,
      location: location,
      arabicLocation: arabicLocation,
      colorVariantId: colorVariantId,
    );
  }

  static int _intValue(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      final parsed = int.tryParse(value?.toString() ?? '');
      if (parsed != null) return parsed;
    }
    return 0;
  }

  static String _stringValue(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value != null) return value.toString();
    }
    return '';
  }

  static String? _nullableStringValue(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = json[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }
}
