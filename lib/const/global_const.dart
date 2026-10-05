class GlobalConst {
  static const String appName = "Hotmul Quran";
  static const String appVersion = "1.0.0";
  static const String developerName = "Eris Taufiq H";

  /// Base URL API (tanpa `/api`). Bisa diganti saat build/run:
  /// `flutter run --dart-define=API_URL=http://localhost:8016`
  static const String url = String.fromEnvironment(
    'API_URL',
    defaultValue: "https://hotmul.pusaka-ilahi.com",
  );

  /// Prefix endpoint API versi 1 (hotmul_api: routes/api.php).
  static const String apiV1 = "$url/api/v1";

  /// Aturan bisnis dari README (BRD/SRS).
  static const int maxAnggotaPerGroup = 30;
  static const int totalJuz = 30;
  static const int hariPerPeriode = 14;
}
