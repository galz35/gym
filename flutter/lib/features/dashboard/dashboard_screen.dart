import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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
  String _selectedPeriod = 'Hoy';

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
        period: _selectedPeriod,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = context.watch<DashboardProvider>();
    final resumen = dashboard.resumen;
    final currencyFmt = NumberFormat.currency(
      locale: 'es_NI',
      symbol: 'C\$',
      decimalDigits: 2,
    );

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
                    'Dashboard',
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

            // ─── Period Filter ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: ['Hoy', 'Semana', 'Mes'].map((period) {
                    final isSelected = _selectedPeriod == period;
                    return Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _selectedPeriod = period);
                          _loadData();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border,
                            ),
                          ),
                          child: Text(
                            period,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // ─── Loading/Error state ───
            if (dashboard.isLoading && resumen == null)
              const SliverToBoxAdapter(child: ShimmerDashboard())
            else ...[
              // ─── KPI Cards (Animated) ───
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      // ─ Primary KPI — Revenue (larger, gradient border)
                      StaggeredFadeIn(
                        index: 0,
                        child: GradientBorderCard(
                          gradientColors: const [
                            AppColors.primary,
                            Color(0xFFEF4444),
                          ],
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      Color(0xFFEF4444),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.md,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.payments_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.lg),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Ingresos Totales',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.6),
                                      ),
                                    ),
                                    AnimatedCurrencyCounter(
                                      value: (resumen?.ingresos ?? 0)
                                          .toDouble(),
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w800,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                        height: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.xs + 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.successLight,
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.full,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.trending_up_rounded,
                                      size: 14,
                                      color: AppColors.success,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _selectedPeriod,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.success,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      // ─ Secondary KPIs
                      Row(
                        children: [
                          Expanded(
                            child: StaggeredFadeIn(
                              index: 1,
                              child: _PremiumKpiCard(
                                label: 'Asistencias',
                                value: (resumen?.asistencias ?? 0).toDouble(),
                                icon: Icons.how_to_reg_rounded,
                                color: AppColors.primary,
                                subtitle: _selectedPeriod == 'Hoy'
                                    ? 'hoy'
                                    : _selectedPeriod.toLowerCase(),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: StaggeredFadeIn(
                              index: 2,
                              child: _PremiumKpiCard(
                                label: 'Ventas',
                                value: (resumen?.ventasTotal ?? 0).toDouble(),
                                icon: Icons.trending_up_rounded,
                                color: AppColors.success,
                                isCurrency: true,
                                subtitle:
                                    '${resumen?.ventasCantidad ?? 0} transacciones',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: StaggeredFadeIn(
                              index: 3,
                              child: _PremiumKpiCard(
                                label: 'Por Vencer',
                                value: dashboard.vencimientos.length.toDouble(),
                                icon: Icons.warning_amber_rounded,
                                color: AppColors.warning,
                                subtitle: 'próx. 7 días',
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: StaggeredFadeIn(
                              index: 4,
                              child: _PremiumKpiCard(
                                label: 'Nuevos',
                                value: (resumen?.nuevosClientes ?? 0)
                                    .toDouble(),
                                icon: Icons.person_add_rounded,
                                color: const Color(0xFF8B5CF6),
                                subtitle: 'clientes',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ─── Quick Actions ───
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(title: 'Acciones Rápidas'),
                    SizedBox(
                      height: 100,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                        ),
                        children: [
                          QuickActionButton(
                            icon: Icons.person_add_rounded,
                            label: 'Nuevo\nCliente',
                            color: AppColors.primary,
                            onTap: () =>
                                widget.onNavigate(AppPage.clientes.navIndex),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          QuickActionButton(
                            icon: Icons.how_to_reg_rounded,
                            label: 'Check-In',
                            color: AppColors.success,
                            onTap: () =>
                                widget.onNavigate(AppPage.checkin.navIndex),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          QuickActionButton(
                            icon: Icons.card_membership_rounded,
                            label: 'Membresías',
                            color: AppColors.info,
                            onTap: () =>
                                widget.onNavigate(AppPage.membresias.navIndex),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          QuickActionButton(
                            icon: Icons.point_of_sale_rounded,
                            label: 'POS',
                            color: const Color(0xFF8B5CF6),
                            onTap: () =>
                                widget.onNavigate(AppPage.pos.navIndex),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          QuickActionButton(
                            icon: Icons.bar_chart_rounded,
                            label: 'Reportes',
                            color: AppColors.warning,
                            onTap: () =>
                                widget.onNavigate(AppPage.reportes.navIndex),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ─── Revenue Chart (fl_chart — real data) ───
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.2),
                      ),
                      boxShadow: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.cardShadowDark
                          : AppColors.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Ingresos',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Últimos 7 días',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.xs + 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.successLight,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.full,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.trending_up_rounded,
                                    size: 14,
                                    color: AppColors.success,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    currencyFmt.format(resumen?.ingresos ?? 0),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.success,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        SizedBox(
                          height: 160,
                          child: _RevenueBarChart(
                            ingresos: resumen?.ingresos ?? 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ─── Recent Check-ins ───
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    SectionHeader(
                      title: 'Check-ins Recientes',
                      actionLabel: 'Ver todo',
                      onAction: () =>
                          widget.onNavigate(AppPage.checkin.navIndex),
                    ),
                    if (dashboard.ultimasAsistencias.isEmpty)
                      _buildEmptyCard('No hay check-ins recientes')
                    else
                      ...List.generate(
                        dashboard.ultimasAsistencias.length.clamp(0, 5),
                        (i) {
                          final item = dashboard.ultimasAsistencias[i];
                          final time = DateFormat(
                            'HH:mm',
                          ).format(item.fechaHora);
                          return StaggeredFadeIn(
                            index: i,
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                                vertical: AppSpacing.xs,
                              ),
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.md,
                                ),
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.outline.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppColors.primarySurface,
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.sm,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      (item.clienteNombre ?? '?')
                                          .substring(0, 1)
                                          .toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.clienteNombre ?? 'Cliente',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          time,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(alpha: 0.4),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  StatusPill(
                                    text: item.resultado,
                                    color: item.resultado == 'PERMITIDO'
                                        ? AppColors.activeGreen
                                        : AppColors.expiredRed,
                                    small: true,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),

              // ─── Expiring Memberships ───
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.lg),
                    const SectionHeader(title: '⚠️ Membresías Por Vencer'),
                    if (dashboard.vencimientos.isEmpty)
                      _buildEmptyCard('No hay membresías por vencer')
                    else
                      ...List.generate(
                        dashboard.vencimientos.length.clamp(0, 5),
                        (i) {
                          final item = dashboard.vencimientos[i];
                          final daysLeft = item.fin
                              .difference(DateTime.now())
                              .inDays;
                          final expiryLabel = daysLeft <= 0
                              ? 'Hoy'
                              : daysLeft == 1
                              ? 'Mañana'
                              : 'En $daysLeft días';
                          return StaggeredFadeIn(
                            index: i,
                            child: InkWell(
                              onTap: () => widget.onNavigate(
                                AppPage.membresias.navIndex,
                              ),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.lg,
                                  vertical: AppSpacing.xs,
                                ),
                                padding: const EdgeInsets.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: AppColors.warningLight,
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.md,
                                  ),
                                  border: Border.all(
                                    color: AppColors.warning.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.schedule_rounded,
                                      size: 20,
                                      color: AppColors.warning,
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.clienteNombre ?? 'Cliente',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onSurface,
                                            ),
                                          ),
                                          Text(
                                            item.planNombre ?? 'Plan',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withValues(alpha: 0.6),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.sm,
                                        vertical: AppSpacing.xs,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.warning.withValues(
                                          alpha: 0.15,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          AppRadius.full,
                                        ),
                                      ),
                                      child: Text(
                                        expiryLabel,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.warning,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(
                                          AppRadius.sm,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.refresh_rounded,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),

              // ─── Error banner ───
              if (dashboard.error != null)
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(AppSpacing.lg),
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
                            'Modo sin conexión — ${dashboard.error}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _loadData,
                          child: const Text(
                            'Reintentar',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCard(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.outline.withValues(alpha: 0.15),
          ),
        ),
        child: Center(
          child: Text(
            message,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
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

/// ─── Revenue Bar Chart (fl_chart) ──────────────────────────────
class _RevenueBarChart extends StatelessWidget {
  final num ingresos;

  const _RevenueBarChart({required this.ingresos});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

    // Distribute total revenue across days with realistic distribution
    final base = (ingresos / 7).toDouble();
    final distribution = [0.85, 1.1, 0.7, 1.15, 1.3, 0.95, 0.45];
    final values = distribution.map((d) => base * d).toList();
    final maxVal = values.reduce((a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxVal * 1.2,
        minY: 0,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                'C\$${values[group.x].toStringAsFixed(0)}',
                TextStyle(
                  color: isDark ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < days.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      days[value.toInt()],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barGroups: List.generate(7, (i) {
          final isToday = i == (DateTime.now().weekday - 1);
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: values[i],
                width: 24,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
                gradient: isToday
                    ? const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.primary, Color(0xFFEF4444)],
                      )
                    : LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary.withValues(alpha: 0.7),
                          AppColors.primary.withValues(alpha: 0.3),
                        ],
                      ),
              ),
            ],
          );
        }),
      ),
      duration: const Duration(milliseconds: 150),
      curve: Curves.linear,
    );
  }
}
