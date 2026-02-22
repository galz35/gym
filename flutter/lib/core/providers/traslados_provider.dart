import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class TrasladoDetalleInput {
  final String productoId;
  final String productoNombre;
  int cantidad;

  TrasladoDetalleInput({
    required this.productoId,
    required this.productoNombre,
    this.cantidad = 1,
  });
}

class TrasladosProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<TrasladoInventario> _traslados = [];
  bool _isLoading = false;
  String? _error;

  List<TrasladoInventario> get traslados => _traslados;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPendientes(String sucursalId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final json = await _api.get('/traslados/pendientes/$sucursalId');
      _traslados = (json as List)
          .map((e) => TrasladoInventario.fromJson(e))
          .toList();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Error cargando traslados';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> crearTraslado({
    required String sucursalOrigenId,
    required String sucursalDestinoId,
    required List<TrasladoDetalleInput> detalles,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _api.post(
        '/traslados',
        body: {
          'sucursalOrigenId': sucursalOrigenId,
          'sucursalDestinoId': sucursalDestinoId,
          'detalles': detalles
              .map((d) => {'productoId': d.productoId, 'cantidad': d.cantidad})
              .toList(),
        },
      );
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'Error creando traslado';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> recibirTraslado(String trasladoId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _api.put('/traslados/recibir/$trasladoId');
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'Error recibiendo traslado';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
