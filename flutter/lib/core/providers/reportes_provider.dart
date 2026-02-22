import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class ReportesProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  ResumenDia? _resumen;
  List<AsistenciaPorHora> _asistenciaPorHora = [];
  bool _isLoading = false;
  String? _error;

  ResumenDia? get resumen => _resumen;
  List<AsistenciaPorHora> get asistenciaPorHora => _asistenciaPorHora;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Backend endpoints:
  /// GET /reportes/resumen-dia?fecha=...&sucursalId=...
  /// GET /reportes/asistencia-hora?fecha=...&sucursalId=...
  Future<void> loadResumen(DateTime date, {String? sucursalId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final query = <String, String>{'fecha': date.toIso8601String()};
      if (sucursalId != null) query['sucursalId'] = sucursalId;

      final json = await _api.get('/reportes/resumen-dia', query: query);
      _resumen = ResumenDia.fromJson(json);

      final asistenciaJson = await _api.get(
        '/reportes/asistencia-hora',
        query: query,
      );
      if (asistenciaJson != null && asistenciaJson is List) {
        _asistenciaPorHora = asistenciaJson
            .map((e) => AsistenciaPorHora.fromJson(e))
            .toList();
      }
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Error cargando reportes';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Venta>> getVentasHistorial({
    required DateTime desde,
    required DateTime hasta,
    String? sucursalId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final query = <String, String>{
        'desde': desde.toIso8601String(),
        'hasta': hasta.toIso8601String(),
      };
      if (sucursalId != null) query['sucursalId'] = sucursalId;

      final json = await _api.get('/reportes/ventas', query: query);
      return (json as List).map((e) => Venta.fromJson(e)).toList();
    } on ApiException catch (e) {
      _error = e.message;
      return [];
    } catch (e) {
      _error = 'Error cargando historial de ventas';
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
