import 'package:flutter/material.dart';
import '../models/models.dart';
import '../database/app_database.dart' hide Producto;
import '../services/api_service.dart';

/// Provider for Products + Inventory with Offline support.
class InventarioProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  final AppDatabase _db;

  InventarioProvider(this._db);

  List<Producto> _productos = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  List<Producto> get productos => _searchQuery.isEmpty
      ? _productos
      : _productos
            .where(
              (p) =>
                  p.nombre.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  (p.categoria?.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ) ??
                      false),
            )
            .toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get totalProductos => _productos.length;
  int get productosLowStock =>
      _productos.where((p) => (p.existencia ?? 0) <= 5).length;

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> loadProductos() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Local load
      final local = await _db.select(_db.productos).get();
      _productos = local
          .map(
            (p) => Producto(
              id: p.id,
              empresaId: p.empresaId,
              nombre: p.nombre,
              categoria: p.categoria,
              precioCentavos: p.precioCentavos,
              costoCentavos: p.costoCentavos,
              estado: p.estado,
            ),
          )
          .toList();
      notifyListeners();

      final json = await _api.get('/inventario/productos');
      _productos = (json as List).map((j) => Producto.fromJson(j)).toList();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Error cargando productos';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadStockSucursal(String sucursalId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final json = await _api.get('/inventario/stock/$sucursalId');
      _productos = (json as List).map((j) {
        // Stock endpoint returns { producto: {...}, existencia }
        final p = Producto.fromJson(j['producto'] ?? j);
        return Producto(
          id: p.id,
          empresaId: p.empresaId,
          nombre: p.nombre,
          categoria: p.categoria,
          precioCentavos: p.precioCentavos,
          costoCentavos: p.costoCentavos,
          estado: p.estado,
          existencia: j['existencia'] != null
              ? (double.tryParse(j['existencia'].toString()) ?? 0).toInt()
              : p.existencia,
        );
      }).toList();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Error cargando stock';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> registrarEntrada({
    required String sucursalId,
    required String productoId,
    required int cantidad,
    String? notas,
  }) async {
    try {
      await _api.post(
        '/inventario/entrada',
        body: {
          'sucursalId': sucursalId,
          'productoId': productoId,
          'cantidad': cantidad,
          'notas': notas,
        },
      );
      // Reload stock
      await loadStockSucursal(sucursalId);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<Producto?> createProducto(Map<String, dynamic> data) async {
    try {
      final json = await _api.post('/inventario/productos', body: data);
      final p = Producto.fromJson(json);
      _productos.insert(0, p);
      notifyListeners();
      return p;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return null;
    }
  }
}
