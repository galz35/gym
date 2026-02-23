import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/providers/reportes_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/membresias_provider.dart';
import '../../core/models/models.dart';

class ReportesScreen extends StatefulWidget {
  const ReportesScreen({super.key});

  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedRange = 'Semana';
  int _touchedPieIndex = -1;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Venta> _selectedDayVentas = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.sucursalId.isNotEmpty) {
        context.read<ReportesProvider>().loadResumen(
          DateTime.now(),
          sucursalId: auth.sucursalId,
        );
        context.read<MembresiasProvider>().loadMembresias(auth.sucursalId);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReportesProvider>();
    final membresiaProv = context.watch<MembresiasProvider>();
    final resumen =
        provider.resumen ??
        ResumenDia(
          asistencias: 0,
          ventasCantidad: 0,
          ventasTotal: 0,
          ingresos: 0,
          nuevosClientes: 0,
        );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes'),
        actions: [
          // ─── Export Menu ───
          PopupMenuButton<String>(
            icon: const Icon(Icons.ios_share_rounded),
            tooltip: 'Exportar / Compartir',
            onSelected: (val) => _handleExport(val),
            itemBuilder: (_) => [
              _exportMenuItem(
                Icons.picture_as_pdf_rounded,
                'Exportar PDF',
                'pdf',
                const Color(0xFFE53935),
              ),
              _exportMenuItem(
                Icons.table_chart_rounded,
                'Exportar Excel',
                'excel',
                const Color(0xFF43A047),
              ),
              const PopupMenuDivider(),
              _exportMenuItem(
                Icons.chat_rounded,
                'Enviar por WhatsApp',
                'whatsapp',
                const Color(0xFF25D366),
              ),
              _exportMenuItem(
                Icons.email_rounded,
                'Enviar por Email',
                'email',
                AppColors.info,
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Ingresos'),
            Tab(text: 'Membresías'),
            Tab(text: 'Asistencia'),
            Tab(text: 'Calendario'),
          ],
        ),
      ),
      body: Column(
        children: [
          // ─── Period Selector ───
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: ['Hoy', 'Semana', 'Mes', 'Personalizado'].map((period) {
                final sel = _selectedRange == period;
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: GestureDetector(
                    onTap: () {
                      if (period == 'Personalizado') {
                        _showDateRangePicker();
                      } else {
                        setState(() => _selectedRange = period);
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: sel ? AppColors.primary : AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        border: Border.all(
                          color: sel ? AppColors.primary : AppColors.border,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (period == 'Personalizado')
                            Icon(
                              Icons.date_range_rounded,
                              size: 14,
                              color: sel
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                          if (period == 'Personalizado')
                            const SizedBox(width: 4),
                          Text(
                            period,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: sel
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // ─── Tab Content ───
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildIngresosTab(resumen),
                _buildMembresiasTab(resumen, membresiaProv.activas.length),
                _buildAsistenciaTab(resumen, provider.asistenciaPorHora),
                _buildCalendarioTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // TAB 1: INGRESOS
  // ═══════════════════════════════════════════════
  Widget _buildIngresosTab(ResumenDia resumen) {
    final currency = NumberFormat.currency(
      locale: 'es_NI',
      symbol: 'C\$',
      decimalDigits: 2,
    );
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          // KPIs Row
          Row(
            children: [
              Expanded(
                child: KpiCard(
                  label: 'Ingresos Total',
                  value: currency.format(resumen.ingresos),
                  icon: Icons.trending_up_rounded,
                  color: AppColors.success,
                  trend: '+12%',
                  trendPositive: true,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: KpiCard(
                  label: 'Membresías',
                  value: currency.format(
                    resumen.ingresos - resumen.ventasTotal,
                  ), // Estimate
                  icon: Icons.card_membership_rounded,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: KpiCard(
                  label: 'Ventas POS',
                  value: currency.format(resumen.ventasTotal),
                  icon: Icons.shopping_cart_rounded,
                  color: AppColors.info,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: KpiCard(
                  label: 'Ticket Prom.',
                  value: 'C\$285',
                  icon: Icons.receipt_long_rounded,
                  color: const Color(0xFF8B5CF6),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xxl),

          // ─── Revenue Bar Chart ───
          _buildChartCard(
            title: 'Ingresos por Día',
            subtitle: 'Últimos 7 días',
            trendLabel: '+15.2%',
            trendPositive: true,
            child: SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 2000,
                    getDrawingHorizontalLine: (value) =>
                        FlLine(color: AppColors.borderLight, strokeWidth: 1),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 42,
                        getTitlesWidget: (val, meta) => Text(
                          'C\$${(val / 1000).toStringAsFixed(0)}k',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: _dayTitles,
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  barGroups: _revenueBarGroups(),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, gIdx, rod, rIdx) =>
                          BarTooltipItem(
                            'C\$${rod.toY.toStringAsFixed(0)}',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // ─── Revenue Breakdown ───
          _buildChartCard(
            title: 'Desglose de Ingresos',
            subtitle: 'Por concepto',
            child: Column(
              children: [
                _buildBreakdownRow(
                  'Membresías',
                  38000,
                  0.79,
                  AppColors.primary,
                ),
                _buildBreakdownRow('Ventas POS', 7450, 0.15, AppColors.info),
                _buildBreakdownRow(
                  'Visitas Diarias',
                  2800,
                  0.06,
                  AppColors.warning,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // TAB 2: MEMBRESÍAS
  // ═══════════════════════════════════════════════
  Widget _buildMembresiasTab(ResumenDia resumen, int activeCount) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: KpiCard(
                  label: 'Activas',
                  value: '$activeCount',
                  icon: Icons.check_circle_rounded,
                  color: AppColors.activeGreen,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: KpiCard(
                  label: 'Vencidas',
                  value: '18',
                  icon: Icons.cancel_rounded,
                  color: AppColors.expiredRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: KpiCard(
                  label: 'Nuevas (mes)',
                  value: '${resumen.nuevosClientes}',
                  icon: Icons.person_add_rounded,
                  color: AppColors.info,
                  trend: '+8%',
                  trendPositive: true,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: KpiCard(
                  label: 'Renovaciones',
                  value: '45',
                  icon: Icons.refresh_rounded,
                  color: const Color(0xFF8B5CF6),
                  trend: '+15%',
                  trendPositive: true,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xxl),

          // ─── Pie Chart ───
          _buildChartCard(
            title: 'Distribución por Plan',
            subtitle: 'Membresías activas',
            child: SizedBox(
              height: 220,
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback: (event, response) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  response == null ||
                                  response.touchedSection == null) {
                                _touchedPieIndex = -1;
                                return;
                              }
                              _touchedPieIndex =
                                  response.touchedSection!.touchedSectionIndex;
                            });
                          },
                        ),
                        sectionsSpace: 3,
                        centerSpaceRadius: 36,
                        sections: _membershipPieSections(),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _legendItem('Mensual', AppColors.primary, '40%'),
                        const SizedBox(height: AppSpacing.md),
                        _legendItem('Semanal', AppColors.info, '25%'),
                        const SizedBox(height: AppSpacing.md),
                        _legendItem('Trimestral', Colors.purple, '20%'),
                        const SizedBox(height: AppSpacing.md),
                        _legendItem('Diario', AppColors.warning, '10%'),
                        const SizedBox(height: AppSpacing.md),
                        _legendItem('Anual', const Color(0xFF8B5CF6), '5%'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // ─── Vencimientos próximos ───
          _buildChartCard(
            title: 'Vencimientos Próximos',
            subtitle: 'Próximos 30 días',
            child: Column(
              children: [
                _buildExpirationRow('Hoy', 3, AppColors.error),
                _buildExpirationRow('Esta semana', 8, AppColors.warning),
                _buildExpirationRow('Próxima semana', 5, AppColors.info),
                _buildExpirationRow('En 30 días', 12, AppColors.textTertiary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // TAB 3: ASISTENCIA
  // ═══════════════════════════════════════════════
  Widget _buildAsistenciaTab(
    ResumenDia resumen,
    List<AsistenciaPorHora> asistenciaData,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: KpiCard(
                  label: 'Check-ins Hoy',
                  value: '${resumen.asistencias}',
                  icon: Icons.how_to_reg_rounded,
                  color: AppColors.primary,
                  trend: '+12%',
                  trendPositive: true,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: KpiCard(
                  label: 'Hora Pico',
                  value: '18:00',
                  icon: Icons.schedule_rounded,
                  color: AppColors.warning,
                  subtitle: '23 personas',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: KpiCard(
                  label: 'Prom. Diario',
                  value: '52',
                  icon: Icons.show_chart_rounded,
                  color: AppColors.info,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: KpiCard(
                  label: 'Tasa Asistencia',
                  value: '68%',
                  icon: Icons.percent_rounded,
                  color: AppColors.success,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xxl),

          // ─── Attendance by Hour ───
          _buildChartCard(
            title: 'Asistencia por Hora',
            subtitle: 'Distribución del día',
            child: SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 5,
                    getDrawingHorizontalLine: (value) =>
                        FlLine(color: AppColors.borderLight, strokeWidth: 1),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (val, meta) => Text(
                          '${val.toInt()}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: _hourTitles,
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  barGroups: _attendanceBarGroups(asistenciaData),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, gIdx, rod, rIdx) =>
                          BarTooltipItem(
                            '${rod.toY.toInt()} personas',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // ─── Weekly trend ───
          _buildChartCard(
            title: 'Tendencia Semanal',
            subtitle: 'Check-ins por día',
            child: SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 10,
                    getDrawingHorizontalLine: (value) =>
                        FlLine(color: AppColors.borderLight, strokeWidth: 1),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (val, meta) => Text(
                          '${val.toInt()}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: _dayTitles,
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 42),
                        FlSpot(1, 58),
                        FlSpot(2, 45),
                        FlSpot(3, 52),
                        FlSpot(4, 65),
                        FlSpot(5, 48),
                        FlSpot(6, 30),
                      ],
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, pct, barData, idx) =>
                            FlDotCirclePainter(
                              radius: 4,
                              color: AppColors.primary,
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (spots) => spots
                          .map(
                            (s) => LineTooltipItem(
                              '${s.y.toInt()} check-ins',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildCalendarioTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChartCard(
            title: 'Calendario de Actividad',
            subtitle: 'Selecciona un día para ver detalle',
            child: TableCalendar(
              locale: 'es_ES',
              firstDay: DateTime.utc(2025, 1, 1),
              lastDay: DateTime.now(),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: CalendarFormat.month,
              startingDayOfWeek: StartingDayOfWeek.monday,
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
                selectedDecoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                markerDecoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
              onDaySelected: _onDaySelected,
            ),
          ),
          if (_selectedDay != null) ...[
            const SizedBox(height: AppSpacing.xl),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'Resumen del ${DateFormat('dd MMMM, yyyy', 'es').format(_selectedDay!)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (context.watch<ReportesProvider>().isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_selectedDayVentas.isEmpty)
              const EmptyState(
                icon: Icons.event_busy_rounded,
                title: 'Sin ventas',
                subtitle: 'No se registraron ventas en este día',
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _selectedDayVentas.length,
                itemBuilder: (context, index) {
                  final venta = _selectedDayVentas[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.info.withValues(alpha: 0.1),
                        child: const Icon(
                          Icons.shopping_bag_rounded,
                          color: AppColors.info,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        venta.clienteNombre ?? 'Cliente General',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Total: C\$${venta.totalDisplay.toStringAsFixed(2)}',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      trailing: Text(
                        DateFormat('HH:mm').format(venta.creadoAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });

    final auth = context.read<AuthProvider>();
    final provider = context.read<ReportesProvider>();

    // Start range: 00:00:00, End range: 23:59:59
    final desde = DateTime(
      selectedDay.year,
      selectedDay.month,
      selectedDay.day,
    );
    final hasta = DateTime(
      selectedDay.year,
      selectedDay.month,
      selectedDay.day,
      23,
      59,
      59,
    );

    final ventas = await provider.getVentasHistorial(
      desde: desde,
      hasta: hasta,
      sucursalId: auth.sucursalId,
    );

    setState(() {
      _selectedDayVentas = ventas;
    });
  }

  // ═══════════════════════════════════════════════
  // SHARED BUILDERS
  // ═══════════════════════════════════════════════

  Widget _buildChartCard({
    required String title,
    required String subtitle,
    required Widget child,
    String? trendLabel,
    bool trendPositive = true,
  }) {
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (trendLabel != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs + 2,
                  ),
                  decoration: BoxDecoration(
                    color: trendPositive
                        ? AppColors.successLight
                        : AppColors.errorLight,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        trendPositive
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                        size: 14,
                        color: trendPositive
                            ? AppColors.success
                            : AppColors.error,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        trendLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: trendPositive
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          child,
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(
    String label,
    double amount,
    double pct,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: AppColors.surfaceVariant,
                    color: color,
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'C\$${amount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${(pct * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpirationRow(String period, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Center(
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              period,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: AppColors.textTertiary,
          ),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color, String pct) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          pct,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  PopupMenuItem<String> _exportMenuItem(
    IconData icon,
    String text,
    String value,
    Color color,
  ) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // DATA GENERATORS
  // ═══════════════════════════════════════════════

  List<BarChartGroupData> _revenueBarGroups() {
    final data = [5200.0, 7800.0, 4500.0, 8900.0, 9500.0, 6700.0, 5650.0];
    return List.generate(
      7,
      (i) => BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: data[i],
            gradient: const LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [AppColors.primary, AppColors.primaryLight],
            ),
            width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _attendanceBarGroups(
    List<AsistenciaPorHora> asistenciaData,
  ) {
    // 6AM to 10PM (17 hours)
    final data = List.generate(17, (index) {
      final hour = 6 + index;
      final found = asistenciaData.firstWhere(
        (e) => e.hora == hour,
        orElse: () => AsistenciaPorHora(hora: hour, cantidad: 0),
      );
      return found.cantidad;
    });

    return List.generate(
      data.length,
      (i) => BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: data[i].toDouble(),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [AppColors.info, AppColors.info.withValues(alpha: 0.6)],
            ),
            width: 14,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _membershipPieSections() {
    final data = [
      {'value': 40.0, 'title': 'Mensual', 'color': AppColors.primary},
      {'value': 25.0, 'title': 'Semanal', 'color': AppColors.info},
      {'value': 20.0, 'title': 'Trimestral', 'color': Colors.purple},
      {'value': 10.0, 'title': 'Diario', 'color': AppColors.warning},
      {'value': 5.0, 'title': 'Anual', 'color': const Color(0xFF8B5CF6)},
    ];
    return List.generate(data.length, (i) {
      final isTouched = i == _touchedPieIndex;
      return PieChartSectionData(
        value: data[i]['value'] as double,
        title: isTouched ? data[i]['title'] as String : '',
        color: data[i]['color'] as Color,
        radius: isTouched ? 60 : 50,
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      );
    });
  }

  static Widget _dayTitles(double value, TitleMeta meta) {
    const titles = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    if (value.toInt() >= titles.length) return const SizedBox.shrink();
    return SideTitleWidget(
      meta: meta,
      child: Text(
        titles[value.toInt()],
        style: const TextStyle(
          fontSize: 10,
          color: AppColors.textTertiary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  static Widget _hourTitles(double value, TitleMeta meta) {
    final hour = 6 + value.toInt();
    if (value.toInt() % 2 != 0) return const SizedBox.shrink();
    return SideTitleWidget(
      meta: meta,
      child: Text(
        '${hour}h',
        style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // ACTIONS
  // ═══════════════════════════════════════════════

  void _handleExport(String type) {
    final tabName = [
      'Ingresos',
      'Membresías',
      'Asistencia',
    ][_tabController.index];
    IconData icon;
    Color color;
    String message;

    switch (type) {
      case 'pdf':
        icon = Icons.picture_as_pdf_rounded;
        color = const Color(0xFFE53935);
        message = 'Generando PDF de $tabName...';
        break;
      case 'excel':
        icon = Icons.table_chart_rounded;
        color = const Color(0xFF43A047);
        message = 'Generando Excel de $tabName...';
        break;
      case 'whatsapp':
        icon = Icons.chat_rounded;
        color = const Color(0xFF25D366);
        message = 'Preparando reporte para WhatsApp...';
        break;
      case 'email':
        icon = Icons.email_rounded;
        color = AppColors.info;
        message = 'Preparando email con reporte...';
        break;
      default:
        return;
    }

    // Show generating feedback
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.lg),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              message,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            LinearProgressIndicator(
              color: color,
              backgroundColor: color.withValues(alpha: 0.15),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );

    // Simulate generation delay
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pop(context);
      _showExportSuccess(type, tabName);
    });
  }

  void _showExportSuccess(String type, String tabName) {
    final snackMessage = switch (type) {
      'pdf' => '📄 PDF de $tabName generado exitosamente',
      'excel' => '📊 Excel de $tabName generado exitosamente',
      'whatsapp' => '✅ Reporte enviado por WhatsApp',
      'email' => '📧 Reporte enviado por email',
      _ => 'Operación completada',
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(snackMessage),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.success,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        action: SnackBarAction(
          label: 'VER',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _showDateRangePicker() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2025),
      lastDate: DateTime.now(),
      currentDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(
            ctx,
          ).colorScheme.copyWith(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (range != null) {
      setState(() => _selectedRange = 'Personalizado');
    }
  }
}
