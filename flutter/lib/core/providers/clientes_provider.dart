import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;
import '../models/models.dart';
import '../database/app_database.dart' hide Cliente;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider for Clients management with Offline support.
class ClientesProvider extends ChangeNotifier {
  final AppDatabase _db;
  final SupabaseClient _supabase = Supabase.instance.client;

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
      // Load local data first
      final local = await _db.select(_db.clientes).get();
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

      // Attempt remote sync if online?
      // For now we can trigger a sync in background or check connectivity
      // _api.checkConnectivity(); // Example usage
    } catch (e) {
      _error = 'Error cargando datos locales';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Cliente?> createCliente(Map<String, dynamic> data) async {
    try {
      final id = data['id'] ?? const Uuid().v4();
      final cliente = Cliente(
        id: id,
        empresaId: data['empresa_id'] ?? '',
        nombre: data['nombre'],
        telefono: data['telefono'],
        email: data['email'],
        documento: data['documento'],
        estado: 'ACTIVO',
      );

      // Save to local DB
      await _db
          .into(_db.clientes)
          .insert(
            ClientesCompanion.insert(
              id: id,
              empresaId: cliente.empresaId,
              nombre: cliente.nombre,
              telefono: drift.Value(cliente.telefono),
              email: drift.Value(cliente.email),
              documento: drift.Value(cliente.documento),
              isDirty: const drift.Value(true),
            ),
          );

      // Log change for sync
      await _db
          .into(_db.syncLog)
          .insert(
            SyncLogCompanion.insert(
              action: 'CREATE',
              entity: 'CLIENTE',
              entityId: id,
              payload: jsonEncode(data),
            ),
          );

      _clientes.insert(0, cliente);
      notifyListeners();
      return cliente;
    } catch (e) {
      _error = 'Error al guardar localmente';
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateCliente(String id, Map<String, dynamic> data) async {
    try {
      // Update local
      await (_db.update(_db.clientes)..where((t) => t.id.equals(id))).write(
        ClientesCompanion(
          nombre: drift.Value(data['nombre']),
          telefono: drift.Value(data['telefono']),
          email: drift.Value(data['email']),
          isDirty: const drift.Value(true),
        ),
      );

      // Log change
      await _db
          .into(_db.syncLog)
          .insert(
            SyncLogCompanion.insert(
              action: 'UPDATE',
              entity: 'CLIENTE',
              entityId: id,
              payload: jsonEncode(data),
            ),
          );

      final idx = _clientes.indexWhere((c) => c.id == id);
      if (idx >= 0) {
        _clientes[idx] = Cliente(
          id: id,
          empresaId: _clientes[idx].empresaId,
          nombre: data['nombre'] ?? _clientes[idx].nombre,
          telefono: data['telefono'] ?? _clientes[idx].telefono,
          email: data['email'] ?? _clientes[idx].email,
          documento: _clientes[idx].documento,
        );
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error actualizando localmente';
      notifyListeners();
      return false;
    }
  }

  Future<void> checkConnectivity() async {
    // Placeholder for connectivity check using _api if available
    // _api.checkConnectivity();
  }

  // ── Biometrics ─────────────────────────────────────────────

  /// Generates embedding, uploads compressed photo to Storage,
  /// and updates the client record in Supabase with the vector.
  Future<bool> registrarBiometria({
    required String clienteId,
    required List<double> embedding,
    required String? publicFotoUrl,
  }) async {
    try {
      final updates = {
        'face_embedding': embedding, // pgvector handles List<double>
        'foto_url': publicFotoUrl,
      }..removeWhere((k, v) => v == null);

      await _supabase
          .schema('gym')
          .from('cliente')
          .update(updates)
          .eq('id', clienteId);

      // Update local object immediately
      final idx = _clientes.indexWhere((c) => c.id == clienteId);
      if (idx >= 0) {
        // Local update for immediate feedback (only photo, embedding is hidden)
        if (publicFotoUrl != null) {
          _clientes[idx] = _clientes[idx].copyWith(fotoUrl: publicFotoUrl);
          notifyListeners();
        }
      }
      return true;
    } catch (e) {
      _error = 'Error registrando biometría: $e';
      notifyListeners();
      return false;
    }
  }

  /// Search for a client using a face embedding (1:N search)
  Future<Cliente?> identificarCliente(List<double> embedding) async {
    try {
      final List<dynamic> response = await _supabase
          .schema('gym')
          .rpc(
            'match_face_embedding',
            params: {
              'query_embedding': embedding,
              'match_threshold': 0.6, // Tweak based on testing
              'match_count': 1,
            },
          );

      if (response.isNotEmpty) {
        final match = response.first;
        final String clienteId = match['id'];

        // Find in local cache if possible, otherwise create basic object from match
        try {
          return _clientes.firstWhere((c) => c.id == clienteId);
        } catch (_) {
          return Cliente(
            id: clienteId,
            empresaId: '',
            nombre: match['nombre'] ?? 'Usuario Reconocido',
            fotoUrl: match['foto_url'],
            estado: match['estado'] ?? 'ACTIVO',
          );
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error en identificación: $e');
      return null;
    }
  }
}
