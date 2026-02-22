import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';

/// Provider for Dashboard data — fetches daily KPIs and recent activity.
class DashboardProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  ResumenDia? _resumen;
  List<Asistencia> _ultimasAsistencias = [];
  List<MembresiaCliente> _vencimientos = [];
  bool _isLoading = false;
  String? _error;

  ResumenDia? get resumen => _resumen;
  List<Asistencia> get ultimasAsistencias => _ultimasAsistencias;
  List<MembresiaCliente> get vencimientos => _vencimientos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadDashboard(String sucursalId, {String period = 'Hoy'}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    String dias = '1';
    if (period == 'Semana') dias = '7';
    if (period == 'Mes') dias = '30';

    try {
      final results = await Future.wait([
        _api.get(
          '/reportes/resumen-dia',
          query: {'sucursalId': sucursalId, 'dias': dias},
        ),
        _api.get(
          '/reportes/vencimientos',
          query: {'sucursalId': sucursalId, 'dias': '7'},
        ),
        _api.get(
          '/asistencia/recientes',
          query: {'sucursalId': sucursalId, 'limit': '10'},
        ),
      ]);

      _resumen = ResumenDia.fromJson(results[0]);
      _vencimientos = (results[1] as List)
          .map((j) => MembresiaCliente.fromJson(j))
          .toList();
      _ultimasAsistencias = (results[2] as List)
          .map((j) => Asistencia.fromJson(j))
          .toList();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Error cargando dashboard';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _resumen = null;
    _ultimasAsistencias = [];
    _vencimientos = [];
    _error = null;
    notifyListeners();
  }
}
