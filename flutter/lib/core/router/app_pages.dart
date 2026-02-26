/// Centralized page identifiers — replaces all magic numbers.
enum AppPage {
  dashboard(0, 'Dashboard', 'dashboard'),
  checkin(1, 'Check-In', 'checkin'),
  pos(2, 'Punto de Venta', 'pos'),
  caja(3, 'Caja', 'caja'),
  clientes(10, 'Clientes', 'clientes'),
  membresias(11, 'Membresías', 'membresias'),
  planes(12, 'Planes', 'planes'),
  productos(13, 'Productos', 'productos'),
  inventario(14, 'Inventario', 'inventario'),
  sucursales(20, 'Sucursales', 'sucursales'),
  usuarios(21, 'Usuarios', 'usuarios'),
  reportes(22, 'Reportes', 'reportes'),
  logs(99, 'Logs del Sistema', 'logs');

  final int navIndex;
  final String label;
  final String routeName;

  const AppPage(this.navIndex, this.label, this.routeName);

  /// Look up by legacy int index (for backward compat during migration)
  static AppPage fromIndex(int idx) {
    return AppPage.values.firstWhere(
      (p) => p.navIndex == idx,
      orElse: () => AppPage.dashboard,
    );
  }

  /// Whether this page lives in the bottom navigation bar
  bool get isBottomNavPage =>
      navIndex == 0 || navIndex == 1 || navIndex == 2 || navIndex == 3;
}
