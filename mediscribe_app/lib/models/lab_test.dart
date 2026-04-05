class LabTest {
  LabTest({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.tags,
  });

  final String id;
  final String name;
  final String category;
  final int price;
  final String description;
  final String imageUrl;
  final List<String> tags;

  factory LabTest.fromJson(Map<String, dynamic> json) {
    return LabTest(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      price: (json['price'] as num?)?.toInt() ?? 0,
      description: (json['description'] ?? '').toString(),
      imageUrl: (json['imageUrl'] ?? '').toString(),
      tags: (json['tags'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
    );
  }
}

