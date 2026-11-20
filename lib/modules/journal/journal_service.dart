import 'package:sparein_mobile/core/network/api_client.dart';
import 'package:sparein_mobile/modules/journal/models/impact_summary.dart';

/// Pemanggilan web service Django REST Framework untuk modul M5 Journal.
class JournalService {
  JournalService({ApiClient? api}) : _api = api ?? ApiClient();

  static const summaryPath = '/api/v1/journal/summary/';

  final ApiClient _api;

  /// Counter dampak situs. Terbuka untuk visitor, member mendapat dampak pribadinya juga.
  Future<JournalSummary> fetchSummary() async {
    final data = await _api.getJson(summaryPath);
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Respons ringkasan jurnal tidak valid');
    }
    return JournalSummary.fromJson(data);
  }
}
