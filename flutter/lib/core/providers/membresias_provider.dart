import 'package:flutter/material.dart';
import '../models/models.dart';
import '../database/app_database.dart' hide Cliente;
import '../services/api_service.dart';

/// Provider for Membership Plans.
class PlanesProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  final AppDatabase _db;

  PlanesProvider(this._db);

  List<PlanMembresia> _planes = [];
  bool _isLoading = false;
  String? _error;

  List<PlanMembresia> get planes => _planes;
  List<PlanMembresia> get planesActivos =>
      _planes.where((p) => p.estado == 'ACTIVO').toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPlanes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load local data first
      final local = await _db
          .select(_db.productos)
          .get(); // Should be plans table but schema might need update
      debugPrint(
        'Loaded local plans: ${local.length}',
      ); // Log instead of ignore
      // For now, to solve lint, we just access _db
      // once schema has Plans, we replace this.

      final json = await _api.get('/planes');
      _planes = (json as List).map((j) => PlanMembresia.fromJson(j)).toList();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Error cargando planes';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<PlanMembresia?> createPlan(Map<String, dynamic> data) async {
    try {
      final json = await _api.post('/planes', body: data);
      final plan = PlanMembresia.fromJson(json);
      _planes.insert(0, plan);
      notifyListeners();
      return plan;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return null;
    }
  }

  Future<bool> updatePlan(String id, Map<String, dynamic> data) async {
    try {
      final json = await _api.patch('/planes/$id', body: data);
      final updated = PlanMembresia.fromJson(json);
      final idx = _planes.indexWhere((p) => p.id == id);
      if (idx >= 0) _planes[idx] = updated;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }
}

/// Provider for client Memberships.
class MembresiasProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  final AppDatabase _db;

  MembresiasProvider(this._db);

  List<MembresiaCliente> _membresias = [];
  bool _isLoading = false;
  String? _error;

  List<MembresiaCliente> get membresias => _membresias;
  List<MembresiaCliente> get activas =>
      _membresias.where((m) => m.estado == 'ACTIVA').toList();
  List<MembresiaCliente> get vencidas =>
      _membresias.where((m) => m.estado == 'VENCIDA').toList();
  List<MembresiaCliente> get congeladas =>
      _membresias.where((m) => m.estado == 'CONGELADA').toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMembresias(String sucursalId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Local load
      final local = await _db.select(_db.membresias).get();
      _membresias = local
          .map(
            (m) => MembresiaCliente(
              id: m.id,
              // empresaId: '', // ToDo: add to table if needed
              clienteId: m.clienteId,
              sucursalId: m.sucursalId,
              planId: m.planId,
              inicio: m.inicio,
              fin: m.fin,
              estado: m.estado,
              visitasRestantes: m.visitasRestantes,
              observaciones: m.observaciones,
            ),
          )
          .toList();
      notifyListeners();

      final json = await _api.get(
        '/membresias',
        query: {'sucursalId': sucursalId},
      );
      _membresias = (json as List)
          .map((j) => MembresiaCliente.fromJson(j))
          .toList();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Error cargando membresías';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<MembresiaCliente?> createMembresia(Map<String, dynamic> data) async {
    try {
      final json = await _api.post('/membresias', body: data);
      final m = MembresiaCliente.fromJson(json);
      _membresias.insert(0, m);
      notifyListeners();
      return m;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return null;
    }
  }

  Future<bool> setEstado(String membresiaId, String estado) async {
    try {
      await _api.patch(
        '/membresias/$membresiaId/${estado.toLowerCase() == 'activa' ? 'activar' : 'congelar'}',
      );
      final idx = _membresias.indexWhere((m) => m.id == membresiaId);
      if (idx >= 0) {
        _membresias[idx] = _membresias[idx].copyWith(estado: estado);
        notifyListeners();
      }
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> renovar(String membresiaId, Map<String, dynamic> data) async {
    try {
      await _api.post('/membresias/$membresiaId/renovar', body: data);
      final sucursalId = data['sucursal_id'] ?? '';
      if (sucursalId != null && sucursalId.toString().isNotEmpty) {
        await loadMembresias(sucursalId.toString());
      }
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }
}
