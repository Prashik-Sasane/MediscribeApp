class Product {
  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.mrp,
    required this.imageUrl,
    required this.tags,
  });

  final String id;
  final String name;
  final String category;
  final int price;
  final int mrp;
  final String imageUrl;
  final List<String> tags;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      price: (json['price'] as num?)?.toInt() ?? 0,
      mrp: (json['mrp'] as num?)?.toInt() ?? 0,
      imageUrl: (json['imageUrl'] ?? '').toString(),
      tags: (json['tags'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
    );
  }
}

