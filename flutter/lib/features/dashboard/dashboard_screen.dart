import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/dashboard_provider.dart';

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
                  onPressed: () {},
                  icon: Stack(
                    children: [
                      const Icon(Icons.notifications_outlined, size: 24),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
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
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(48),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
              )
            else ...[
              // ─── KPI Cards ───
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: KpiCard(
                              label: 'Asistencias',
                              value: '${resumen?.asistencias ?? 0}',
                              icon: Icons.how_to_reg_rounded,
                              color: AppColors.primary,
                              subtitle: _selectedPeriod == 'Hoy'
                                  ? 'registradas hoy'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: KpiCard(
                              label: 'Ventas',
                              value: currencyFmt.format(
                                resumen?.ventasTotal ?? 0,
                              ),
                              icon: Icons.trending_up_rounded,
                              color: AppColors.success,
                              subtitle:
                                  '${resumen?.ventasCantidad ?? 0} transacciones',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: KpiCard(
                              label: 'Ingresos',
                              value: currencyFmt.format(resumen?.ingresos ?? 0),
                              icon: Icons.payments_rounded,
                              color: AppColors.info,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: KpiCard(
                              label: 'Por Vencer',
                              value: '${dashboard.vencimientos.length}',
                              icon: Icons.warning_amber_rounded,
                              color: AppColors.warning,
                              subtitle: 'próximos 7 días',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: KpiCard(
                              label: 'Clientes Nuevos',
                              value: '${resumen?.nuevosClientes ?? 0}',
                              icon: Icons.person_add_rounded,
                              color: const Color(0xFF8B5CF6),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          const Expanded(child: SizedBox()),
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
                            onTap: () => widget.onNavigate(10),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          QuickActionButton(
                            icon: Icons.how_to_reg_rounded,
                            label: 'Check-In',
                            color: AppColors.success,
                            onTap: () => widget.onNavigate(1),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          QuickActionButton(
                            icon: Icons.face_unlock_rounded,
                            label: 'Acceso\nBio',
                            color: const Color(0xFF6366F1), // Indigo
                            onTap: () => widget.onNavigate(30),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          QuickActionButton(
                            icon: Icons.card_membership_rounded,
                            label: 'Renovar\nMembresía',
                            color: AppColors.info,
                            onTap: () => widget.onNavigate(11),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          QuickActionButton(
                            icon: Icons.shopping_cart_rounded,
                            label: 'Venta\nRápida',
                            color: const Color(0xFF8B5CF6),
                            onTap: () => widget.onNavigate(2),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          QuickActionButton(
                            icon: Icons.bar_chart_rounded,
                            label: 'Reportes',
                            color: AppColors.warning,
                            onTap: () => widget.onNavigate(22),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ─── Revenue Chart Placeholder ───
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.border),
                      boxShadow: AppColors.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Ingresos',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Últimos 7 días',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
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
                          height: 140,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _buildBar('Lun', 0.6),
                              _buildBar('Mar', 0.8),
                              _buildBar('Mié', 0.45),
                              _buildBar('Jue', 0.9),
                              _buildBar('Vie', 1.0),
                              _buildBar('Sáb', 0.7),
                              _buildBar('Dom', 0.3),
                            ],
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
                      onAction: () => widget.onNavigate(1),
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
                          return AnimatedListItem(
                            index: i,
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                                vertical: AppSpacing.xs,
                              ),
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.md,
                                ),
                                border: Border.all(color: AppColors.border),
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
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          time,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textTertiary,
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
                          return AnimatedListItem(
                            index: i,
                            child: InkWell(
                              onTap: () {
                                // Jump to memberships screen where they can manage it
                                widget.onNavigate(11); // 11 is Membresias
                              },
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
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          Text(
                                            item.planNombre ?? 'Plan',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textSecondary,
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
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Center(
          child: Text(
            message,
            style: const TextStyle(fontSize: 13, color: AppColors.textTertiary),
          ),
        ),
      ),
    );
  }

  Widget _buildBar(String label, double height) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              height: 120 * height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0.6),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
