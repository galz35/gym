import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/providers/caja_provider.dart';
import '../../core/providers/auth_provider.dart';

class CajaScreen extends StatefulWidget {
  const CajaScreen({super.key});

  @override
  State<CajaScreen> createState() => _CajaScreenState();
}

class _CajaScreenState extends State<CajaScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CajaProvider>().loadCajaAbierta();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CajaProvider>();
    final authFn =
        context.read<AuthProvider>; // Function to get auth provider safely
    final user = authFn().user;

    final currencyFmt = NumberFormat.simpleCurrency(locale: 'es_GT', name: 'Q');

    // Status Logic
    final isOpen = provider.hasCajaAbierta;
    final caja = provider.cajaAbierta;

    // Calculations
    final fondoInicial = isOpen ? (caja!.montoAperturaCentavos / 100.0) : 0.0;

    double ventasEfectivo = 0;
    double ventasTarjeta = 0;
    double gastos = 0;

    for (final m in provider.movimientos) {
      final monto = m.montoDisplay;
      if (m.tipo == 'GASTO') {
        gastos += monto;
      } else {
        // Ingresos (Ventas, Pagos)
        if (m.metodo == 'EFECTIVO') {
          ventasEfectivo += monto;
        } else if (m.metodo == 'TARJETA') {
          ventasTarjeta += monto;
        }
      }
    }

    final totalEfectivoEnCaja = fondoInicial + ventasEfectivo - gastos;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Caja y Turno'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (val) => _handleMenuAction(val, context),
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'history',
                child: Row(
                  children: [
                    Icon(Icons.history_rounded, color: AppColors.textSecondary),
                    SizedBox(width: 12),
                    Text('Historial de Turnos'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : CustomScrollView(
              slivers: [
                // ─── Status Banner ───
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      decoration: BoxDecoration(
                        gradient: isOpen
                            ? const LinearGradient(
                                colors: [Color(0xFF059669), Color(0xFF34D399)],
                              )
                            : null,
                        color: isOpen ? null : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        boxShadow: isOpen
                            ? [
                                BoxShadow(
                                  color: AppColors.success.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(
                                alpha: isOpen ? 0.2 : 0.0,
                              ),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: Icon(
                              isOpen
                                  ? Icons.lock_open_rounded
                                  : Icons.lock_outline_rounded,
                              color: isOpen
                                  ? Colors.white
                                  : AppColors.textTertiary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isOpen ? 'CAJA ABIERTA' : 'CAJA CERRADA',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: isOpen
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isOpen
                                      ? 'Apertura: ${DateFormat('hh:mm a').format(caja!.fechaApertura)} · ${user?.nombre ?? 'Usuario'}'
                                      : 'Sin turno activo',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isOpen
                                        ? Colors.white.withValues(alpha: 0.85)
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ─── Metrics Grid ───
                if (isOpen)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildMetricCard(
                                  'Fondo Inicial',
                                  currencyFmt.format(fondoInicial),
                                  Icons.input_rounded,
                                  AppColors.info,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: _buildMetricCard(
                                  'Ventas Efectivo',
                                  currencyFmt.format(ventasEfectivo),
                                  Icons.payments_rounded,
                                  AppColors.success,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            children: [
                              Expanded(
                                child: _buildMetricCard(
                                  'Ventas Tarjeta',
                                  currencyFmt.format(ventasTarjeta),
                                  Icons.credit_card_rounded,
                                  AppColors.info,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: _buildMetricCard(
                                  'Gastos / Retiros',
                                  '-${currencyFmt.format(gastos)}',
                                  Icons.money_off_rounded,
                                  AppColors.error,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          // Total highlight (Cash in drawer)
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.primaryLight,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.savings_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                const SizedBox(width: AppSpacing.lg),
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'EFECTIVO EN CAJA',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white70,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      '(Fondo + Ventas Efec. - Gastos)',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.white54,
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Text(
                                  currencyFmt.format(totalEfectivoEnCaja),
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // ─── Movements header ───
                if (isOpen)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xxl),
                      child: SectionHeader(
                        title: 'Movimientos del Turno',
                        actionLabel: '${provider.movimientos.length} registros',
                      ),
                    ),
                  ),

                // ─── Movement list ───
                if (isOpen && provider.movimientos.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.xl),
                      child: Center(
                        child: Text(
                          "Sin movimientos registrados",
                          style: TextStyle(color: AppColors.textTertiary),
                        ),
                      ),
                    ),
                  )
                else if (isOpen)
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, i) {
                      final mov = provider.movimientos[i];
                      final isExpense = mov.tipo == 'GASTO';
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
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(
                              color: isExpense
                                  ? AppColors.error.withValues(alpha: 0.2)
                                  : AppColors.border,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: isExpense
                                      ? AppColors.errorLight
                                      : AppColors.successLight,
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.sm,
                                  ),
                                ),
                                child: Icon(
                                  isExpense
                                      ? Icons.arrow_downward_rounded
                                      : Icons.arrow_upward_rounded,
                                  size: 18,
                                  color: isExpense
                                      ? AppColors.error
                                      : AppColors.success,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isExpense
                                          ? 'Gasto/Retiro'
                                          : mov.descripcion ?? 'Venta/Pago',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${DateFormat('HH:mm').format(mov.creadoAt)} · ${mov.metodo}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textTertiary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${isExpense ? '-' : '+'}${currencyFmt.format(mov.montoDisplay)}',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: isExpense
                                      ? AppColors.error
                                      : AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }, childCount: provider.movimientos.length),
                  ),

                // ─── Action Button ───
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: isOpen
                        ? Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton.icon(
                                  onPressed: () => _showCloseDialog(
                                    context,
                                    totalEfectivoEnCaja,
                                  ),
                                  icon: const Icon(Icons.lock_clock, size: 20),
                                  label: const Text(
                                    'CERRAR TURNO / CORTE DE CAJA',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.error,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              SizedBox(
                                width: double.infinity,
                                height: 44,
                                child: OutlinedButton.icon(
                                  onPressed: () => _showExpenseDialog(context),
                                  icon: const Icon(
                                    Icons.money_off_rounded,
                                    size: 18,
                                  ),
                                  label: const Text('Registrar Gasto / Retiro'),
                                ),
                              ),
                            ],
                          )
                        : SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: () => _showOpenDialog(context),
                              icon: const Icon(Icons.key_rounded, size: 20),
                              label: const Text(
                                'ABRIR CAJA',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.success,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
    );
  }

  Widget _buildMetricCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
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
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action, BuildContext context) {
    if (action == 'history') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Historial de turnos (próximamente)')),
      );
    }
  }

  void _showOpenDialog(BuildContext context) {
    final montoCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
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
                'Apertura de Caja',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.xxl),
              TextField(
                controller: montoCtrl,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Monto Inicial (Fondo)',
                  prefixIcon: Icon(Icons.attach_money_rounded),
                  hintText: 'Ej. 500',
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final monto = double.tryParse(montoCtrl.text) ?? 0.0;
                    if (monto <= 0) return;

                    Navigator.pop(ctx);
                    final success = await context
                        .read<CajaProvider>()
                        .abrirCaja(monto);

                    if (!context.mounted) return;
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Caja abierta exitosamente'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            context.read<CajaProvider>().error ??
                                'Error al abrir caja',
                          ),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.lock_open_rounded),
                  label: const Text('Abrir Caja'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  void _showCloseDialog(BuildContext context, double expectedCash) {
    final montoCtrl = TextEditingController(
      text: expectedCash.toStringAsFixed(2),
    );
    final notaCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
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
                'Cierre de Turno',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Se espera contar con Q${expectedCash.toStringAsFixed(2)} en efectivo.',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              TextField(
                controller: montoCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Monto Real en Caja (Arqueo)',
                  prefixIcon: Icon(Icons.attach_money_rounded),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: notaCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Notas de Cierre',
                  prefixIcon: Icon(Icons.note_alt_outlined),
                  hintText: 'Diferencias, observaciones...',
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final monto = double.tryParse(montoCtrl.text) ?? 0.0;
                    final nota = notaCtrl.text;

                    Navigator.pop(ctx);
                    final success = await context
                        .read<CajaProvider>()
                        .cerrarCaja(monto, nota);

                    if (!context.mounted) return;
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Turno cerrado exitosamente'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            context.read<CajaProvider>().error ??
                                'Error al cerrar caja',
                          ),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.lock_clock),
                  label: const Text('Cerrar Turno'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  void _showExpenseDialog(BuildContext context) {
    final montoCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Registrar Gasto / Retiro',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.xl),
              TextField(
                controller: montoCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Monto (Q)',
                  prefixIcon: Icon(Icons.money_off),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Descripción / Motivo',
                  prefixIcon: Icon(Icons.description),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    final monto = double.tryParse(montoCtrl.text) ?? 0;
                    if (monto <= 0) return;
                    Navigator.pop(ctx);
                    final success = await context
                        .read<CajaProvider>()
                        .registrarGasto(monto, descCtrl.text);
                    if (context.mounted && success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Gasto registrado')),
                      );
                    }
                  },
                  child: const Text('Registrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
