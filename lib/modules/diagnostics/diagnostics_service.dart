import 'package:sparein_mobile/core/network/api_client.dart';
import 'package:sparein_mobile/modules/diagnostics/models/symptom.dart';

/// Pemanggilan web service Django REST Framework untuk modul M2 Diagnostics.
class DiagnosticsService {
  DiagnosticsService({ApiClient? api}) : _api = api ?? ApiClient();

  static const symptomsPath = '/api/v1/symptoms/';

  final ApiClient _api;

  /// Daftar gejala. `device` (slug perangkat) dan `severity` kosong tidak dikirim.
  Future<List<Symptom>> fetchSymptoms({
    String? device,
    String? severity,
  }) async {
    final query = <String, String>{
      if (device != null && device.isNotEmpty) 'device': device,
      if (severity != null && severity.isNotEmpty) 'severity': severity,
    };
    final data = await _api.getJson(
      symptomsPath,
      query: query.isEmpty ? null : query,
    );
    // Terima list biasa maupun respons pagination DRF ({"results": [...]}).
    final items = data is Map<String, dynamic> ? data['results'] : data;
    if (items is! List) {
      throw const FormatException('Respons daftar gejala tidak valid');
    }
    return items
        .whereType<Map<String, dynamic>>()
        .map(Symptom.fromJson)
        .toList();
  }
}
