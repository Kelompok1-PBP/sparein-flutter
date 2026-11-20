/// Model data modul M4 Parts, dipetakan dari JSON endpoint `/api/v1/parts/`.
///
/// Harga dan kontak penjual cuma dikirim untuk member, jadi field-nya nullable.
library;

/// Kategori suku cadang, sama dengan `SparePart.Category` di Django.
const Map<String, String> partCategories = {
  'battery': 'Baterai',
  'screen': 'Layar',
  'charger': 'Charger',
  'cable': 'Kabel',
  'motor': 'Motor',
  'other': 'Lainnya',
};

String _str(Object? value) => value is String ? value : '';

int? _int(Object? value) => value is num ? value.toInt() : null;

List<Map<String, dynamic>> _list(Object? value) =>
    value is List ? value.whereType<Map<String, dynamic>>().toList() : const [];

class Part {
  const Part({
    required this.id,
    required this.name,
    required this.slug,
    required this.partNumber,
    required this.category,
    required this.categoryLabel,
    required this.imageUrl,
    required this.sourceCount,
    this.lowestPrice,
    this.highestPrice,
    this.description = '',
    this.compatibilities = const [],
    this.sources = const [],
  });

  factory Part.fromJson(Map<String, dynamic> json) {
    final category = _str(json['category']);
    final label = _str(json['category_label']);
    final sources = _list(json['sources']).map(PartSource.fromJson).toList();
    return Part(
      id: _int(json['id']) ?? 0,
      name: _str(json['name']),
      slug: _str(json['slug']),
      partNumber: _str(json['part_number']),
      category: category,
      categoryLabel: label.isNotEmpty
          ? label
          : partCategories[category] ?? category,
      imageUrl: _str(json['image_url']),
      sourceCount: _int(json['source_count']) ?? sources.length,
      lowestPrice: _int(json['lowest_price']),
      highestPrice: _int(json['highest_price']),
      description: _str(json['description']),
      compatibilities: _list(json['compatibilities'])
          .map(PartCompatibility.fromJson)
          .toList(),
      sources: sources,
    );
  }

  final int id;
  final String name;
  final String slug;
  final String partNumber;
  final String category;
  final String categoryLabel;
  final String imageUrl;
  final int sourceCount;

  /// Null kalau pengguna bukan member atau belum ada toko.
  final int? lowestPrice;
  final int? highestPrice;

  /// Tiga field di bawah cuma terisi di respons detail.
  final String description;
  final List<PartCompatibility> compatibilities;
  final List<PartSource> sources;
}

class PartCompatibility {
  const PartCompatibility({
    required this.deviceName,
    required this.deviceSlug,
    required this.note,
  });

  factory PartCompatibility.fromJson(Map<String, dynamic> json) {
    final slug = _str(json['device_slug']);
    final name = _str(json['device_name']);
    return PartCompatibility(
      deviceName: name.isNotEmpty ? name : slug,
      deviceSlug: slug,
      note: _str(json['note']),
    );
  }

  final String deviceName;
  final String deviceSlug;
  final String note;
}

class PartSource {
  const PartSource({
    required this.vendorName,
    required this.city,
    required this.url,
    this.lastChecked,
    this.price,
    this.currency,
    this.contact,
  });

  factory PartSource.fromJson(Map<String, dynamic> json) {
    final contact = json['contact'];
    return PartSource(
      vendorName: _str(json['vendor_name']),
      city: _str(json['city']),
      url: _str(json['url']),
      lastChecked: DateTime.tryParse(_str(json['last_checked'])),
      price: _int(json['price']),
      currency: json['currency'] is String ? json['currency'] as String : null,
      contact: contact is String ? contact : null,
    );
  }

  final String vendorName;
  final String city;
  final String url;
  final DateTime? lastChecked;

  /// Harga, mata uang, dan kontak cuma ada untuk member.
  final int? price;
  final String? currency;
  final String? contact;
}
