import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/clientes_provider.dart';
import '../../core/providers/asistencia_provider.dart';
import '../../core/models/models.dart';
import '../../core/router/app_pages.dart';
import '../../core/widgets/shimmer_widgets.dart';

class CheckinScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigate;

  const CheckinScreen({super.key, this.onNavigate});

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
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
        _focusNode.requestFocus();
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
                  focusNode: _focusNode,
                  autofocus: true,
                  onChanged: (v) {
                    setState(() {
                      _searchQuery = v;
                      _showResult = false;
                    });
                    // Auto-checkin if exact match on documento or phone (speed for barcode readers)
                    if (v.length >= 4) {
                      final matches = _filteredClients;
                      if (matches.length == 1) {
                        final c = matches.first;
                        if (c.documento == v || c.telefono == v) {
                          _doCheckin(c);
                        }
                      }
                    }
                  },
                  onSubmitted: (v) {
                    if (_filteredClients.isNotEmpty) {
                      _doCheckin(_filteredClients.first);
                    }
                  },
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
                    fillColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
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
            const Expanded(child: ShimmerList(itemCount: 5)),

          // ─── Result Animation ───
          if (_showResult && _selectedClient != null)
            _buildCheckinResult(_selectedClient!, _resultAsistencia),

          // ─── Client List (autocomplete) or Empty state ───
          if (!_showResult && !isLoading)
            if (_filteredClients.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
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
                                        ? AppColors.primary.withValues(
                                            alpha: 0.1,
                                          )
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
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.how_to_reg_rounded,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
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
                              widget.onNavigate!(
                                AppPage.pos.navIndex,
                              ); // 2 is POS
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
            Expanded(
              child: EmptyState(
                icon: Icons.person_add_alt_1_rounded,
                title: 'Cliente no encontrado',
                subtitle: 'Pulsa abajo para crearlo rápidamente y registrarlo',
                actionLabel: 'Crear Cliente Express',
                onAction: _showQuickCreateDialog,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCheckinResult(Cliente client, Asistencia? asistencia) {
    final isAllowed = asistencia?.resultado == 'PERMITIDO';
    final statusColor = isAllowed ? AppColors.success : AppColors.error;

    return Expanded(
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.8 + (0.2 * value),
              child: Opacity(opacity: value.clamp(0, 1), child: child),
            );
          },
          child: GestureDetector(
            onTap: () {
              setState(() {
                _showResult = false;
                _selectedClient = null;
                _resultAsistencia = null;
                _searchController.clear();
                _searchQuery = '';
              });
              _focusNode.requestFocus();
            },
            child: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.md,
              ),
              padding: const EdgeInsets.all(AppSpacing.xxl),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(AppRadius.xxl),
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withValues(alpha: 0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
                border: Border.all(color: statusColor, width: 4),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 📸 FOTO GIGANTE ANTI-TRAMPA
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      border: Border.all(color: statusColor, width: 3),
                      image:
                          client.fotoUrl != null && client.fotoUrl!.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(client.fotoUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: client.fotoUrl == null || client.fotoUrl!.isEmpty
                        ? Icon(
                            Icons.person_rounded,
                            size: 100,
                            color: AppColors.textTertiary,
                          )
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isAllowed
                            ? Icons.check_circle_rounded
                            : Icons.cancel_rounded,
                        size: 32,
                        color: statusColor,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        isAllowed ? '¡ACCESO PERMITIDO!' : 'ACCESO DENEGADO',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: statusColor,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    client.nombre.toUpperCase(),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  if (asistencia?.nota != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Text(
                        asistencia!.nota!,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],

                  if (!isAllowed) ...[
                    const SizedBox(height: AppSpacing.xxl),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => _showRenewDialog(client),
                        icon: const Icon(Icons.refresh_rounded, size: 24),
                        label: const Text(
                          'RENOVAR MEMBRESÍA',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
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
      widget.onNavigate!(AppPage.membresias.navIndex);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Redirigiendo a Membresías para ${client.nombre}...'),
        ),
      );
    }
    // Future: Use a global key or proper navigation to switch tabs/screens
  }

  void _showQuickCreateDialog() {
    final nameCtrl = TextEditingController(text: _searchQuery);
    final phoneCtrl = TextEditingController();
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Crear Cliente Exprés',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Teléfono (Opcional)',
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton.icon(
              onPressed: isSaving
                  ? null
                  : () async {
                      if (nameCtrl.text.trim().isEmpty) return;
                      setDialogState(() => isSaving = true);

                      final clientesProv = context.read<ClientesProvider>();
                      final created = await clientesProv.createCliente({
                        'nombre': nameCtrl.text.trim(),
                        'telefono': phoneCtrl.text.trim().isEmpty
                            ? null
                            : phoneCtrl.text.trim(),
                      });

                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);

                      if (created != null) {
                        setState(() {
                          _searchController.text = created.nombre;
                          _searchQuery = created.nombre;
                        });
                        _doCheckin(created);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Cliente guardado y seleccionado rápidamente',
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              clientesProv.error ?? 'Error al guardar',
                            ),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    },
              icon: isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.check_circle_outline),
              label: Text(isSaving ? 'Guardando...' : 'Crear y Continuar'),
            ),
          ],
        ),
      ),
    );
  }
}
