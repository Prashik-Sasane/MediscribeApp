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

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      price: (json['price'] as num?)?.toInt() ?? 0,
      mrp: (json['mrp'] as num?)?.toInt() ?? 0,
      imageUrl: (json['imageUrl'] ?? '').toString(),
      tags: (json['tags'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      requiresPrescription: (json['requiresPrescription'] as bool?) ?? false,
      description: (json['description'] ?? '').toString(),
      manufacturer: (json['manufacturer'] ?? '').toString(),
      stock: (json['stock'] as num?)?.toInt() ?? 0,
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

