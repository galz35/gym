import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/models.dart';
import '../services/api_service.dart';

/// Authentication provider — manages login, logout, token persistence,
/// and exposes the current [UserProfile] and selected [Sucursal].
class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  final FlutterSecureStorage _secure = const FlutterSecureStorage();

  UserProfile? _user;
  Sucursal? _selectedSucursal;
  bool _isLoading = true;
  String? _error;

  // ── Getters ────────────────────────────────────────────────
  UserProfile? get user => _user;
  Sucursal? get selectedSucursal => _selectedSucursal;
  bool get isAuthenticated => _user != null && _api.hasToken;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get empresaId => _user?.empresaId ?? '';
  String get sucursalId => _selectedSucursal?.id ?? '';
  String get userId => _user?.id ?? '';
  String get userName => _user?.nombre ?? '';

  // ── Bootstrap ──────────────────────────────────────────────
  /// Called once at app start to try to restore a previous session.
  Future<void> tryAutoLogin() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _secure.read(key: AppConfig.keyAccessToken);
      if (token == null || token.isEmpty) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      _api.setToken(token);

      // Validate by calling the profile endpoint
      final profileJson = await _api.get('/auth/profile');
      _user = UserProfile.fromJson(profileJson);
      _api.setEmpresaId(_user!.empresaId);

      // Restore saved sucursal
      final prefs = await SharedPreferences.getInstance();
      final savedSucursalId = prefs.getString(AppConfig.keySucursalId);
      if (_user!.sucursales.isNotEmpty) {
        _selectedSucursal = _user!.sucursales.firstWhere(
          (s) => s.id == savedSucursalId,
          orElse: () => _user!.sucursales.first,
        );
        _api.setSucursalId(_selectedSucursal?.id);
      }
    } on ApiException catch (e) {
      // Token expired or invalid → clear
      if (e.isUnauthorized) {
        await _clearSession();
      }
    } catch (_) {
      // Network error → leave as not authenticated for now
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Login ──────────────────────────────────────────────────
  Future<bool> login(
    String email,
    String password, {
    required String empresaId,
    String? deviceId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final body = {
        'email': email,
        'password': password,
        'empresaId': empresaId,
      };
      if (deviceId != null) {
        body['deviceId'] = deviceId;
      }

      final json = await _api.post('/auth/login', body: body);

      final auth = AuthResponse.fromJson(json);
      _api.setToken(auth.accessToken);

      // Persist tokens
      await _secure.write(
        key: AppConfig.keyAccessToken,
        value: auth.accessToken,
      );
      if (auth.refreshToken != null) {
        await _secure.write(
          key: AppConfig.keyRefreshToken,
          value: auth.refreshToken,
        );
      }

      _user = auth.user;
      _api.setEmpresaId(_user!.empresaId);

      // Default to first sucursal
      if (_user!.sucursales.isNotEmpty) {
        _selectedSucursal = _user!.sucursales.first;
        _api.setSucursalId(_selectedSucursal?.id);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConfig.keySucursalId, _selectedSucursal!.id);
      }

      _error = null;
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'Error de conexión. Verifica tu red.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Logout ─────────────────────────────────────────────────
  Future<void> logout() async {
    try {
      if (_api.hasToken) {
        await _api.post('/auth/logout');
      }
    } catch (_) {
      // Ignore errors on logout
    }
    await _clearSession();
    notifyListeners();
  }

  Future<void> _clearSession() async {
    _api.setToken(null);
    _api.setSucursalId(null);
    _api.setEmpresaId(null);
    _user = null;
    _selectedSucursal = null;
    await _secure.deleteAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConfig.keySucursalId);
  }

  // ── Sucursal switch ────────────────────────────────────────
  Future<void> selectSucursal(Sucursal sucursal) async {
    _selectedSucursal = sucursal;
    _api.setSucursalId(sucursal.id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConfig.keySucursalId, sucursal.id);
    notifyListeners();
  }

  // ── Token refresh (can be called from interceptors) ────────
  Future<bool> refreshToken() async {
    try {
      final rt = await _secure.read(key: AppConfig.keyRefreshToken);
      if (rt == null) return false;

      final json = await _api.post('/auth/refresh', body: {'refreshToken': rt});

      final auth = AuthResponse.fromJson(json);
      _api.setToken(auth.accessToken);
      await _secure.write(
        key: AppConfig.keyAccessToken,
        value: auth.accessToken,
      );
      return true;
    } catch (_) {
      await _clearSession();
      notifyListeners();
      return false;
    }
  }
}
