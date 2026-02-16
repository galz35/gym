import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';

/// Cart item for POS.
class CartItem {
  final Producto producto;
  int cantidad;

  CartItem({required this.producto, this.cantidad = 1});

  int get subtotalCentavos => producto.precioCentavos * cantidad;
  double get subtotalDisplay => subtotalCentavos / 100;
}

/// Provider for Point-of-Sale operations.
class PosProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<Producto> _productos = [];
  final List<CartItem> _cart = [];
  bool _isLoading = false;
  bool _isProcessing = false;
  String? _error;
  String _searchQuery = '';

  List<Producto> get productos => _searchQuery.isEmpty
      ? _productos
      : _productos
            .where(
              (p) =>
                  p.nombre.toLowerCase().contains(_searchQuery.toLowerCase()),
            )
            .toList();
  List<CartItem> get cart => _cart;
  bool get isLoading => _isLoading;
  bool get isProcessing => _isProcessing;
  String? get error => _error;
  bool get cartIsEmpty => _cart.isEmpty;
  List<Producto> get allProductos => _productos;

  int get totalCentavos =>
      _cart.fold(0, (sum, item) => sum + item.subtotalCentavos);
  double get totalDisplay => totalCentavos / 100;
  int get totalItems => _cart.fold(0, (sum, item) => sum + item.cantidad);

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> loadProductos() async {
    _isLoading = true;
    notifyListeners();

    try {
      final json = await _api.get('/inventario/productos');
      _productos = (json as List).map((j) => Producto.fromJson(j)).toList();
    } catch (e) {
      _error = 'Error cargando productos';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addToCart(Producto producto) {
    final existing = _cart.indexWhere((c) => c.producto.id == producto.id);
    if (existing >= 0) {
      _cart[existing].cantidad++;
    } else {
      _cart.add(CartItem(producto: producto));
    }
    notifyListeners();
  }

  void removeFromCart(int index) {
    _cart.removeAt(index);
    notifyListeners();
  }

  void updateQuantity(int index, int qty) {
    if (qty <= 0) {
      _cart.removeAt(index);
    } else {
      _cart[index].cantidad = qty;
    }
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  /// Process sale: sends to /ventas endpoint.
  Future<Venta?> processSale({
    required String sucursalId,
    required String cajaId,
    String? clienteId,
    required String metodo,
  }) async {
    if (_cart.isEmpty) return null;
    _isProcessing = true;
    _error = null;
    notifyListeners();

    try {
      final json = await _api.post(
        '/ventas',
        body: {
          'sucursal_id': sucursalId,
          'caja_id': cajaId,
          'cliente_id': clienteId,
          'metodo': metodo,
          'detalles': _cart
              .map(
                (item) => {
                  'producto_id': item.producto.id,
                  'cantidad': item.cantidad,
                  'precio_unit_centavos': item.producto.precioCentavos,
                },
              )
              .toList(),
        },
      );
      final venta = Venta.fromJson(json);
      _cart.clear();
      return venta;
    } on ApiException catch (e) {
      _error = e.message;
      return null;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
}
