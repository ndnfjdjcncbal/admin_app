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
      id: _intValue(json, const ['items_id', 'item_id', 'id']),
      name: _stringValue(json, const ['items_name', 'item_name', 'name']),
      arabicName: _stringValue(json, const ['itemname_AR', 'item_name_ar', 'name_ar']),
      price: _stringValue(json, const ['items_price', 'price', 'item_price']),
      categoryId: _intValue(json, const ['items_categort', 'category_id', 'item_category_id']),
      image: _nullableStringValue(json, const [
        'items_image',
        'item_image',
        'product_image',
        'image_url',
        'image',
      ]),
      description: _stringValue(json, const ['items_desc', 'description', 'item_description']),
      arabicDescription: _stringValue(json, const ['items_descAr', 'description_ar', 'item_description_ar']),
      count: _intValue(json, const ['itemscolor_quantity', 'items_count', 'count', 'quantity']),
      color: _stringValue(json, const ['namecolor_en', 'items_color', 'color', 'item_color']),
      arabicColor: _stringValue(json, const ['namecolor_ar', 'items_colorar', 'color_ar', 'arabic_color']),
      location: _stringValue(json, const ['itemscolor_locationen', 'items_location', 'location', 'item_location']),
      arabicLocation: _stringValue(json, const ['itemscolor_locationar', 'items_locationar', 'location_ar', 'arabic_location']),
      colorVariantId: _intValue(json, const ['itemscolor_id', 'color_variant_id', 'id']),
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
      if (value == null) continue;
      if (value is num) return value.toInt();

      final text = value.toString().trim();
      if (text.isEmpty || text.toLowerCase() == 'null') continue;

      final parsed = int.tryParse(text);
      if (parsed != null) return parsed;

      final number = num.tryParse(text);
      if (number != null) return number.toInt();
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

  static String? _nullableStringValue(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) continue;

      final text = value.toString().trim();
      if (text.isEmpty || text.toLowerCase() == 'null') continue;
      return text;
    }
    return null;
  }
}
