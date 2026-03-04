import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/clientes_provider.dart';
import '../../core/models/models.dart';
import '../../core/providers/asistencia_provider.dart';
import '../../core/providers/membresias_provider.dart';
import '../../core/providers/dashboard_provider.dart';
import '../../core/providers/caja_provider.dart';

class CheckinScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigate;
  const CheckinScreen({super.key, this.onNavigate});

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen>
    with TickerProviderStateMixin {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  String _searchQuery = '';
  bool _isProcessing = false;

  // Feedback overlay
  _FeedbackData? _feedback;
  late AnimationController _feedbackAnim;

  @override
  void initState() {
    super.initState();
    _feedbackAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.empresaId.isNotEmpty) {
        context.read<ClientesProvider>().loadClientes();
        context.read<PlanesProvider>().loadPlanes();
        context.read<MembresiasProvider>().loadMembresias(auth.sucursalId);
        context.read<DashboardProvider>().loadDashboard(auth.sucursalId);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _feedbackAnim.dispose();
    super.dispose();
  }

  // ─── CLIENT SEARCH ─────────────────────────────────────────────
  List<Cliente> get _filteredClients {
    final provider = context.read<ClientesProvider>();
    if (_searchQuery.isEmpty) return provider.clientes.take(20).toList();
    final q = _searchQuery.toLowerCase();
    return provider.clientes
        .where(
          (c) =>
              c.nombre.toLowerCase().contains(q) ||
              (c.telefono?.contains(q) ?? false) ||
              (c.documento?.toLowerCase().contains(q) ?? false),
        )
        .take(15)
        .toList();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _searchQuery = '');
    _focusNode.requestFocus();
  }

  // ─── MEMBERSHIP HELPER ─────────────────────────────────────────
  MembresiaCliente? _getMembresiaActiva(String clienteId) {
    try {
      final membProv = context.read<MembresiasProvider>();
      return membProv.membresias.firstWhere(
        (m) =>
            m.clienteId == clienteId &&
            m.estado == 'ACTIVA' &&
            m.fin.isAfter(DateTime.now()),
      );
    } catch (_) {
      return null;
    }
  }

  // ─── CHECK-IN / CHECK-OUT ─────────────────────────────────────
  Future<void> _doCheckin(Cliente client) async {
    setState(() => _isProcessing = true);
    final auth = context.read<AuthProvider>();
    final asisProv = context.read<AsistenciaProvider>();
    final res = await asisProv.registrarAsistencia(client.id, auth.sucursalId);
    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (res != null && res.resultado == 'PERMITIDO') {
      HapticFeedback.heavyImpact();
      _showFeedback(true, '✅ ENTRADA', client.nombre, Icons.login);
      if (mounted) {
        context.read<DashboardProvider>().loadDashboard(auth.sucursalId);
      }
    } else {
      HapticFeedback.vibrate();
      _showFeedback(
        false,
        '⛔ DENEGADO',
        res?.nota ?? asisProv.error ?? 'Sin membresía activa',
        Icons.block,
      );
      _showRenewSheet(client);
    }
  }

  Future<void> _doCheckout(Cliente client) async {
    setState(() => _isProcessing = true);
    final auth = context.read<AuthProvider>();
    final asisProv = context.read<AsistenciaProvider>();
    final res = await asisProv.registrarSalida(client.id, auth.sucursalId);
    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (res != null) {
      HapticFeedback.mediumImpact();
      _showFeedback(true, '👋 SALIDA', client.nombre, Icons.logout);
      if (mounted) {
        context.read<DashboardProvider>().loadDashboard(auth.sucursalId);
      }
    } else {
      _showFeedback(
        false,
        'ERROR',
        asisProv.error ?? 'No se encontró entrada activa',
        Icons.error,
      );
    }
  }

  // ─── REGISTER NEW + CHECK IN ──────────────────────────────────
  Future<void> _registerAndCheckin(
    String name,
    String phone,
    String cedula,
    File? photo,
    PlanMembresia? plan,
  ) async {
    setState(() => _isProcessing = true);
    try {
      final clientesProv = context.read<ClientesProvider>();
      final membProv = context.read<MembresiasProvider>();
      final auth = context.read<AuthProvider>();
      final cajaProv = context.read<CajaProvider>();

      final Map<String, dynamic> data = {'nombre': name.trim()};
      if (phone.trim().isNotEmpty) data['telefono'] = phone.trim();
      if (cedula.trim().isNotEmpty) data['documento'] = cedula.trim();

      final client = await clientesProv.createCliente(data);
      if (client == null)
        throw Exception(clientesProv.error ?? 'Error creando cliente');

      if (photo != null) {
        await clientesProv.uploadFoto(client.id, photo);
      }

      if (plan != null) {
        // Con plan: crear membresía, cobrar y dar entrada
        final mb = await membProv.createMembresia({
          'cliente_id': client.id,
          'plan_id': plan.id,
          'sucursal_id': auth.sucursalId,
          if (cajaProv.cajaAbierta != null) 'caja_id': cajaProv.cajaAbierta!.id,
          'metodo_pago': 'EFECTIVO',
        });
        if (mb == null)
          throw Exception(membProv.error ?? 'Error creando membresía');

        if (!mounted) return;
        // Ahora sí dar entrada porque ya tiene membresía activa
        final asisProv = context.read<AsistenciaProvider>();
        final res = await asisProv.registrarAsistencia(
          client.id,
          auth.sucursalId,
        );
        if (!mounted) return;

        if (res != null && res.resultado == 'PERMITIDO') {
          _showFeedback(
            true,
            '💰 PAGADO + ENTRADA',
            client.nombre,
            Icons.celebration,
          );
        } else {
          // Membresía creada pero checkin falló - al menos le notificamos
          _showFeedback(
            true,
            '💰 PAGADO',
            '${client.nombre}\n(Membresía asignada)',
            Icons.check_circle,
          );
        }
      } else {
        // Sin plan: solo registrar al cliente, sin intentar checkin
        if (!mounted) return;
        _showFeedback(true, '✅ REGISTRADO', client.nombre, Icons.person_add);
      }

      if (mounted) {
        context.read<DashboardProvider>().loadDashboard(auth.sucursalId);
        _clearSearch();
      }
    } catch (e) {
      if (mounted) {
        _showFeedback(false, 'ERROR', e.toString(), Icons.error);
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // ─── FEEDBACK OVERLAY ─────────────────────────────────────────
  void _showFeedback(
    bool success,
    String title,
    String subtitle,
    IconData icon,
  ) {
    setState(() => _feedback = _FeedbackData(success, title, subtitle, icon));
    _feedbackAnim.forward(from: 0);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _feedbackAnim.reverse().then((_) {
          if (mounted) setState(() => _feedback = null);
        });
      }
    });
  }

  // ─── RENEW / PAY SHEET ────────────────────────────────────────
  void _showRenewSheet(Cliente client) {
    final planes = context.read<PlanesProvider>().planesActivos;
    final fmt = NumberFormat.currency(
      locale: 'es',
      symbol: 'C\$',
      decimalDigits: 0,
    );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.error,
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Membresía vencida',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.error,
                    ),
                  ),
                  Text(client.nombre, style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Cobrar en efectivo y entrar:',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const SizedBox(height: 12),
            ...planes.map(
              (p) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () async {
                      Navigator.pop(ctx);
                      setState(() => _isProcessing = true);
                      final auth = context.read<AuthProvider>();
                      final cajaProv = context.read<CajaProvider>();
                      final res = await context
                          .read<MembresiasProvider>()
                          .createMembresia({
                            'cliente_id': client.id,
                            'plan_id': p.id,
                            'sucursal_id': auth.sucursalId,
                            if (cajaProv.cajaAbierta != null)
                              'caja_id': cajaProv.cajaAbierta!.id,
                            'metodo_pago': 'EFECTIVO',
                          });
                      if (res != null) {
                        await _doCheckin(client);
                      } else {
                        setState(() => _isProcessing = false);
                        if (mounted) {
                          _showFeedback(
                            false,
                            'ERROR',
                            'No se pudo cobrar',
                            Icons.error,
                          );
                        }
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              p.nombre,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            fmt.format(p.precioDisplay),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('CANCELAR', style: TextStyle(fontSize: 16)),
            ),
            SizedBox(height: MediaQuery.of(ctx).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  // ─── NEW CLIENT SHEET ─────────────────────────────────────────
  void _showNewClientSheet(String initialName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _NewClientForm(
        initialName: initialName,
        onSave: (name, phone, cedula, photo, plan) {
          Navigator.pop(ctx);
          _registerAndCheckin(name, phone, cedula, photo, plan);
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // ── TOP BAR: Daily Stats + Search ─────────────
                _buildHeader(cs, isDark),
                // ── MAIN CONTENT ──────────────────────────────
                Expanded(child: _buildBody(cs, isDark)),
              ],
            ),
            // ── PROCESSING OVERLAY ────────────────────────────
            if (_isProcessing) _buildProcessingOverlay(),
            // ── FEEDBACK TOAST ────────────────────────────────
            if (_feedback != null) _buildFeedbackOverlay(),
          ],
        ),
      ),
    );
  }

  // ─── HEADER ───────────────────────────────────────────────────
  Widget _buildHeader(ColorScheme cs, bool isDark) {
    final dashboard = context.watch<DashboardProvider>();
    final resumen = dashboard.resumen;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark : AppColors.primarySurface,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // ── Daily Stats Row ──
          Row(
            children: [
              _StatChip(
                icon: Icons.login,
                label: '${resumen?.asistencias ?? 0}',
                color: AppColors.success,
                tooltip: 'Entradas hoy',
              ),
              const SizedBox(width: 10),
              _StatChip(
                icon: Icons.logout,
                label: '${resumen?.salidas ?? 0}',
                color: AppColors.warning,
                tooltip: 'Salidas hoy',
              ),
              const Spacer(),
              Text(
                DateFormat('EEEE d MMM', 'es').format(DateTime.now()),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // ── Search Bar ──
          Container(
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(18),
              boxShadow: isDark
                  ? AppColors.cardShadowDark
                  : AppColors.cardShadow,
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                hintText: 'Buscar cliente...',
                hintStyle: TextStyle(
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 16, right: 8),
                  child: Icon(Icons.search, size: 28),
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 52),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 24),
                        onPressed: _clearSearch,
                      )
                    : null,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 18),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
        ],
      ),
    );
  }

  // ─── BODY ─────────────────────────────────────────────────────
  Widget _buildBody(ColorScheme cs, bool isDark) {
    final clients = _filteredClients;
    final showNewBtn =
        _searchQuery.isNotEmpty &&
        (clients.isEmpty ||
            !clients.any(
              (c) => c.nombre.toLowerCase() == _searchQuery.toLowerCase(),
            ));

    return CustomScrollView(
      slivers: [
        // ── New Client Button ──
        if (showNewBtn)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Material(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(18),
                elevation: 2,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    _focusNode.unfocus();
                    _showNewClientSheet(_searchQuery);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.person_add,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'REGISTRAR NUEVO CLIENTE',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _searchQuery.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white70,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

        // ── Client List ──
        if (clients.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _buildClientCard(clients[i], isDark),
                childCount: clients.length,
              ),
            ),
          ),

        // ── Empty State ──
        if (clients.isEmpty && _searchQuery.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: AppColors.textTertiary.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Escribe un nombre para buscar\no registrar un cliente',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // ── Activity Feed ──
        if (context.watch<DashboardProvider>().ultimasAsistencias.isNotEmpty &&
            _searchQuery.isEmpty) ...[
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(
                'ACTIVIDAD RECIENTE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  final a = context
                      .read<DashboardProvider>()
                      .ultimasAsistencias[i];
                  final isSalida = a.resultado == 'SALIDA';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(ctx).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.border.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSalida ? Icons.logout : Icons.login,
                            color: isSalida
                                ? AppColors.warning
                                : AppColors.success,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              a.clienteNombre ?? 'Cliente',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            DateFormat('HH:mm').format(a.fechaHora),
                            style: const TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: context
                    .read<DashboardProvider>()
                    .ultimasAsistencias
                    .length,
              ),
            ),
          ),
        ],

        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }

  // ─── CLIENT CARD (THE STAR) ───────────────────────────────────
  Widget _buildClientCard(Cliente client, bool isDark) {
    final memb = _getMembresiaActiva(client.id);
    final bool activa = memb != null;
    final bool porVencer =
        activa && memb.fin.difference(DateTime.now()).inDays <= 3;

    Color badgeColor = activa
        ? (porVencer ? AppColors.warning : AppColors.success)
        : AppColors.error;
    String badgeText = activa
        ? (porVencer ? 'Por vencer' : memb.planNombre ?? 'Activa')
        : 'Sin plan';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
          boxShadow: isDark ? AppColors.cardShadowDark : AppColors.cardShadow,
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // ── Avatar ──
              _buildAvatar(client, 26),
              const SizedBox(width: 14),
              // ── Info ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      client.nombre,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: badgeColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // ── INLINE ACTION BUTTONS ──
              if (activa) ...[
                _ActionCircle(
                  icon: Icons.login,
                  color: AppColors.success,
                  label: 'ENTRADA',
                  onTap: () => _doCheckin(client),
                ),
                const SizedBox(width: 8),
                _ActionCircle(
                  icon: Icons.logout,
                  color: AppColors.warning,
                  label: 'SALIDA',
                  onTap: () => _doCheckout(client),
                ),
              ] else ...[
                _ActionCircle(
                  icon: Icons.attach_money,
                  color: AppColors.primary,
                  label: 'COBRAR',
                  onTap: () => _showRenewSheet(client),
                ),
                const SizedBox(width: 8),
                _ActionCircle(
                  icon: Icons.login,
                  color: AppColors.success.withValues(alpha: 0.6),
                  label: 'CORTESÍA',
                  onTap: () => _doCheckin(client),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(Cliente client, double radius) {
    if (client.fotoUrl != null && client.fotoUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: CachedNetworkImageProvider(client.fotoUrl!),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primary.withValues(alpha: 0.15),
      child: Text(
        client.nombre.isNotEmpty ? client.nombre[0].toUpperCase() : '?',
        style: TextStyle(
          fontSize: radius,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
        ),
      ),
    );
  }

  // ─── PROCESSING OVERLAY ───────────────────────────────────────
  Widget _buildProcessingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.45),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Procesando...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── FEEDBACK OVERLAY ─────────────────────────────────────────
  Widget _buildFeedbackOverlay() {
    final fb = _feedback!;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: FadeTransition(
        opacity: CurvedAnimation(parent: _feedbackAnim, curve: Curves.easeOut),
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
              .animate(
                CurvedAnimation(
                  parent: _feedbackAnim,
                  curve: Curves.easeOutBack,
                ),
              ),
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: fb.success ? AppColors.success : AppColors.error,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: (fb.success ? AppColors.success : AppColors.error)
                      .withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(fb.icon, color: Colors.white, size: 36),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        fb.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        fb.subtitle,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
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
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// SMALL WIDGETS
// ═══════════════════════════════════════════════════════════════════

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String tooltip;
  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCircle extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;
  const _ActionCircle({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(14),
        elevation: 1,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }
}

class _FeedbackData {
  final bool success;
  final String title;
  final String subtitle;
  final IconData icon;
  _FeedbackData(this.success, this.title, this.subtitle, this.icon);
}

// ═══════════════════════════════════════════════════════════════════
// NEW CLIENT FORM (BOTTOM SHEET)
// ═══════════════════════════════════════════════════════════════════

class _NewClientForm extends StatefulWidget {
  final String initialName;
  final Function(
    String name,
    String phone,
    String cedula,
    File? photo,
    PlanMembresia? plan,
  )
  onSave;
  const _NewClientForm({required this.initialName, required this.onSave});

  @override
  State<_NewClientForm> createState() => _NewClientFormState();
}

class _NewClientFormState extends State<_NewClientForm> {
  late TextEditingController _nameCtrl;
  final _phoneCtrl = TextEditingController();
  final _cedCtrl = TextEditingController();
  File? _photo;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName);
  }

  Future<void> _takePhoto() async {
    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 800,
    );
    if (picked != null) setState(() => _photo = File(picked.path));
  }

  @override
  Widget build(BuildContext context) {
    final planes = context.read<PlanesProvider>().planesActivos;
    final fmt = NumberFormat.currency(
      locale: 'es',
      symbol: 'C\$',
      decimalDigits: 0,
    );

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Title ──
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.person_add,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Nuevo Cliente',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Photo ──
            Center(
              child: GestureDetector(
                onTap: _takePhoto,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 42,
                      backgroundColor: AppColors.border,
                      backgroundImage: _photo != null
                          ? FileImage(_photo!)
                          : null,
                      child: _photo == null
                          ? const Icon(
                              Icons.camera_alt,
                              size: 32,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Foto (opcional)',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
            ),
            const SizedBox(height: 20),

            // ── Fields ──
            TextField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nombre completo *',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono',
                      prefixIcon: Icon(Icons.phone),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _cedCtrl,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'Cédula',
                      prefixIcon: Icon(Icons.badge),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // ── Plans ──
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  Icon(Icons.flash_on, color: AppColors.success),
                  SizedBox(width: 8),
                  Text(
                    'Cobrar en Efectivo y Entrar',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ...planes.map(
              (p) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      if (_nameCtrl.text.trim().isEmpty) return;
                      widget.onSave(
                        _nameCtrl.text,
                        _phoneCtrl.text,
                        _cedCtrl.text,
                        _photo,
                        p,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              p.nombre,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
                            fmt.format(p.precioDisplay),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Free entry ──
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.volunteer_activism, size: 20),
              label: const Text(
                'Solo Registrar (Sin cobrar)',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onPressed: () {
                if (_nameCtrl.text.trim().isEmpty) return;
                widget.onSave(
                  _nameCtrl.text,
                  _phoneCtrl.text,
                  _cedCtrl.text,
                  _photo,
                  null,
                );
              },
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCELAR', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
