import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/clientes_provider.dart';
import '../../core/providers/asistencia_provider.dart';
import '../../core/providers/membresias_provider.dart';
import '../../core/models/models.dart';
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
  String _modo = 'Entrada';
  bool _showResult = false;
  Cliente? _selectedClient;
  Asistencia? _resultAsistencia;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.empresaId.isNotEmpty) {
        context.read<ClientesProvider>().loadClientes();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<Cliente> get _filteredClients {
    final provider = context.read<ClientesProvider>();
    if (_searchQuery.isEmpty) return provider.clientes;
    final q = _searchQuery.toLowerCase();
    return provider.clientes
        .where((c) {
          return c.nombre.toLowerCase().contains(q) ||
              (c.telefono?.contains(q) ?? false);
        })
        .take(20)
        .toList();
  }

  Future<void> _doCheckin(Cliente client) async {
    final auth = context.read<AuthProvider>();
    final asistenciaProv = context.read<AsistenciaProvider>();

    final funcion = _modo == 'Entrada'
        ? asistenciaProv.registrarAsistencia
        : asistenciaProv.registrarSalida;

    final asistencia = await funcion(client.id, auth.sucursalId);

    if (!mounted) return;

    if (asistencia != null) {
      if (asistencia.resultado == 'PERMITIDO') {
        HapticFeedback.heavyImpact();
      } else {
        HapticFeedback.vibrate();
      }
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
            asistenciaProv.error ?? 'Error al registrar ${_modo.toLowerCase()}',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _autoHideResult() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _showResult) {
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

  void _clearAndRefocus() {
    setState(() {
      _showResult = false;
      _selectedClient = null;
      _resultAsistencia = null;
      _searchController.clear();
      _searchQuery = '';
    });
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final asistenciaProv = context.watch<AsistenciaProvider>();
    final isLoading = asistenciaProv.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Asistencia'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded),
            tooltip: 'Escanear QR (Opcional)',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Lector QR próximamente')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_add_rounded),
            tooltip: 'Registrar Cliente',
            onPressed: () => _showNewClientSheet(),
          ),
        ],
      ),
      body: Column(
        children: [
          // ─── Selector Entrada / Salida ───
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              0,
            ),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _modo = 'Entrada'),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: _modo == 'Entrada'
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          boxShadow: _modo == 'Entrada'
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Entrada',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: _modo == 'Entrada'
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: _modo == 'Entrada'
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _modo = 'Salida'),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: _modo == 'Salida'
                              ? const Color(0xFFF59E0B)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          boxShadow: _modo == 'Salida'
                              ? [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFF59E0B,
                                    ).withValues(alpha: 0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Salida',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: _modo == 'Salida'
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: _modo == 'Salida'
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Search Bar ───
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              0,
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              onChanged: (v) {
                setState(() {
                  _searchQuery = v;
                  _showResult = false;
                });
              },
              onSubmitted: (v) {
                final matches = _filteredClients;
                if (matches.length == 1) {
                  _doCheckin(matches.first);
                }
              },
              style: const TextStyle(fontSize: 18),
              decoration: InputDecoration(
                hintText: 'Nombre del cliente...',
                hintStyle: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 18,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.textTertiary,
                  size: 24,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: _clearAndRefocus,
                        icon: const Icon(Icons.close_rounded, size: 22),
                      )
                    : null,
                filled: true,
                fillColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // ─── Loading ───
          if (isLoading && !_showResult)
            const Expanded(child: ShimmerList(itemCount: 4)),

          // ─── Result Animation ───
          if (_showResult && _selectedClient != null)
            _buildCheckinResult(_selectedClient!, _resultAsistencia),

          // ─── Client List ───
          if (!_showResult && !isLoading && _filteredClients.isNotEmpty)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                itemCount: _filteredClients.length,
                itemBuilder: (context, i) {
                  final client = _filteredClients[i];
                  return _ClientTile(
                    client: client,
                    onTap: () => _doCheckin(client),
                  );
                },
              ),
            ),

          // ─── Empty state: No clients registered ───
          if (!_showResult &&
              !isLoading &&
              _filteredClients.isEmpty &&
              _searchQuery.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.people_rounded,
                        size: 40,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const Text(
                      'No hay clientes registrados',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ─── Not found → Create + Pay ───
          if (!_showResult &&
              !isLoading &&
              _searchQuery.length >= 2 &&
              _filteredClients.isEmpty)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxl,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person_off_rounded,
                        size: 56,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'No se encontró "$_searchQuery"',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton.icon(
                          onPressed: () =>
                              _showNewClientSheet(prefillName: _searchQuery),
                          icon: const Icon(Icons.person_add_rounded, size: 22),
                          label: const Text(
                            'Registrar Cliente Nuevo',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // CHECK-IN RESULT (Big photo + status)
  // ─────────────────────────────────────────────────────────────

  Widget _buildCheckinResult(Cliente client, Asistencia? asistencia) {
    final bool isSalida = asistencia?.resultado == 'SALIDA';
    final bool isAllowed = isSalida || asistencia?.resultado == 'PERMITIDO';
    final statusColor = isAllowed ? AppColors.success : AppColors.error;

    return Expanded(
      child: GestureDetector(
        onTap: _clearAndRefocus,
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 500),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.85 + (0.15 * value),
                child: Opacity(opacity: value.clamp(0, 1), child: child),
              );
            },
            child: Container(
              width: double.infinity,
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
                    color: statusColor.withValues(alpha: 0.25),
                    blurRadius: 25,
                    spreadRadius: 3,
                  ),
                ],
                border: Border.all(color: statusColor, width: 3),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ─── FOTO GRANDE ───
                  Stack(
                    children: [
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                          border: Border.all(color: statusColor, width: 3),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child:
                            client.fotoUrl != null && client.fotoUrl!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: client.fotoUrl!,
                                fit: BoxFit.cover,
                                placeholder: (_, _) => const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                errorWidget: (_, _, _) =>
                                    _buildInitialsAvatar(client.nombre, 80),
                              )
                            : _buildInitialsAvatar(client.nombre, 80),
                      ),
                      if (client.fotoUrl == null || client.fotoUrl!.isEmpty)
                        Positioned(
                          right: -4,
                          bottom: -4,
                          child: IconButton.filled(
                            onPressed: () async {
                              final picker = ImagePicker();
                              final photo = await picker.pickImage(
                                source: ImageSource.camera,
                                imageQuality: 70,
                              );
                              if (photo != null && mounted) {
                                final file = File(photo.path);
                                final prov = context.read<ClientesProvider>();
                                await prov.uploadFoto(client.id, file);
                                if (!mounted) return;
                                setState(() {
                                  _selectedClient = client.copyWith(
                                    fotoUrl: 'local_update',
                                  );
                                });
                                prov.loadClientes();
                              }
                            },
                            icon: const Icon(
                              Icons.add_a_photo_rounded,
                              size: 20,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // ─── Nombre ───
                  Text(
                    client.nombre.toUpperCase(),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // ─── Status Badge ───
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isAllowed
                              ? Icons.check_circle_rounded
                              : Icons.cancel_rounded,
                          size: 22,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isAllowed
                              ? (isSalida ? 'SALIDA REGISTRADA' : 'PUEDE PASAR')
                              : 'ACCESO DENEGADO',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ─── Nota ───
                  if (asistencia?.nota != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      asistencia!.nota!,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: statusColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],

                  // ─── Renovar inline (not a dead button!) ───
                  if (!isAllowed) ...[
                    const SizedBox(height: AppSpacing.xl),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        onPressed: () {
                          _clearAndRefocus();
                          _showRenewSheet(client);
                        },
                        icon: const Icon(Icons.credit_card_rounded, size: 22),
                        label: const Text(
                          'COBRAR MEMBRESÍA',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Toca para cerrar',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // NEW CLIENT + MEMBERSHIP (All in one sheet)
  // ─────────────────────────────────────────────────────────────

  void _showNewClientSheet({String prefillName = ''}) {
    final nameCtrl = TextEditingController(text: prefillName);
    final phoneCtrl = TextEditingController();
    PlanMembresia? selectedPlan;
    String selectedMetodo = 'EFECTIVO';
    bool isSaving = false;
    bool skipMembership = false;
    File? capturedPhoto;

    // Load plans
    final planesProv = context.read<PlanesProvider>();
    if (planesProv.planes.isEmpty) {
      planesProv.loadPlanes();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final planes = planesProv.planesActivos;
            final currencyFmt = NumberFormat.currency(
              locale: 'es',
              symbol: 'C\$',
              decimalDigits: 0,
            );

            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle
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
                      const SizedBox(height: AppSpacing.lg),

                      // Title
                      const Text(
                        'Registrar Cliente Nuevo',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Ingresa sus datos y selecciona membresía',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // ─── Captura de Foto ───
                      Center(
                        child: GestureDetector(
                          onTap: () async {
                            final picker = ImagePicker();
                            final photo = await picker.pickImage(
                              source: ImageSource.camera,
                              imageQuality: 70,
                              preferredCameraDevice: CameraDevice.front,
                            );
                            if (photo != null) {
                              setSheetState(
                                () => capturedPhoto = File(photo.path),
                              );
                            }
                          },
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.border,
                                width: 2,
                              ),
                              image: capturedPhoto != null
                                  ? DecorationImage(
                                      image: FileImage(capturedPhoto!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: capturedPhoto == null
                                ? const Icon(
                                    Icons.add_a_photo_rounded,
                                    size: 40,
                                    color: AppColors.textTertiary,
                                  )
                                : Align(
                                    alignment: Alignment.bottomRight,
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.edit_rounded,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const Center(
                        child: Text(
                          'Tocar para tomar foto',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // ─── Name ───
                      TextField(
                        controller: nameCtrl,
                        autofocus: prefillName.isEmpty,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Nombre completo',
                          prefixIcon: Icon(Icons.person_rounded, size: 20),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // ─── Phone ───
                      TextField(
                        controller: phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Teléfono',
                          prefixIcon: Icon(Icons.phone_rounded, size: 20),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // ─── Skip membership toggle ───
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Solo registrar (sin membresía)',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          Switch(
                            value: skipMembership,
                            onChanged: (v) =>
                                setSheetState(() => skipMembership = v),
                          ),
                        ],
                      ),

                      // ─── Plans ───
                      if (!skipMembership) ...[
                        const SizedBox(height: AppSpacing.md),
                        const Text(
                          'Selecciona Plan',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        if (planesProv.isLoading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        else if (planes.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            decoration: BoxDecoration(
                              color: AppColors.warningLight,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  size: 20,
                                  color: AppColors.warning,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'No hay planes creados. Ve a Planes para crear uno.',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: planes.map((plan) {
                              final isSelected = selectedPlan?.id == plan.id;
                              return InkWell(
                                onTap: () =>
                                    setSheetState(() => selectedPlan = plan),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.md,
                                ),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary
                                        : Theme.of(
                                            context,
                                          ).colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.md,
                                    ),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.border,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        plan.nombre,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: isSelected
                                              ? Colors.white
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        currencyFmt.format(plan.precioDisplay),
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: isSelected
                                              ? Colors.white
                                              : AppColors.success,
                                        ),
                                      ),
                                      Text(
                                        plan.tipo == 'DIAS'
                                            ? '${plan.dias ?? 0} días'
                                            : '${plan.visitas ?? 0} visitas',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isSelected
                                              ? Colors.white70
                                              : AppColors.textTertiary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                        // ─── Payment method ───
                        if (selectedPlan != null) ...[
                          const SizedBox(height: AppSpacing.xl),
                          const Text(
                            'Método de Pago',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            children: [
                              _PayMethodChip(
                                label: 'Efectivo',
                                icon: Icons.money_rounded,
                                isSelected: selectedMetodo == 'EFECTIVO',
                                onTap: () => setSheetState(
                                  () => selectedMetodo = 'EFECTIVO',
                                ),
                              ),
                              const SizedBox(width: 8),
                              _PayMethodChip(
                                label: 'Tarjeta',
                                icon: Icons.credit_card_rounded,
                                isSelected: selectedMetodo == 'TARJETA',
                                onTap: () => setSheetState(
                                  () => selectedMetodo = 'TARJETA',
                                ),
                              ),
                              const SizedBox(width: 8),
                              _PayMethodChip(
                                label: 'Transfer.',
                                icon: Icons.phone_android_rounded,
                                isSelected: selectedMetodo == 'TRANSFERENCIA',
                                onTap: () => setSheetState(
                                  () => selectedMetodo = 'TRANSFERENCIA',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],

                      const SizedBox(height: AppSpacing.xxl),

                      // ─── Total + Button ───
                      if (!skipMembership && selectedPlan != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          margin: const EdgeInsets.only(bottom: AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total a cobrar:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                currencyFmt.format(selectedPlan!.precioDisplay),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),

                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: FilledButton.icon(
                          onPressed: isSaving
                              ? null
                              : () => _saveNewClient(
                                  ctx,
                                  setSheetState,
                                  nameCtrl.text.trim(),
                                  phoneCtrl.text.trim(),
                                  skipMembership ? null : selectedPlan,
                                  selectedMetodo,
                                  capturedPhoto,
                                  (v) => setSheetState(() => isSaving = v),
                                ),
                          icon: isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(
                                  skipMembership
                                      ? Icons.person_add_rounded
                                      : Icons.check_circle_rounded,
                                  size: 22,
                                ),
                          label: Text(
                            isSaving
                                ? 'Guardando...'
                                : skipMembership
                                ? 'Registrar Cliente'
                                : 'Registrar y Cobrar',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _saveNewClient(
    BuildContext ctx,
    StateSetter setSheetState,
    String name,
    String phone,
    PlanMembresia? plan,
    String metodo,
    File? photoFile,
    ValueChanged<bool> setLoading,
  ) async {
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe el nombre del cliente')),
      );
      return;
    }

    if (plan == null) {
      // Just create client, no membership
    } else {
      // Validate
    }

    setLoading(true);

    try {
      // 1. Create client
      final clientesProv = context.read<ClientesProvider>();
      final created = await clientesProv.createCliente({
        'nombre': name,
        'telefono': phone.isEmpty ? null : phone,
      });

      if (!mounted || created == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(clientesProv.error ?? 'Error al crear cliente'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        setLoading(false);
        return;
      }

      // Subir foto si tomó
      if (photoFile != null) {
        await clientesProv.uploadFoto(created.id, photoFile);
      }

      // 2. Create membership if plan selected
      if (plan != null && mounted) {
        final auth = context.read<AuthProvider>();
        final membProv = context.read<MembresiasProvider>();
        final membresia = await membProv.createMembresia({
          'cliente_id': created.id,
          'plan_id': plan.id,
          'sucursal_id': auth.sucursalId,
        });

        if (membresia == null && mounted) {
          // Client created but membership failed - still close and show partial success
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Cliente creado, pero error en membresía: ${membProv.error}',
              ),
              backgroundColor: AppColors.warning,
            ),
          );
        }
      }

      if (!ctx.mounted) return;
      Navigator.pop(ctx);

      // 3. Do check-in right away
      _doCheckin(created);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              plan != null
                  ? '✅ ${created.nombre} registrado con ${plan.nombre}'
                  : '✅ ${created.nombre} registrado',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setLoading(false);
    }
  }

  // ─────────────────────────────────────────────────────────────
  // RENEW MEMBERSHIP (for existing client with expired membership)
  // ─────────────────────────────────────────────────────────────

  void _showRenewSheet(Cliente client) {
    PlanMembresia? selectedPlan;
    String selectedMetodo = 'EFECTIVO';
    bool isSaving = false;

    final planesProv = context.read<PlanesProvider>();
    if (planesProv.planes.isEmpty) {
      planesProv.loadPlanes();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final planes = planesProv.planesActivos;
            final currencyFmt = NumberFormat.currency(
              locale: 'es',
              symbol: 'C\$',
              decimalDigits: 0,
            );

            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle
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
                      const SizedBox(height: AppSpacing.lg),

                      // Client info header
                      Row(
                        children: [
                          // Photo
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child:
                                client.fotoUrl != null &&
                                    client.fotoUrl!.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: client.fotoUrl!,
                                    fit: BoxFit.cover,
                                  )
                                : _buildInitialsAvatar(client.nombre, 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  client.nombre,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const Text(
                                  'Cobrar membresía',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // ─── Plans ───
                      const Text(
                        'Selecciona Plan',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      if (planesProv.isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: planes.map((plan) {
                            final isSelected = selectedPlan?.id == plan.id;
                            return InkWell(
                              onTap: () =>
                                  setSheetState(() => selectedPlan = plan),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : Theme.of(
                                          context,
                                        ).colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.md,
                                  ),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.border,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      plan.nombre,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected
                                            ? Colors.white
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      currencyFmt.format(plan.precioDisplay),
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: isSelected
                                            ? Colors.white
                                            : AppColors.success,
                                      ),
                                    ),
                                    Text(
                                      plan.tipo == 'DIAS'
                                          ? '${plan.dias ?? 0} días'
                                          : '${plan.visitas ?? 0} visitas',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isSelected
                                            ? Colors.white70
                                            : AppColors.textTertiary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                      // ─── Payment method ───
                      if (selectedPlan != null) ...[
                        const SizedBox(height: AppSpacing.xl),
                        const Text(
                          'Método de Pago',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            _PayMethodChip(
                              label: 'Efectivo',
                              icon: Icons.money_rounded,
                              isSelected: selectedMetodo == 'EFECTIVO',
                              onTap: () => setSheetState(
                                () => selectedMetodo = 'EFECTIVO',
                              ),
                            ),
                            const SizedBox(width: 8),
                            _PayMethodChip(
                              label: 'Tarjeta',
                              icon: Icons.credit_card_rounded,
                              isSelected: selectedMetodo == 'TARJETA',
                              onTap: () => setSheetState(
                                () => selectedMetodo = 'TARJETA',
                              ),
                            ),
                            const SizedBox(width: 8),
                            _PayMethodChip(
                              label: 'Transfer.',
                              icon: Icons.phone_android_rounded,
                              isSelected: selectedMetodo == 'TRANSFERENCIA',
                              onTap: () => setSheetState(
                                () => selectedMetodo = 'TRANSFERENCIA',
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: AppSpacing.xxl),

                      // ─── Total ───
                      if (selectedPlan != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          margin: const EdgeInsets.only(bottom: AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total a cobrar:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                currencyFmt.format(selectedPlan!.precioDisplay),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // ─── Button ───
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: FilledButton.icon(
                          onPressed: isSaving || selectedPlan == null
                              ? null
                              : () async {
                                  setSheetState(() => isSaving = true);

                                  final auth = context.read<AuthProvider>();
                                  final membProv = context
                                      .read<MembresiasProvider>();
                                  final result = await membProv
                                      .createMembresia({
                                        'cliente_id': client.id,
                                        'plan_id': selectedPlan!.id,
                                        'sucursal_id': auth.sucursalId,
                                      });

                                  if (!ctx.mounted) return;

                                  if (result != null) {
                                    Navigator.pop(ctx);
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '✅ Membresía activada para ${client.nombre}',
                                          ),
                                          backgroundColor: AppColors.success,
                                        ),
                                      );
                                      // Re-do checkin to update status
                                      _doCheckin(client);
                                    }
                                  } else {
                                    setSheetState(() => isSaving = false);
                                    if (!ctx.mounted) return;
                                    ScaffoldMessenger.of(ctx).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          membProv.error ??
                                              'Error al crear membresía',
                                        ),
                                        backgroundColor: AppColors.error,
                                      ),
                                    );
                                  }
                                },
                          icon: isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.check_circle_rounded,
                                  size: 22,
                                ),
                          label: Text(
                            isSaving ? 'Procesando...' : 'Cobrar y Activar',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────

  Widget _buildInitialsAvatar(String name, double fontSize) {
    final initials = name.isNotEmpty
        ? name
              .split(' ')
              .take(2)
              .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
              .join()
        : '?';
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// CLIENT TILE (with prominent photo)
// ─────────────────────────────────────────────────────────────

class _ClientTile extends StatelessWidget {
  final Cliente client;
  final VoidCallback onTap;

  const _ClientTile({required this.client, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isActive = client.estado == 'ACTIVO';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.border),
            boxShadow: AppColors.cardShadow,
          ),
          child: Row(
            children: [
              // ── FOTO (prominente) ──
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                clipBehavior: Clip.antiAlias,
                child: client.fotoUrl != null && client.fotoUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: client.fotoUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => _buildSmallInitials(context),
                        errorWidget: (_, _, _) => _buildSmallInitials(context),
                      )
                    : _buildSmallInitials(context),
              ),
              const SizedBox(width: AppSpacing.md),

              // ── Info ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      client.nombre,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (client.telefono != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        client.telefono!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // ── Status pill + arrow ──
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StatusPill(
                    text: isActive ? 'Activo' : 'Inactivo',
                    color: isActive
                        ? AppColors.activeGreen
                        : AppColors.expiredRed,
                    small: true,
                  ),
                  const SizedBox(height: 6),
                  Icon(
                    Icons.touch_app_rounded,
                    size: 18,
                    color: isActive
                        ? AppColors.primary
                        : AppColors.textTertiary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallInitials(BuildContext context) {
    final initials = client.nombre.isNotEmpty
        ? client.nombre
              .split(' ')
              .take(2)
              .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
              .join()
        : '?';
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// PAY METHOD CHIP
// ─────────────────────────────────────────────────────────────

class _PayMethodChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PayMethodChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.1)
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 22,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
