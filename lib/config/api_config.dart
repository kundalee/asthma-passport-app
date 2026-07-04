import 'package:flutter/services.dart' show appFlavor;

// Environment is picked up from the Flutter build flavor, e.g.:
//   flutter run --flavor staging
//   flutter build apk --flavor staging
//   flutter build ipa --flavor staging
// Defaults to prod when no flavor is set (e.g. flutter test).
class ApiConfig {
  static final String _env = appFlavor ?? 'prod';

  static const String _prodBaseUrl = 'https://asthma.itroll.com.tw';
  static const String _stagingBaseUrl = 'https://asthma.itroll.com.tw';

  static String get baseUrl => _env == 'staging' ? _stagingBaseUrl : _prodBaseUrl;
}
