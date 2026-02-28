import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/shimmer_widgets.dart';
import '../../core/widgets/premium_widgets.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/dashboard_provider.dart';
import '../../core/router/app_pages.dart';
import '../notifications/notifications_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String gymName;
  final ValueChanged<int> onNavigate;
  final VoidCallback onShowGymSelector;

  const DashboardScreen({
    super.key,
    required this.gymName,
    required this.onNavigate,
    required this.onShowGymSelector,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final auth = context.read<AuthProvider>();
    if (auth.sucursalId.isNotEmpty) {
      context.read<DashboardProvider>().loadDashboard(
        auth.sucursalId,
        period: 'Hoy',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = context.watch<DashboardProvider>();
    final resumen = dashboard.resumen;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            // ─── App Bar ───
            SliverAppBar(
              floating: true,
              snap: true,
              toolbarHeight: 64,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Inicio',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  GymSelectorChip(
                    gymName: widget.gymName,
                    onTap: widget.onShowGymSelector,
                  ),
                ],
              ),
              actions: [
                IconButton(
                  tooltip: 'Notificaciones',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const NotificationsScreen(),
                      ),
                    );
                  },
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.notifications_outlined, size: 24),
                      if (dashboard.vencimientos.isNotEmpty)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${dashboard.vencimientos.length}',
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),

            // ─── Main Actions ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _MainDashboardActionCard(
                      title: 'Asistencia y Registro',
                      subtitle:
                          'Control de accesos y cobro de membresías y pases rápidos',
                      icon: Icons.how_to_reg_rounded,
                      color: AppColors.primary,
                      gradient: const [AppColors.primary, Color(0xFF8B5CF6)],
                      onTap: () => widget.onNavigate(AppPage.checkin.navIndex),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _MainDashboardActionCard(
                      title: 'Venta de Productos',
                      subtitle: 'Venta de productos, bebidas y suplementos',
                      icon: Icons.shopping_cart_rounded,
                      color: AppColors.success,
                      gradient: const [AppColors.success, Color(0xFF10B981)],
                      onTap: () => widget.onNavigate(AppPage.pos.navIndex),
                    ),
                  ],
                ),
              ),
            ),

            // ─── Resumen Diario (Simplified KPIs) ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Resumen del Día',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (dashboard.isLoading && resumen == null)
                      const ShimmerDashboard()
                    else
                      Row(
                        children: [
                          Expanded(
                            child: _PremiumKpiCard(
                              label: 'Asistencias Hoy',
                              value: (resumen?.asistencias ?? 0).toDouble(),
                              icon: Icons.directions_run_rounded,
                              color: AppColors.info,
                              subtitle: 'Personas',
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: _PremiumKpiCard(
                              label: 'Ventas Hoy',
                              value: (resumen?.ventasTotal ?? 0).toDouble(),
                              icon: Icons.payments_rounded,
                              color: AppColors.success,
                              isCurrency: true,
                              subtitle:
                                  '${resumen?.ventasCantidad ?? 0} tickets',
                            ),
                          ),
                        ],
                      ),

                    if (dashboard.error != null)
                      Container(
                        margin: const EdgeInsets.only(top: AppSpacing.lg),
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.errorLight,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.cloud_off_rounded,
                              size: 18,
                              color: AppColors.error,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Error: ${dashboard.error}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: _loadData,
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ─── Main Action Card ──────────────────────────────────────────
class _MainDashboardActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _MainDashboardActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                icon,
                size: 120,
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: Colors.white, size: 28),
                  ),
                  const Spacer(),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ─── Premium KPI Card ──────────────────────────────────────────
class _PremiumKpiCard extends StatelessWidget {
  final String label;
  final double value;
  final IconData icon;
  final Color color;
  final bool isCurrency;
  final String? subtitle;

  const _PremiumKpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.isCurrency = false,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: Theme.of(context).brightness == Brightness.dark
            ? AppColors.cardShadowDark
            : AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: AppSpacing.md),
          isCurrency
              ? AnimatedCurrencyCounter(
                  value: value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.1,
                  ),
                )
              : AnimatedCounter(
                  value: value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.1,
                  ),
                ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
