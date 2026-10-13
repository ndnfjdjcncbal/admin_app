class CatalogCategory {
  const CatalogCategory({
    required this.id,
    required this.name,
    required this.arabicName,
    this.image,
    required this.datetime,
  });

  final int id;
  final String name;
  final String arabicName;
  final String? image;
  final String datetime;
}

class CatalogProduct {
  const CatalogProduct({
    required this.id,
    required this.name,
    required this.arabicName,
    required this.price,
    required this.categoryId,
    this.image,
    this.description = '',
    this.arabicDescription = '',
    this.count = 0,
    this.color = '',
    this.arabicColor = '',
    this.location = '',
    this.arabicLocation = '',
    this.colorVariantId = 0,
  });

  final int id;
  final String name;
  final String arabicName;
  final String price;
  final int categoryId;
  final String? image;
  final String description;
  final String arabicDescription;
  final int count;
  final String color;
  final String arabicColor;
  final String location;
  final String arabicLocation;
  final int colorVariantId;
}
