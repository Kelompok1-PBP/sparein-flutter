import 'package:sparein_mobile/core/network/api_client.dart';
import 'package:sparein_mobile/modules/parts/models/part.dart';

/// Pemanggilan web service Django REST Framework untuk modul M4 Parts.
class PartsService {
  PartsService({ApiClient? api}) : _api = api ?? ApiClient();

  static const path = '/api/v1/parts/';

  final ApiClient _api;

  /// Daftar suku cadang. Filter yang kosong tidak dikirim.
  Future<List<Part>> fetchParts({String? q, String? category}) async {
    final query = <String, String>{
      if (q != null && q.trim().isNotEmpty) 'q': q.trim(),
      if (category != null && category.isNotEmpty) 'category': category,
    };
    final data = await _api.getJson(path, query: query.isEmpty ? null : query);
    // Terima list biasa maupun respons pagination DRF ({"results": [...]}).
    final items = data is Map<String, dynamic> ? data['results'] : data;
    if (items is! List) {
      throw const FormatException('Respons daftar suku cadang tidak valid');
    }
    return items.whereType<Map<String, dynamic>>().map(Part.fromJson).toList();
  }

  /// Detail satu suku cadang berdasarkan slug.
  Future<Part> fetchPart(String slug) async {
    final data = await _api.getJson('$path$slug/');
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Respons detail suku cadang tidak valid');
    }
    return Part.fromJson(data);
  }
}
