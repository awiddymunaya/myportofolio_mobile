/// Base URL backend Django REST Framework.
///
/// Default-nya `http://10.0.2.2:8000`, yaitu alamat komputer kita jika
/// dipanggil dari emulator Android.
/// Ganti lewat `--dart-define=API_BASE_URL=http://localhost:8000` saat
/// menjalankan di browser (web) atau macOS.
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:8000',
);
