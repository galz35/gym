import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';

/// Provider for Clients management.
class ClientesProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<Cliente> _clientes = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  List<Cliente> get clientes => _searchQuery.isEmpty
      ? _clientes
      : _clientes
            .where(
              (c) =>
                  c.nombre.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  (c.telefono?.contains(_searchQuery) ?? false) ||
                  (c.email?.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ) ??
                      false),
            )
            .toList();
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalClientes => _clientes.length;
  int get clientesActivos =>
      _clientes.where((c) => c.estado == 'ACTIVO').length;

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> loadClientes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final json = await _api.get('/clientes');
      _clientes = (json as List).map((j) => Cliente.fromJson(j)).toList();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Error cargando clientes';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Cliente?> createCliente(Map<String, dynamic> data) async {
    try {
      final json = await _api.post('/clientes', body: data);
      final cliente = Cliente.fromJson(json);
      _clientes.insert(0, cliente);
      notifyListeners();
      return cliente;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateCliente(String id, Map<String, dynamic> data) async {
    try {
      final json = await _api.patch('/clientes/$id', body: data);
      final updated = Cliente.fromJson(json);
      final idx = _clientes.indexWhere((c) => c.id == id);
      if (idx >= 0) _clientes[idx] = updated;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }
}
