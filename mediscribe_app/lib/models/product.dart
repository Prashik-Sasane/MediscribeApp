class Product {
  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.mrp,
    required this.imageUrl,
    required this.tags,
    required this.requiresPrescription,
    this.description = '',
    this.manufacturer = '',
    this.stock = 0,
  });

  final String id;
  final String name;
  final String category;
  final int price;
  final int mrp;
  final String imageUrl;
  final List<String> tags;
  final bool requiresPrescription;
  final String description;
  final String manufacturer;
  final int stock;

  double get discount => mrp > 0 ? ((mrp - price) / mrp * 100) : 0;

  static int _parseInt(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      price: _parseInt(json['price']),
      mrp: _parseInt(json['mrp']),
      imageUrl: (json['imageUrl'] ?? '').toString(),
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          (json['tags'] != null ? [json['tags'].toString()] : []),
      requiresPrescription: _parseBool(json['requiresPrescription']),
      description: (json['description'] ?? '').toString(),
      manufacturer: (json['manufacturer'] ?? '').toString(),
      stock: _parseInt(json['stock']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'mrp': mrp,
      'imageUrl': imageUrl,
      'tags': tags,
      'requiresPrescription': requiresPrescription,
      'description': description,
      'manufacturer': manufacturer,
      'stock': stock,
    };
  }
}

