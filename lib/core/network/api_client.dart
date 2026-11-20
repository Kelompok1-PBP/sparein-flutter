import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sparein_mobile/core/config/api_config.dart';

class ApiException implements Exception {
  const ApiException(this.statusCode, this.path);

  final int statusCode;
  final String path;

  @override
  String toString() => 'ApiException($statusCode, $path)';
}

/// Satu pintu untuk memanggil web service Django REST Framework.
class ApiClient {
  ApiClient({http.Client? client, this.baseUrl = ApiConfig.baseUrl})
    : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;

  /// GET [path] (misal `/api/v1/devices/`) lalu decode body JSON.
  Future<dynamic> getJson(String path, {Map<String, String>? query}) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
    final response = await _client.get(
      uri,
      headers: {'Accept': 'application/json'},
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(response.statusCode, path);
    }
    return jsonDecode(utf8.decode(response.bodyBytes));
  }
}
