import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

/// Custom exception for API errors.
class ApiException implements Exception {
  final int statusCode;
  final String message;
  final dynamic body;
  ApiException(this.statusCode, this.message, [this.body]);

  @override
  String toString() => 'ApiException($statusCode): $message';

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isServerError => statusCode >= 500;
}

/// Low-level HTTP client that wraps the `http` package.
/// Handles: base URL, auth headers, JSON serialization, error mapping.
class ApiService {
  final http.Client _client = http.Client();
  String? _accessToken;
  String? _sucursalId;

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // ── Token & Context management ──────────────────────────────
  void setToken(String? token) => _accessToken = token;
  void setSucursalId(String? id) => _sucursalId = id;
  String? get currentToken => _accessToken;
  String? get currentSucursalId => _sucursalId;
  bool get hasToken => _accessToken != null && _accessToken!.isNotEmpty;

  // ── Headers ────────────────────────────────────────────────
  Map<String, String> get _headers {
    final h = <String, String>{
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.acceptHeader: 'application/json',
    };
    if (_accessToken != null) {
      h[HttpHeaders.authorizationHeader] = 'Bearer $_accessToken';
    }
    if (_sucursalId != null) {
      h['X-Sucursal-Id'] = _sucursalId!;
    }
    return h;
  }

  // ── Core request method ────────────────────────────────────
  Future<dynamic> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
  }) async {
    final uri = Uri.parse(
      '${AppConfig.apiBaseUrl}$path',
    ).replace(queryParameters: queryParams);

    http.Response response;
    try {
      switch (method) {
        case 'GET':
          response = await _client
              .get(uri, headers: _headers)
              .timeout(AppConfig.receiveTimeout);
          break;
        case 'POST':
          response = await _client
              .post(
                uri,
                headers: _headers,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(AppConfig.receiveTimeout);
          break;
        case 'PUT':
          response = await _client
              .put(
                uri,
                headers: _headers,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(AppConfig.receiveTimeout);
          break;
        case 'PATCH':
          response = await _client
              .patch(
                uri,
                headers: _headers,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(AppConfig.receiveTimeout);
          break;
        case 'DELETE':
          response = await _client
              .delete(uri, headers: _headers)
              .timeout(AppConfig.receiveTimeout);
          break;
        default:
          throw UnsupportedError('Method $method not supported');
      }
    } on SocketException {
      throw ApiException(0, 'Sin conexión a internet');
    } on http.ClientException catch (e) {
      throw ApiException(0, 'Error de red: ${e.message}');
    }

    return _processResponse(response);
  }

  dynamic _processResponse(http.Response response) {
    if (kDebugMode) {
      debugPrint(
        '[API] ${response.request?.method} ${response.request?.url} → ${response.statusCode}',
      );
      if (response.statusCode >= 400) {
        debugPrint('[API] Response: ${response.body}');
      }
    }

    dynamic decoded;
    try {
      decoded = response.body.isNotEmpty ? jsonDecode(response.body) : null;
    } catch (_) {
      decoded = response.body;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    final message = decoded is Map
        ? (decoded['message'] ?? 'Error desconocido')
        : 'Error ${response.statusCode}';
    final messageStr = message is List
        ? message.join(', ')
        : message.toString();
    throw ApiException(response.statusCode, messageStr, decoded);
  }

  // ── Public convenience methods ─────────────────────────────
  Future<dynamic> get(String path, {Map<String, String>? query}) =>
      _request('GET', path, queryParams: query);

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) =>
      _request('POST', path, body: body);

  Future<dynamic> put(String path, {Map<String, dynamic>? body}) =>
      _request('PUT', path, body: body);

  Future<dynamic> patch(String path, {Map<String, dynamic>? body}) =>
      _request('PATCH', path, body: body);

  Future<dynamic> delete(String path) => _request('DELETE', path);

  void dispose() => _client.close();
}
