import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/api_service.dart';

// El estado inmutable para nuestras sucursales
class SucursalesState {
  final List<Sucursal> sucursales;
  final bool isLoading;
  final String? error;

  const SucursalesState({
    this.sucursales = const [],
    this.isLoading = false,
    this.error,
  });

  SucursalesState copyWith({
    List<Sucursal>? sucursales,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return SucursalesState(
      sucursales: sucursales ?? this.sucursales,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// Inyectamos el ApiService
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

// El Notifier que manejará la lógica sin re-renders innecesarios (Riverpod)
class SucursalesNotifier extends StateNotifier<SucursalesState> {
  final ApiService _api;

  SucursalesNotifier(this._api) : super(const SucursalesState()) {
    // Al instanciar, cargamos los datos
    loadSucursales();
  }

  Future<void> loadSucursales() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _api.get('/sucursales');
      final list = (response as List).map((e) => Sucursal.fromJson(e)).toList();
      state = state.copyWith(sucursales: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error cargando sucursales: $e',
      );
    }
  }

  Future<bool> createSucursal({
    required String nombre,
    String? direccion,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _api.post(
        '/sucursales',
        body: {'nombre': nombre, 'direccion': direccion},
      );

      final nuevaSucursal = Sucursal.fromJson(response);

      // Riverpod requiere inmutabilidad: creamos una nueva lista
      state = state.copyWith(
        sucursales: [...state.sucursales, nuevaSucursal],
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error creando sucursal: $e',
      );
      return false;
    }
  }
}

// El Provider a consumir en nuestra interfaz
final sucursalesRiverpodProvider =
    StateNotifierProvider<SucursalesNotifier, SucursalesState>((ref) {
      final api = ref.watch(apiServiceProvider);
      return SucursalesNotifier(api);
    });
