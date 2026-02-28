import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/models.dart';

class AsistenciaProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  bool _isLoading = false;
  String? _error;
  Asistencia? _ultimaAsistencia;

  bool get isLoading => _isLoading;
  String? get error => _error;
  Asistencia? get ultimaAsistencia => _ultimaAsistencia;

  Future<Asistencia?> registrarAsistencia(
    String clienteId,
    String sucursalId,
  ) async {
    _isLoading = true;
    _error = null;
    _ultimaAsistencia = null;
    notifyListeners();

    try {
      final json = await _api.post(
        '/asistencia/checkin',
        body: {'clienteId': clienteId, 'sucursalId': sucursalId},
      );

      _ultimaAsistencia = Asistencia(
        id: json['asistenciaId'] ?? '',
        clienteId: clienteId,
        sucursalId: sucursalId,
        fechaHora: DateTime.now(),
        resultado: json['acceso'] == true ? 'PERMITIDO' : 'DENEGADO',
        nota: json['mensaje'] ?? json['motivo'],
      );
      return _ultimaAsistencia;
    } on ApiException catch (e) {
      _error = e.message;
      return null;
    } catch (e) {
      _error = 'Error registrando asistencia';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Asistencia?> registrarSalida(
    String clienteId,
    String sucursalId,
  ) async {
    _isLoading = true;
    _error = null;
    _ultimaAsistencia = null;
    notifyListeners();

    try {
      final json = await _api.post(
        '/asistencia/checkout',
        body: {'clienteId': clienteId, 'sucursalId': sucursalId},
      );

      if (json['acceso'] == true) {
        _ultimaAsistencia = Asistencia(
          id: json['asistenciaId'] ?? '',
          clienteId: clienteId,
          sucursalId: sucursalId,
          fechaHora: DateTime.now(),
          resultado: 'SALIDA',
          nota: json['mensaje'],
        );
        return _ultimaAsistencia;
      } else {
        _error = json['mensaje'] ?? 'Error registrando salida';
        return null;
      }
    } on ApiException catch (e) {
      _error = e.message;
      return null;
    } catch (e) {
      _error = 'Error registrando salida';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
