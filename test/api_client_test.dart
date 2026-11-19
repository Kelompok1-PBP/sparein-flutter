import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sparein_mobile/core/network/api_client.dart';

void main() {
  test('getJson menggabungkan base url, query, dan decode JSON', () async {
    late Uri called;
    final api = ApiClient(
      baseUrl: 'http://host',
      client: MockClient((request) async {
        called = request.url;
        return http.Response('{"count": 1}', 200);
      }),
    );
    final data = await api.getJson('/api/v1/devices/', query: {'q': 'iphone'});
    expect(called.toString(), 'http://host/api/v1/devices/?q=iphone');
    expect(data['count'], 1);
  });

  test('status di luar 2xx dilempar sebagai ApiException', () async {
    final api = ApiClient(
      baseUrl: 'http://host',
      client: MockClient((_) async => http.Response('', 404)),
    );
    expect(
      () => api.getJson('/api/v1/devices/x/'),
      throwsA(isA<ApiException>()),
    );
  });
}
