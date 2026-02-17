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
      _ultimaAsistencia = Asistencia.fromJson(json);
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
}
