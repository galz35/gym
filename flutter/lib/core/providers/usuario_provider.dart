import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class UsuarioProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<UserProfile> _usuarios = [];
  bool _isLoading = false;
  String? _error;

  List<UserProfile> get usuarios => _usuarios;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUsuarios() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.get('/usuarios');
      final list = response as List;
      _usuarios = list.map((e) => UserProfile.fromJson(e)).toList();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Error cargando usuarios';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Backend DTO expects: { empresaId (UUID), email, nombre, password (min 6), roles? (int[]), sucursales? (UUID[]) }
  Future<bool> createUsuario({
    required String nombre,
    required String email,
    required String password,
    required String empresaId,
    List<int>? roles,
    List<String>? sucursales,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.post(
        '/usuarios',
        body: {
          'empresaId': empresaId,
          'nombre': nombre,
          'email': email,
          'password': password,
          if (roles != null && roles.isNotEmpty) 'roles': roles,
          if (sucursales != null && sucursales.isNotEmpty)
            'sucursales': sucursales,
        },
      );
      _usuarios.add(UserProfile.fromJson(response));
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'Error creando usuario';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Backend expects PUT /usuarios/:id with UpdateUsuarioDto fields
  Future<bool> updateUser(
    String id, {
    String? nombre,
    String? email,
    String? estado,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final body = <String, dynamic>{};
      if (nombre != null) body['nombre'] = nombre;
      if (email != null) body['email'] = email;
      if (estado != null) body['estado'] = estado;

      final response = await _api.put('/usuarios/$id', body: body);
      final updated = UserProfile.fromJson(response);
      final index = _usuarios.indexWhere((u) => u.id == id);
      if (index != -1) {
        _usuarios[index] = updated;
        notifyListeners();
      }
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'Error actualizando usuario';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Activate / deactivate user
  Future<bool> setStatus(String id, bool active) async {
    try {
      await _api.post('/usuarios/$id/${active ? 'activar' : 'inactivar'}');
      final index = _usuarios.indexWhere((u) => u.id == id);
      if (index != -1) {
        _usuarios[index] = UserProfile(
          id: _usuarios[index].id,
          empresaId: _usuarios[index].empresaId,
          email: _usuarios[index].email,
          nombre: _usuarios[index].nombre,
          estado: active ? 'ACTIVO' : 'INACTIVO',
          roles: _usuarios[index].roles,
          sucursales: _usuarios[index].sucursales,
        );
        notifyListeners();
      }
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  /// Update user roles
  Future<bool> updateRoles(String id, List<String> roles) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _api.put(
        '/usuarios/$id/roles',
        body: {'roles': roles},
      );
      final updated = UserProfile.fromJson(response);
      final index = _usuarios.indexWhere((u) => u.id == id);
      if (index != -1) {
        _usuarios[index] = updated;
        notifyListeners();
      }
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update user branches
  Future<bool> updateSucursales(String id, List<String> sucursalIds) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _api.put(
        '/usuarios/$id/sucursales',
        body: {'sucursalIds': sucursalIds},
      );
      final updated = UserProfile.fromJson(response);
      final index = _usuarios.indexWhere((u) => u.id == id);
      if (index != -1) {
        _usuarios[index] = updated;
        notifyListeners();
      }
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
