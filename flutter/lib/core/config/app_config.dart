/// Central configuration for the GymPro app.
class AppConfig {
  AppConfig._();

  // ── API ────────────────────────────────────────────────────
  /// Change this to your backend URL.
  /// For Android emulator use 10.0.2.2 ; for physical device use your LAN IP.
  static const String apiBaseUrl = 'http://10.0.2.2:3000';

  /// Supabase project URL (for storage / realtime if needed).
  static const String supabaseUrl = 'https://ddmeodlpdxgmadduwdas.supabase.co';

  // ── Timeouts ───────────────────────────────────────────────
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // ── Storage keys ───────────────────────────────────────────
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserJson = 'user_json';
  static const String keySucursalId = 'sucursal_id';
  static const String keyEmpresaId = 'empresa_id';
  static const String keyDeviceId = 'device_id';

  // ── Pagination defaults ────────────────────────────────────
  static const int defaultPageSize = 30;
}
