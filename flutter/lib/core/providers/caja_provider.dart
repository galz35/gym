import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';

/// Provider for Caja (cash register) management.
class CajaProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  CajaModel? _cajaAbierta;
  List<Pago> _movimientos = [];
  bool _isLoading = false;
  String? _error;

  CajaModel? get cajaAbierta => _cajaAbierta;
  List<Pago> get movimientos => _movimientos;
  bool get isLoading => _isLoading;
  bool get hasCajaAbierta => _cajaAbierta != null;
  String? get error => _error;

  double get totalIngresos => _movimientos
      .where((m) => m.tipo != 'GASTO')
      .fold(0.0, (sum, m) => sum + m.montoDisplay);

  double get totalEgresos => _movimientos
      .where((m) => m.tipo == 'GASTO')
      .fold(0.0, (sum, m) => sum + m.montoDisplay);

  Future<void> loadCajaAbierta() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final json = await _api.get('/caja/abierta');
      if (json != null && json is Map<String, dynamic> && json['id'] != null) {
        _cajaAbierta = CajaModel.fromJson(json);
        // Load movements for this caja
        await _loadMovimientos();
      } else {
        _cajaAbierta = null;
        _movimientos = [];
      }
    } on ApiException catch (e) {
      if (e.isNotFound) {
        _cajaAbierta = null;
        _movimientos = [];
      } else {
        _error = e.message;
      }
    } catch (e) {
      _error = 'Error cargando caja';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadMovimientos() async {
    if (_cajaAbierta == null) return;
    try {
      final json = await _api.get(
        '/pagos',
        query: {'cajaId': _cajaAbierta!.id},
      );
      _movimientos = (json as List).map((j) => Pago.fromJson(j)).toList();
    } catch (_) {
      _movimientos = [];
    }
  }

  /// Opens a new cash register session.
  /// Backend DTO expects: { sucursalId: UUID, montoApertura: number (centavos) }
  Future<bool> abrirCaja(double montoApertura, {required String sucursalId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final json = await _api.post(
        '/caja/abrir',
        body: {
          'sucursalId': sucursalId,
          'montoApertura': (montoApertura * 100).toInt(),
        },
      );
      _cajaAbierta = CajaModel.fromJson(json);
      _movimientos = [];
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'Error abriendo caja';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Closes the current cash register session.
  /// Backend DTO expects: { montoCierre: number (centavos), notaCierre?: string }
  Future<bool> cerrarCaja(double montoCierre, String? nota) async {
    if (_cajaAbierta == null) return false;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _api.post(
        '/caja/cerrar/${_cajaAbierta!.id}',
        body: {
          'montoCierre': (montoCierre * 100).toInt(),
          if (nota != null && nota.isNotEmpty) 'notaCierre': nota,
        },
      );
      _cajaAbierta = null;
      _movimientos = [];
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'Error cerrando caja';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> registrarGasto(double monto, String descripcion) async {
    if (_cajaAbierta == null) return false;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final json = await _api.post(
        '/pagos/gasto',
        body: {
          'caja_id': _cajaAbierta!.id,
          'monto_centavos': (monto * 100).toInt(),
          'descripcion': descripcion,
        },
      );
      final pago = Pago.fromJson(json);
      _movimientos.insert(0, pago);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'Error registrando gasto';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _cajaAbierta = null;
    _movimientos = [];
    _error = null;
    notifyListeners();
  }
}
