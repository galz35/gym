import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class SucursalProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<Sucursal> _sucursales = [];
  bool _isLoading = false;
  String? _error;

  List<Sucursal> get sucursales => _sucursales;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadSucursales() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.get('/sucursales');
      final list = response as List;
      _sucursales = list.map((e) => Sucursal.fromJson(e)).toList();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Error cargando sucursales';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createSucursal({
    required String nombre,
    String? direccion,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.post(
        '/sucursales',
        body: {'nombre': nombre, 'direccion': direccion},
      );
      _sucursales.add(Sucursal.fromJson(response));
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'Error creando sucursal';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateSucursal(
    String id, {
    String? nombre,
    String? direccion,
    String? estado,
  }) async {
    try {
      final response = await _api.patch(
        '/sucursales/$id',
        body: {'nombre': nombre, 'direccion': direccion, 'estado': estado},
      );
      final updated = Sucursal.fromJson(response);
      final index = _sucursales.indexWhere((s) => s.id == id);
      if (index != -1) {
        _sucursales[index] = updated;
        notifyListeners();
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}
