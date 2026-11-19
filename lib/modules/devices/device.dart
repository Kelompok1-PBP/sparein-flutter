class Device {
  const Device({
    required this.name,
    required this.slug,
    required this.brand,
    required this.category,
    required this.imageUrl,
  });

  factory Device.fromJson(Map<String, dynamic> json) => Device(
    name: json['name'] as String,
    slug: json['slug'] as String,
    brand: json['brand'] as String? ?? '',
    category: json['category_name'] as String? ?? '',
    imageUrl: json['image_url'] as String? ?? '',
  );

  final String name;
  final String slug;
  final String brand;
  final String category;
  final String imageUrl;
}
