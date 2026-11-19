/// Konfigurasi endpoint web service Django (proyek `sparein`).
///
/// Override saat run/build tanpa mengubah kode:
///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
class ApiConfig {
  const ApiConfig._();

  /// 10.0.2.2 = localhost komputer host dari emulator Android.
  /// Ganti default ke URL PWS produksi setelah deploy.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );
}
