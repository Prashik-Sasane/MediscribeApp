class LabTest {
  LabTest({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.tags,
    this.parametersCount = 1,
    this.isHomeCollectionAvailable = true,
    this.requiresFasting = false,
    this.reportTime = '24 hours',
  });

  final String id;
  final String name;
  final String category;
  final int price;
  final String description;
  final String imageUrl;
  final List<String> tags;
  final int parametersCount;
  final bool isHomeCollectionAvailable;
  final bool requiresFasting;
  final String reportTime;

  factory LabTest.fromJson(Map<String, dynamic> json) {
    return LabTest(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      price: (json['price'] as num?)?.toInt() ?? 0,
      description: (json['description'] ?? '').toString(),
      imageUrl: (json['imageUrl'] ?? '').toString(),
      tags: (json['tags'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      parametersCount: (json['parametersCount'] as num?)?.toInt() ?? 1,
      isHomeCollectionAvailable: (json['isHomeCollectionAvailable'] as bool?) ?? true,
      requiresFasting: (json['requiresFasting'] as bool?) ?? false,
      reportTime: (json['reportTime'] ?? '24 hours').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'tags': tags,
      'parametersCount': parametersCount,
      'isHomeCollectionAvailable': isHomeCollectionAvailable,
      'requiresFasting': requiresFasting,
      'reportTime': reportTime,
    };
  }
}

