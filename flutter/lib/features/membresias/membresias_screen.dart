import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/membresias_provider.dart';
import '../../core/providers/clientes_provider.dart';
import '../../core/models/models.dart';

class MembresiasScreen extends StatefulWidget {
  const MembresiasScreen({super.key});

  @override
  State<MembresiasScreen> createState() => _MembresiasScreenState();
}

class _MembresiasScreenState extends State<MembresiasScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final TextEditingController _searchController;
  String _filtroEstado = 'TODAS';
  String? _filtroPlanId;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _tabController = TabController(length: 4, vsync: this);
    _loadMembresias();
  }

  Future<void> _loadMembresias() async {
    final auth = context.read<AuthProvider>();
    if (auth.sucursalId.isNotEmpty) {
      context.read<MembresiasProvider>().loadMembresias(auth.sucursalId);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MembresiasProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Membresías'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Activas'),
            Tab(text: 'Por Vencer'),
            Tab(text: 'Vencidas'),
            Tab(text: 'Todas'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Simple search filter prompt
              showSearch(
                context: context,
                delegate: MembresiaSearchDelegate(provider.membresias),
              );
            },
            icon: const Icon(Icons.search_rounded),
            tooltip: 'Buscar',
          ),
          IconButton(
            onPressed: () => _showFilterDialog(),
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'Filtrar',
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildMembresiasList(provider.activas),
                _buildMembresiasList(
                  provider.membresias.where((m) {
                    final days = m.fin.difference(DateTime.now()).inDays;
                    return m.estado == 'ACTIVA' && days >= 0 && days <= 7;
                  }).toList(),
                ),
                _buildMembresiasList(provider.vencidas),
                _buildMembresiasList(provider.membresias),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context),
        icon: const Icon(Icons.add_rounded, size: 20),
        label: const Text('Nueva Membresía'),
      ),
    );
  }

  Widget _buildMembresiasList(List<MembresiaCliente> list) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.card_membership_rounded,
              size: 48,
              color: AppColors.textTertiary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            const Text(
              'No hay membresías en esta categoría',
              style: TextStyle(fontSize: 14, color: AppColors.textTertiary),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMembresias,
      color: AppColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: list.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          final m = list[index];
          final isActive = m.estado == 'ACTIVA';
          final daysLeft = m.fin.difference(DateTime.now()).inDays;

          Color statusRunColor = AppColors.textSecondary;
          if (m.estado == 'ACTIVA') {
            statusRunColor = AppColors.activeGreen;
            if (daysLeft <= 5) statusRunColor = AppColors.warning;
          } else if (m.estado == 'VENCIDA') {
            statusRunColor = AppColors.expiredRed;
          }

          return AnimatedListItem(
            index: index,
            child: InkWell(
              onTap: () => _showMembresiaDetail(m),
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppColors.cardShadow,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: statusRunColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Icon(
                            Icons.card_membership_rounded,
                            color: statusRunColor,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                m.clienteNombre ?? 'Cliente',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                m.planNombre ?? 'Plan',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        StatusPill(
                          text: m.estado,
                          color: statusRunColor,
                          small: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Divider(height: 1),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildMiniInfo(
                          Icons.calendar_today_rounded,
                          'Inicio',
                          DateFormat('dd/MM/yy').format(m.inicio),
                        ),
                        _buildMiniInfo(
                          Icons.event_rounded,
                          'Fin',
                          DateFormat('dd/MM/yy').format(m.fin),
                          isWarning: isActive && daysLeft <= 5,
                        ),
                        _buildMiniInfo(
                          Icons.directions_walk_rounded,
                          'Restantes',
                          m.visitasRestantes?.toString() ?? 'Inf',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMiniInfo(
    IconData icon,
    String label,
    String value, {
    bool isWarning = false,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: isWarning ? AppColors.warning : AppColors.textTertiary,
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textTertiary,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isWarning ? AppColors.warning : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showMembresiaDetail(MembresiaCliente m) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (ctx, scroll) {
          final daysLeft = m.fin.difference(DateTime.now()).inDays;
          final isActive = m.estado == 'ACTIVA';

          return SingleChildScrollView(
            controller: scroll,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
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
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: isActive
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : AppColors.border,
                    child: Icon(
                      Icons.card_membership_rounded,
                      size: 36,
                      color: isActive
                          ? AppColors.primary
                          : AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    m.clienteNombre ?? 'Cliente',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    m.planNombre ?? 'Plan',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  StatusPill(
                    text: m.estado,
                    color: isActive
                        ? AppColors.activeGreen
                        : AppColors.expiredRed,
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Details
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Column(
                      children: [
                        InfoRow(
                          label: 'Inicio',
                          value: DateFormat('dd MMM yyyy').format(m.inicio),
                          icon: Icons.calendar_today_rounded,
                        ),
                        InfoRow(
                          label: 'Vencimiento',
                          value: DateFormat('dd MMM yyyy').format(m.fin),
                          icon: Icons.event_busy_rounded,
                        ),
                        InfoRow(
                          label: 'Días Restantes',
                          value: isActive ? '$daysLeft días' : '-',
                          icon: Icons.timer_rounded,
                        ),
                        InfoRow(
                          label: 'Visitas Restantes',
                          value: m.visitasRestantes?.toString() ?? 'Ilimitadas',
                          icon: Icons.directions_walk_rounded,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),
                  if (m.estado == 'ACTIVA') ...[
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          Navigator.pop(context);
                          // Implementation of freeze
                          final prov = context.read<MembresiasProvider>();
                          final success = await prov.setEstado(
                            m.id,
                            'CONGELADA',
                          );
                          if (!mounted) return;
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Membresía congelada'),
                              ),
                            );
                            _loadMembresias();
                          }
                        },
                        icon: const Icon(Icons.pause_circle_outline_rounded),
                        label: const Text('Congelar Membresía'),
                      ),
                    ),
                  ] else if (m.estado == 'VENCIDA' ||
                      m.estado == 'CONGELADA') ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showRenewDialog(m);
                        },
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Renovar / Activar'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    // Load dependencies
    context.read<ClientesProvider>().loadClientes();
    context.read<PlanesProvider>().loadPlanes();

    Cliente? selectedCliente;
    PlanMembresia? selectedPlan;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final clientes = ctx.watch<ClientesProvider>().clientes;
          final planes = ctx.watch<PlanesProvider>().planesActivos;

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nueva Membresía',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  DropdownButtonFormField<Cliente>(
                    decoration: const InputDecoration(
                      labelText: 'Cliente',
                      prefixIcon: Icon(Icons.person),
                    ),
                    initialValue: selectedCliente,
                    isExpanded: true,
                    items: clientes
                        .map(
                          (c) =>
                              DropdownMenuItem(value: c, child: Text(c.nombre)),
                        )
                        .toList(),
                    onChanged: (c) => setModalState(() => selectedCliente = c),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  DropdownButtonFormField<PlanMembresia>(
                    decoration: const InputDecoration(
                      labelText: 'Plan',
                      prefixIcon: Icon(Icons.card_membership),
                    ),
                    initialValue: selectedPlan,
                    isExpanded: true,
                    items: planes
                        .map(
                          (p) => DropdownMenuItem(
                            value: p,
                            child: Text('${p.nombre} - Q${p.precioDisplay}'),
                          ),
                        )
                        .toList(),
                    onChanged: (p) => setModalState(() => selectedPlan = p),
                  ),

                  const SizedBox(height: AppSpacing.xxl),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed:
                          (selectedCliente == null || selectedPlan == null)
                          ? null
                          : () async {
                              Navigator.pop(ctx);
                              final auth = context.read<AuthProvider>();
                              final success = await context
                                  .read<MembresiasProvider>()
                                  .createMembresia({
                                    'cliente_id': selectedCliente!.id,
                                    'plan_id': selectedPlan!.id,
                                    'sucursal_id': auth.sucursalId,
                                    'inicio': DateTime.now().toIso8601String(),
                                  });

                              if (!context.mounted) return;
                              if (success != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Membresía creada con éxito'),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                                _loadMembresias();
                              }
                            },
                      child: const Text('Asignar Membresía'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showRenewDialog(MembresiaCliente m) {
    // Similar to create but for a specific client
    PlanMembresia? selectedPlan;
    context.read<PlanesProvider>().loadPlanes();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final planes = ctx.watch<PlanesProvider>().planesActivos;
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Renovar a ${m.clienteNombre}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  DropdownButtonFormField<PlanMembresia>(
                    decoration: const InputDecoration(
                      labelText: 'Seleccionar Plan',
                    ),
                    items: planes
                        .map(
                          (p) =>
                              DropdownMenuItem(value: p, child: Text(p.nombre)),
                        )
                        .toList(),
                    onChanged: (p) => setModalState(() => selectedPlan = p),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: selectedPlan == null
                          ? null
                          : () async {
                              Navigator.pop(ctx);
                              final auth = context.read<AuthProvider>();
                              final success = await context
                                  .read<MembresiasProvider>()
                                  .renovar(m.id, {
                                    'plan_id': selectedPlan!.id,
                                    'sucursal_id': auth.sucursalId,
                                  });
                              if (!mounted) return;
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Membresía renovada'),
                                  ),
                                );
                                _loadMembresias();
                              }
                            },
                      child: const Text('Confirmar Renovación'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final planes = context.read<PlanesProvider>().planes;

          return Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filtrar Membresías',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.xl),
                const Text(
                  'Estado',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Wrap(
                  spacing: 8,
                  children: ['TODAS', 'ACTIVA', 'VENCIDA', 'CONGELADA'].map((
                    e,
                  ) {
                    final isSel = _filtroEstado == e;
                    return choiceChip(e, isSel, (s) {
                      if (s) {
                        setModalState(() => _filtroEstado = e);
                        setState(() => _filtroEstado = e);
                      }
                    });
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'Plan',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                DropdownButtonFormField<String?>(
                  initialValue: _filtroPlanId,
                  decoration: const InputDecoration(
                    hintText: 'Todos los planes',
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Todos los planes'),
                    ),
                    ...planes.map(
                      (p) =>
                          DropdownMenuItem(value: p.id, child: Text(p.nombre)),
                    ),
                  ],
                  onChanged: (v) {
                    setModalState(() => _filtroPlanId = v);
                    setState(() => _filtroPlanId = v);
                  },
                ),
                const SizedBox(height: AppSpacing.xxl),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Aplicar Filtros'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget choiceChip(String label, bool selected, Function(bool) onSelected) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      labelStyle: TextStyle(
        color: selected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}

class MembresiaSearchDelegate extends SearchDelegate {
  final List<MembresiaCliente> list;
  MembresiaSearchDelegate(this.list);

  @override
  List<Widget>? buildActions(BuildContext context) => [
    IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
  ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, null),
  );

  @override
  Widget buildResults(BuildContext context) => _buildList();

  @override
  Widget buildSuggestions(BuildContext context) => _buildList();

  Widget _buildList() {
    final results = list
        .where(
          (m) =>
              (m.clienteNombre?.toLowerCase().contains(query.toLowerCase()) ??
                  false) ||
              (m.planNombre?.toLowerCase().contains(query.toLowerCase()) ??
                  false),
        )
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, i) => ListTile(
        title: Text(results[i].clienteNombre ?? 'Cliente'),
        subtitle: Text(results[i].planNombre ?? 'Plan'),
        onTap: () => close(context, results[i]),
      ),
    );
  }
}
