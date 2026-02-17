import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/clientes/clientes_screen.dart';
import '../../features/membresias/membresias_screen.dart';
import '../../features/asistencia/checkin_screen.dart';
import '../../features/caja/caja_screen.dart';
import '../../features/pos/pos_screen.dart';
import '../../features/inventario/inventario_screen.dart';
import '../../features/usuarios/usuarios_screen.dart';
import '../../features/sucursales/sucursales_screen.dart';
import '../../features/reportes/reportes_screen.dart';
import '../../features/productos/productos_screen.dart';
import '../../features/planes/planes_screen.dart';
import '../../features/access_control/access_control_screen.dart';

class AppShell extends StatefulWidget {
  final VoidCallback onLogout;

  const AppShell({super.key, required this.onLogout});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Helper to get current gym name from provider
  String _currentGymName(AuthProvider auth) {
    return auth.selectedSucursal?.nombre ?? 'GymPro';
  }

  // Bottom nav pages
  final List<_NavItem> _bottomNavItems = const [
    _NavItem(Icons.dashboard_rounded, 'Inicio'),
    _NavItem(Icons.how_to_reg_rounded, 'Check-In'),
    _NavItem(Icons.point_of_sale_rounded, 'POS'),
    _NavItem(Icons.account_balance_wallet_rounded, 'Caja'),
    _NavItem(Icons.menu_rounded, 'Menú'),
  ];

  // Drawer menu items
  final List<_MenuItem> _menuItems = [
    _MenuItem(Icons.dashboard_rounded, 'Dashboard', 0),
    _MenuItem(Icons.how_to_reg_rounded, 'Check-In', 1),
    _MenuItem(Icons.face_unlock_rounded, 'Acceso Biométrico', 30), // Now visible
    _MenuItem(Icons.point_of_sale_rounded, 'Punto de Venta', 2),
    _MenuItem(Icons.account_balance_wallet_rounded, 'Caja', 3),
    _MenuItem(Icons.people_rounded, 'Clientes', 10),
    _MenuItem(Icons.card_membership_rounded, 'Membresías', 11),
    _MenuItem(Icons.category_rounded, 'Planes', 12),
    _MenuItem(Icons.inventory_2_rounded, 'Productos', 13),
    _MenuItem(Icons.warehouse_rounded, 'Inventario', 14),
    // Admin stuff could be conditional, but requested "employee does everything"
    _MenuItem(Icons.store_rounded, 'Sucursales', 20),
    _MenuItem(Icons.admin_panel_settings_rounded, 'Usuarios', 21),
    _MenuItem(Icons.bar_chart_rounded, 'Reportes', 22),
  ];

  Widget _buildCurrentPage() {
    switch (_currentIndex) {
      case 0:
        return DashboardScreen(
          gymName: _currentGymName(context.read<AuthProvider>()),
          onNavigate: (index) => setState(() => _currentIndex = index),
        );
      case 1:
        return const CheckinScreen();
      case 2:
        return const PosScreen();
      case 3:
        return const CajaScreen();
      case 10:
        return const ClientesScreen();
      case 11:
        return const MembresiasScreen();
      case 12:
        return const PlanesScreen();
      case 13:
        return const ProductosScreen();
      case 14:
        return const InventarioScreen();
      case 20:
        return const SucursalesScreen();
      case 21:
        return const UsuariosScreen();
      case 22:
        return const ReportesScreen();
      case 30:
        return const AccessControlScreen();
      default:
        return DashboardScreen(
          gymName: _currentGymName(context.read<AuthProvider>()),
          onNavigate: (index) => setState(() => _currentIndex = index),
        );
    }
  }

  int _bottomNavIndex() {
    if (_currentIndex <= 3) return _currentIndex;
    return 4; // "Menu" for everything else
  }

  void _onBottomNavTap(int index) {
    if (index == 4) {
      _scaffoldKey.currentState?.openDrawer();
    } else {
      setState(() => _currentIndex = index);
    }
  }

  void _showGymSelector() {
    final auth = context.read<AuthProvider>();
    final sucursales = auth.user?.sucursales ?? [];
    if (sucursales.isEmpty) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const Text(
                'Seleccionar Sucursal',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Elige la sucursal donde estás operando',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xl),
              ...List.generate(sucursales.length, (i) {
                final s = sucursales[i];
                final isSelected = s.id == auth.sucursalId;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      onTap: () {
                        auth.selectSucursal(s);
                        setState(() {});
                        Navigator.pop(ctx);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primarySurface
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.border,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.md,
                                ),
                              ),
                              child: Icon(
                                Icons.fitness_center_rounded,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textTertiary,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.lg),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s.nombre,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isSelected
                                        ? 'Sucursal actual'
                                        : s.direccion ??
                                              'Cambiar a esta sucursal',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isSelected
                                          ? AppColors.primary.withValues(
                                              alpha: 0.7,
                                            )
                                          : AppColors.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.primary,
                                size: 22,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: KeyedSubtree(
          key: ValueKey(_currentIndex),
          child: _buildCurrentPage(),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: List.generate(_bottomNavItems.length, (i) {
              final item = _bottomNavItems[i];
              final isActive = _bottomNavIndex() == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _onBottomNavTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.primarySurface
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: Icon(
                            item.icon,
                            size: 22,
                            color: isActive
                                ? AppColors.primary
                                : AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isActive
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: isActive
                                ? AppColors.primary
                                : AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          // ─── Drawer Header ───
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 20,
              right: 20,
              bottom: 20,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF991B1B), Color(0xFFDC2626)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.fitness_center_rounded,
                    color: AppColors.primary,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'GymPro',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${context.watch<AuthProvider>().userName} — ${_currentGymName(context.read<AuthProvider>())}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _showGymSelector();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.swap_horiz_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Cambiar sucursal',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ─── Menu Items ───
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              children: [
                _buildMenuSection('OPERACIÓN', [0, 1, 2, 3]),
                _buildMenuSection('CATÁLOGOS', [4, 5, 6, 7, 8]),
                _buildMenuSection('ADMINISTRACIÓN', [9, 10, 11]),
              ],
            ),
          ),
          // ─── Logout ───
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: AppColors.error),
            title: const Text(
              'Cerrar Sesión',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: widget.onLogout,
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }

  Widget _buildMenuSection(String title, List<int> indices) {
    final items = indices
        .where((i) => i < _menuItems.length)
        .map((i) => _menuItems[i])
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 20,
            top: AppSpacing.lg,
            bottom: AppSpacing.xs,
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textTertiary,
              letterSpacing: 1,
            ),
          ),
        ),
        ...items.map((item) {
          final isActive = _currentIndex == item.pageIndex;
          return ListTile(
            dense: true,
            visualDensity: const VisualDensity(vertical: -1),
            leading: Icon(
              item.icon,
              size: 20,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
            title: Text(
              item.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            selected: isActive,
            selectedTileColor: AppColors.primarySurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            onTap: () {
              setState(() => _currentIndex = item.pageIndex);
              Navigator.pop(context);
            },
          );
        }),
      ],
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}

class _MenuItem {
  final IconData icon;
  final String label;
  final int pageIndex;
  const _MenuItem(this.icon, this.label, this.pageIndex);
}
