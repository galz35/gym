import 'dart:convert';
import 'dart:io' as java_io;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import '../config/app_config.dart';
import '../models/models.dart';
import '../database/app_database.dart' hide Cliente;
import '../services/api_service.dart';

/// Provider for Clients management with Offline support.
class ClientesProvider extends ChangeNotifier {
  final AppDatabase _db;
  final ApiService _api = ApiService();

  ClientesProvider(this._db);

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
      // 1. Load local data first for immediate UI
      final local = await _db.select(_db.clientes).get();
      if (local.isNotEmpty) {
        _clientes = local
            .map(
              (c) => Cliente(
                id: c.id,
                empresaId: c.empresaId,
                nombre: c.nombre,
                telefono: c.telefono,
                email: c.email,
                documento: c.documento,
                fotoUrl: c.fotoUrl,
                estado: c.estado,
                creadoAt: c.creadoAt,
              ),
            )
            .toList();
        notifyListeners();
      }

      // 2. Fetch from remote API
      final json = await _api.get('/clientes');
      final remote = (json as List).map((j) => Cliente.fromJson(j)).toList();

      // 3. Update local DB (Upsert)
      await _db.batch((batch) {
        for (final c in remote) {
          batch.insert(
            _db.clientes,
            ClientesCompanion.insert(
              id: c.id,
              empresaId: c.empresaId,
              nombre: c.nombre,
              telefono: drift.Value(c.telefono),
              email: drift.Value(c.email),
              documento: drift.Value(c.documento),
              fotoUrl: drift.Value(c.fotoUrl),
              estado: drift.Value(c.estado),
              creadoAt: drift.Value(c.creadoAt),
            ),
            mode: drift.InsertMode.insertOrReplace,
          );
        }
      });

      _clientes = remote;
      _error = null;
    } on ApiException catch (e) {
      _error = e.message;
      // If we have local data, don't show error as a blocker
      if (_clientes.isEmpty) _error = e.message;
    } catch (e) {
      if (_clientes.isEmpty) _error = 'Error de red. Verifica tu conexión.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Cliente?> createCliente(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Send to API first (Online-first for now to satisfy user)
      final json = await _api.post('/clientes', body: data);
      final cliente = Cliente.fromJson(json);

      // 2. Save to local DB (Keep sync)
      await _db
          .into(_db.clientes)
          .insert(
            ClientesCompanion.insert(
              id: cliente.id,
              empresaId: cliente.empresaId,
              nombre: cliente.nombre,
              telefono: drift.Value(cliente.telefono),
              email: drift.Value(cliente.email),
              documento: drift.Value(cliente.documento),
              estado: drift.Value(cliente.estado),
              isDirty: const drift.Value(false),
            ),
            mode: drift.InsertMode.insertOrReplace,
          );

      _clientes.insert(0, cliente);
      return cliente;
    } on ApiException catch (e) {
      _error = e.message;
      return null;
    } catch (e) {
      _error = 'Error al crear cliente. Verifica tu red.';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update a client — online-first approach
  /// Backend expects PUT /clientes/:id with UpdateClienteDto
  Future<bool> updateCliente(String id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Send to API first
      final json = await _api.put('/clientes/$id', body: data);
      final updated = Cliente.fromJson(json);

      // 2. Update local DB
      await (_db.update(_db.clientes)..where((t) => t.id.equals(id))).write(
        ClientesCompanion(
          nombre: drift.Value(updated.nombre),
          telefono: drift.Value(updated.telefono),
          email: drift.Value(updated.email),
          documento: drift.Value(updated.documento),
          isDirty: const drift.Value(false),
        ),
      );

      // 3. Update in-memory list
      final idx = _clientes.indexWhere((c) => c.id == id);
      if (idx >= 0) {
        _clientes[idx] = updated;
      }
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Error al actualizar cliente. Verifica tu red.';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> uploadFoto(String clienteId, java_io.File imageFile) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${AppConfig.apiBaseUrl}/clientes/$clienteId/foto'),
      );
      if (_api.currentToken != null) {
        request.headers['Authorization'] = 'Bearer ${_api.currentToken}';
      }
      if (_api.currentSucursalId != null) {
        request.headers['X-Sucursal-Id'] = _api.currentSucursalId!;
      }

      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final json = jsonDecode(response.body);
        final fotoUrl = json['fotoUrl'];
        if (fotoUrl != null) {
          final idx = _clientes.indexWhere((c) => c.id == clienteId);
          if (idx >= 0) {
            _clientes[idx] = _clientes[idx].copyWith(fotoUrl: fotoUrl);
            notifyListeners();
          }
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error al subir foto: $e');
      return false;
    }
  }

  Future<void> checkConnectivity() async {
    // Placeholder for connectivity check using _api if available
    // _api.checkConnectivity();
  }
}
