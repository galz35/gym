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
      // Ignore load error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createUsuario({
    required String nombre,
    required String email,
    required String password,
    required String role,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.post(
        '/usuarios',
        body: {
          'nombre': nombre,
          'email': email,
          'password': password,
          'roles': [role],
        },
      );
      // Assuming response returns the created user
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

  Future<bool> updateUser(
    String id, {
    String? nombre,
    String? email,
    List<String>? roles,
    String? estado,
  }) async {
    try {
      final response = await _api.patch(
        '/usuarios/$id',
        body: {
          'nombre': nombre,
          'email': email,
          'roles': roles,
          'estado': estado,
        },
      );
      final updated = UserProfile.fromJson(response);
      final index = _usuarios.indexWhere((u) => u.id == id);
      if (index != -1) {
        _usuarios[index] = updated;
        notifyListeners();
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}
