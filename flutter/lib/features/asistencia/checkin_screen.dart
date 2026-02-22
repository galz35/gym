import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/clientes_provider.dart';
import '../../core/providers/asistencia_provider.dart';
import '../../core/models/models.dart';

class CheckinScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigate;

  const CheckinScreen({super.key, this.onNavigate});

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showResult = false;
  Cliente? _selectedClient;
  Asistencia? _resultAsistencia;

  @override
  void initState() {
    super.initState();
    // Load clients if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.empresaId.isNotEmpty) {
        // We trigger a reload to ensure we have fresh data, or just rely on existing
        // context.read<ClientesProvider>().loadClientes(auth.empresaId);
        // Actually loadClientes() takes no args now as per my previous fix
        context.read<ClientesProvider>().loadClientes();
      }
    });
  }

  List<Cliente> get _filteredClients {
    if (_searchQuery.isEmpty) return [];
    final provider = context.read<ClientesProvider>();
    final q = _searchQuery.toLowerCase();
    return provider.clientes.where((c) {
      return c.nombre.toLowerCase().contains(q) ||
          (c.telefono?.contains(q) ?? false) ||
          (c.documento?.contains(q) ?? false);
    }).toList();
  }

  Future<void> _doCheckin(Cliente client) async {
    final auth = context.read<AuthProvider>();
    final asistenciaProv = context.read<AsistenciaProvider>();

    // Perform check-in
    final asistencia = await asistenciaProv.registrarAsistencia(
      client.id,
      auth.sucursalId,
    );

    if (!mounted) return;

    if (asistencia != null) {
      setState(() {
        _selectedClient = client;
        _resultAsistencia = asistencia;
        _showResult = true;
      });
      _autoHideResult();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            asistenciaProv.error ?? 'Error al registrar asistencia',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _autoHideResult() {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _showResult = false;
          _selectedClient = null;
          _resultAsistencia = null;
          _searchController.clear();
          _searchQuery = '';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final asistenciaProv = context.watch<AsistenciaProvider>();
    final isLoading = asistenciaProv.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-In'),
        actions: [
          IconButton(
            onPressed: () => _showQRScanner(),
            icon: const Icon(Icons.qr_code_scanner_rounded),
            tooltip: 'Escanear QR',
          ),
        ],
      ),
      body: Column(
        children: [
          // ─── Search ───
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: (v) => setState(() {
                    _searchQuery = v;
                    _showResult = false;
                  }),
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre o teléfono...',
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.textTertiary,
                      size: 22,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                                _showResult = false;
                              });
                            },
                            icon: const Icon(Icons.close_rounded, size: 20),
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.lg,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline_rounded,
                      size: 14,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Escribe el nombre o escanea el QR del cliente',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ─── Loading Overlay/Indicator ───
          if (isLoading && !_showResult)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),

          // ─── Result Animation ───
          if (_showResult && _selectedClient != null)
            _buildCheckinResult(_selectedClient!, _resultAsistencia),

          // ─── Client List (autocomplete) ───
          if (!_showResult && !isLoading && _filteredClients.isNotEmpty)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                itemCount: _filteredClients.length,
                itemBuilder: (context, i) {
                  final client = _filteredClients[i];
                  final isActive = client.estado == 'ACTIVO';
                  // Demo plan data as Cliente model might not have plan details populated fully yet
                  // Assuming client extension or we just show partial info
                  return AnimatedListItem(
                    index: i,
                    child: GestureDetector(
                      onTap: () => _doCheckin(client),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: AppColors.border),
                          boxShadow: AppColors.cardShadow,
                        ),
                        child: Row(
                          children: [
                            // Avatar
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isActive
                                      ? [
                                          AppColors.primary,
                                          AppColors.primaryLight,
                                        ]
                                      : [
                                          AppColors.textTertiary,
                                          AppColors.textTertiary,
                                        ],
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.md,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                client.nombre.substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    client.nombre,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Tel: ${client.telefono ?? 'N/A'}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                StatusPill(
                                  text: client.estado,
                                  color: isActive
                                      ? AppColors.activeGreen
                                      : AppColors.expiredRed,
                                  small: true,
                                ),
                                const SizedBox(height: 8),
                                Icon(
                                  Icons.login_rounded,
                                  color: isActive
                                      ? AppColors.primary
                                      : AppColors.textTertiary,
                                  size: 22,
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
            ),

          // ─── Empty / Default ───
          if (!_showResult && !isLoading && _searchQuery.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        color: AppColors.primarySurface,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.how_to_reg_rounded,
                        size: 48,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const Text(
                      'Registra la Asistencia',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Text(
                      'Busca un cliente por nombre o escanea\nsu código QR para registrar su entrada',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _showQRScanner(),
                          icon: const Icon(
                            Icons.qr_code_scanner_rounded,
                            size: 18,
                          ),
                          label: const Text('Escanear QR'),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        FilledButton.icon(
                          onPressed: () {
                            if (widget.onNavigate != null) {
                              widget.onNavigate!(2); // 2 is POS
                            }
                          },
                          icon: const Icon(
                            Icons.shopping_cart_checkout_rounded,
                            size: 18,
                          ),
                          label: const Text('Pase de Día'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          if (!_showResult &&
              !isLoading &&
              _searchQuery.isNotEmpty &&
              _filteredClients.isEmpty)
            const Expanded(
              child: EmptyState(
                icon: Icons.person_search_rounded,
                title: 'Sin resultados',
                subtitle:
                    'No se encontraron clientes con ese nombre o teléfono',
                actionLabel: 'Nuevo Cliente',
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCheckinResult(Cliente client, Asistencia? asistencia) {
    final isAllowed = asistencia?.resultado == 'PERMITIDO';
    // Fallback logic if needed, but API usually dictates allowed/denied
    return Expanded(
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 500),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.5 + (0.5 * value),
              child: Opacity(opacity: value.clamp(0, 1), child: child),
            );
          },
          child: Container(
            margin: const EdgeInsets.all(AppSpacing.xxl),
            padding: const EdgeInsets.all(AppSpacing.xxxl),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.xxl),
              boxShadow: AppColors.elevatedShadow,
              border: Border.all(
                color: isAllowed ? AppColors.success : AppColors.error,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: isAllowed
                        ? AppColors.successLight
                        : AppColors.errorLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isAllowed
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    size: 48,
                    color: isAllowed ? AppColors.success : AppColors.error,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  isAllowed ? '¡Bienvenido!' : 'Acceso Denegado',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: isAllowed ? AppColors.success : AppColors.error,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  client.nombre,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (asistencia?.nota != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                    child: Text(
                      asistencia!.nota!,
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                if (!isAllowed) ...[
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showRenewDialog(client),
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Renovar Membresía'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showQRScanner() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Escáner QR: Próximamente (requiere cámara)'),
      ),
    );
  }

  void _showRenewDialog(Cliente client) {
    // We navigate to Membresias or show a simplified renewal here?
    // Let's show a snackbar and navigage to Membresias Screen for now.
    if (widget.onNavigate != null) {
      widget.onNavigate!(11);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Redirigiendo a Membresías para ${client.nombre}...'),
        ),
      );
    }
    // Future: Use a global key or proper navigation to switch tabs/screens
  }
}
