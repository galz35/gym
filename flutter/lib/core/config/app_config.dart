/// Central configuration for the GymPro app.
class AppConfig {
  AppConfig._();

  // ── API ────────────────────────────────────────────────────
  /// Change this to your backend URL.
  /// For Android emulator use 10.0.2.2 ; for physical device use your LAN IP.
  static const String apiBaseUrl = 'https://gym-fxzy.onrender.com';
  static const String defaultEmpresaId = 'b741a91f-47b0-4963-a65a-94b77cbc9b94';

  /// Supabase project URL (for storage / realtime if needed).
  static const String supabaseUrl = 'https://ayyotvvjcwdoocdcouao.supabase.co';
  static const String supabaseAnonKey =
      'sb_publishable_FTkK-bXjQGTFqgfaV0qaSQ_z_HZnW-C';

  // ── Timeouts ───────────────────────────────────────────────
  static const Duration connectTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout = Duration(seconds: 60);

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
