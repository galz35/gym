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

  Future<void> loadResumen(DateTime date) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final json = await _api.get(
        '/reportes/resumen?fecha=${date.toIso8601String()}',
      );
      _resumen = ResumenDia.fromJson(json);

      final asistenciaJson = await _api.get(
        '/reportes/asistencia-hora?fecha=${date.toIso8601String()}',
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
}
