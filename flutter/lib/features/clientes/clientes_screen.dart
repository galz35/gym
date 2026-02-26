import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/data_widgets.dart';
import '../../core/widgets/shimmer_widgets.dart';
import '../../core/providers/clientes_provider.dart';
import '../../core/models/models.dart';
import '../../core/router/app_pages.dart';
import 'biometric_registration_screen.dart';

class ClientesScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigate;

  const ClientesScreen({super.key, this.onNavigate});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterStatus = 'Todos';

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    context.read<ClientesProvider>().loadClientes();
  }

  List<Cliente> get _filteredClients {
    final provider = context.read<ClientesProvider>();
    return provider.clientes.where((c) {
      final matchesQuery =
          _searchQuery.isEmpty ||
          c.nombre.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (c.telefono?.contains(_searchQuery) ?? false) ||
          (c.email?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
              false);
      final matchesFilter =
          _filterStatus == 'Todos' ||
          c.estado == (_filterStatus == 'Activos' ? 'ACTIVO' : 'INACTIVO');
      return matchesQuery && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClientesProvider>();
    final filtered = _filteredClients;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Clientes')),
      body: RefreshIndicator(
        onRefresh: _loadClients,
        color: AppColors.primary,
        child: Column(
          children: [
            // ─── Search + Filter ───
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre, teléfono...',
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        size: 20,
                        color: AppColors.textTertiary,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                              icon: const Icon(Icons.close_rounded, size: 18),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: ['Todos', 'Activos', 'Inactivos'].map((f) {
                      final isSelected = _filterStatus == f;
                      return Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: FilterChip(
                          label: Text(f),
                          selected: isSelected,
                          onSelected: (_) => setState(() => _filterStatus = f),
                          selectedColor: AppColors.primarySurface,
                          checkmarkColor: AppColors.primary,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppColors.primary
                                : Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            // ─── Results count ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: [
                  Text(
                    '${filtered.length} clientes',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const Spacer(),
                  if (provider.isLoading && filtered.isNotEmpty)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // ─── Client List ───
            Expanded(
              child: provider.isLoading && provider.clientes.isEmpty
                  ? const ShimmerList(itemCount: 8)
                  : filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.person_search_rounded,
                            size: 48,
                            color: AppColors.textTertiary.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No se encontraron clientes',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : PaginatedDataWidget<Cliente>(
                      items: filtered,
                      itemsPerPage: 15,
                      emptyMessage: 'No se encontraron clientes',
                      itemBuilder: (client, index) {
                        final isActive = client.estado == 'ACTIVO';
                        return AnimatedListItem(
                          index: index % 15,
                          child: InkWell(
                            onTap: () => _showClientDetail(client),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                                vertical: AppSpacing.md,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                border: Border(
                                  bottom: BorderSide(
                                    color: Theme.of(
                                      context,
                                    ).dividerColor.withValues(alpha: 0.1),
                                  ),
                                ),
                                boxShadow: isDark
                                    ? null
                                    : [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.02,
                                          ),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? AppColors.primary.withValues(
                                              alpha: 0.1,
                                            )
                                          : Theme.of(context)
                                                .colorScheme
                                                .surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.md,
                                      ),
                                      image: client.fotoUrl != null
                                          ? DecorationImage(
                                              image: NetworkImage(
                                                client.fotoUrl!,
                                              ),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    ),
                                    alignment: Alignment.center,
                                    child: client.fotoUrl == null
                                        ? Text(
                                            client.nombre
                                                .substring(
                                                  0,
                                                  client.nombre.length >= 2
                                                      ? 2
                                                      : 1,
                                                )
                                                .toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: isActive
                                                  ? AppColors.primary
                                                  : Theme.of(context)
                                                        .colorScheme
                                                        .onSurface
                                                        .withValues(alpha: 0.4),
                                            ),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          client.nombre,
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
                                          [client.telefono, client.email]
                                              .where(
                                                (e) =>
                                                    e != null && e.isNotEmpty,
                                              )
                                              .join(' · '),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(alpha: 0.5),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  StatusPill(
                                    text: client.estado,
                                    color: isActive
                                        ? AppColors.activeGreen.withValues(
                                            alpha: 0.1,
                                          )
                                        : AppColors.expiredRed.withValues(
                                            alpha: 0.1,
                                          ),
                                    small: true,
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    size: 20,
                                    color: AppColors.textTertiary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddClientDialog(),
        icon: const Icon(Icons.person_add_rounded, size: 20),
        label: const Text('Nuevo Cliente'),
      ),
    );
  }

  void _showClientDetail(Cliente client) {
    final isActive = client.estado == 'ACTIVO';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (ctx, scroll) {
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
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: client.fotoUrl == null
                            ? const LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.primaryLight,
                                ],
                              )
                            : null,
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        image: client.fotoUrl != null
                            ? DecorationImage(
                                image: NetworkImage(client.fotoUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: client.fotoUrl == null
                          ? Text(
                              client.nombre
                                  .substring(
                                    0,
                                    client.nombre.length >= 2 ? 2 : 1,
                                  )
                                  .toUpperCase(),
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      client.nombre,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    StatusPill(
                      text: client.estado,
                      color: isActive
                          ? AppColors.activeGreen
                          : AppColors.expiredRed,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Column(
                        children: [
                          InfoRow(
                            icon: Icons.phone_rounded,
                            label: 'Teléfono',
                            value: client.telefono ?? 'No registrado',
                          ),
                          InfoRow(
                            icon: Icons.email_rounded,
                            label: 'Email',
                            value: client.email ?? 'No registrado',
                          ),
                          InfoRow(
                            icon: Icons.badge_rounded,
                            label: 'Documento',
                            value: client.documento ?? 'No registrado',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(ctx);
                              _showEditClientDialog(client);
                            },
                            icon: const Icon(Icons.edit_rounded, size: 18),
                            label: const Text('Editar'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(ctx);
                              if (widget.onNavigate != null) {
                                widget.onNavigate!(AppPage.membresias.navIndex);
                              }
                            },
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('Renovar'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BiometricRegistrationScreen(
                                clienteId: client.id,
                                clienteNombre: client.nombre,
                              ),
                            ),
                          );
                          if (result == true && mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Rostro registrado exitosamente'),
                              ),
                            );
                          }
                        },
                        icon: const Icon(
                          Icons.face_retouching_natural_rounded,
                          size: 18,
                        ),
                        label: const Text('Registrar Rostro'),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          if (widget.onNavigate != null) {
                            widget.onNavigate!(AppPage.checkin.navIndex);
                          }
                        },
                        icon: const Icon(Icons.how_to_reg_rounded, size: 18),
                        label: const Text('Registrar Asistencia'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddClientDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final docCtrl = TextEditingController();
    File? selectedImage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
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
                      'Nuevo Cliente',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // 📸 FOTO DEL CLIENTE (NUEVO)
                    Center(
                      child: GestureDetector(
                        onTap: () async {
                          final picker = ImagePicker();
                          final picked = await picker.pickImage(
                            source: ImageSource.camera,
                            imageQuality: 60,
                            maxWidth: 800,
                          );
                          if (picked != null) {
                            setModalState(
                              () => selectedImage = File(picked.path),
                            );
                          }
                        },
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary,
                              width: 2,
                            ),
                            image: selectedImage != null
                                ? DecorationImage(
                                    image: FileImage(selectedImage!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: selectedImage == null
                              ? const Icon(
                                  Icons.add_a_photo_rounded,
                                  size: 40,
                                  color: AppColors.primary,
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nombre completo',
                        prefixIcon: Icon(Icons.person_rounded, size: 20),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Teléfono',
                        prefixIcon: Icon(Icons.phone_rounded, size: 20),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextField(
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email (opcional)',
                        prefixIcon: Icon(Icons.email_rounded, size: 20),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextField(
                      controller: docCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Documento / ID (opcional)',
                        prefixIcon: Icon(Icons.badge_rounded, size: 20),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          final name = nameCtrl.text.trim().isEmpty
                              ? 'Visitante Anónimo'
                              : nameCtrl.text.trim();
                          final clientesProv = context.read<ClientesProvider>();

                          // 1. Create client
                          final created = await clientesProv.createCliente({
                            'nombre': name,
                            'telefono': phoneCtrl.text.trim().isEmpty
                                ? null
                                : phoneCtrl.text.trim(),
                            'email': emailCtrl.text.trim().isEmpty
                                ? null
                                : emailCtrl.text.trim(),
                            'documento': docCtrl.text.trim().isEmpty
                                ? null
                                : docCtrl.text.trim(),
                          });

                          // 2. Upload photo if selected
                          if (created != null && selectedImage != null) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Subiendo foto...')),
                            );
                            await clientesProv.uploadFoto(
                              created.id,
                              selectedImage!,
                            );
                          }

                          if (!ctx.mounted) return;
                          Navigator.pop(ctx);
                          if (created != null) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Cliente guardado exitosamente'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        child: const Text('Guardar Cliente'),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditClientDialog(Cliente client) {
    final nameCtrl = TextEditingController(text: client.nombre);
    final phoneCtrl = TextEditingController(text: client.telefono);
    final emailCtrl = TextEditingController(text: client.email);
    final docCtrl = TextEditingController(text: client.documento);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
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
                  'Editar Cliente',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre completo',
                    prefixIcon: Icon(Icons.person_rounded, size: 20),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    prefixIcon: Icon(Icons.phone_rounded, size: 20),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_rounded, size: 20),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                TextField(
                  controller: docCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Documento / ID',
                    prefixIcon: Icon(Icons.badge_rounded, size: 20),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (nameCtrl.text.trim().isEmpty) return;
                      final clientesProv = context.read<ClientesProvider>();
                      final updated = await clientesProv
                          .updateCliente(client.id, {
                            'nombre': nameCtrl.text.trim(),
                            'telefono': phoneCtrl.text.trim().isEmpty
                                ? null
                                : phoneCtrl.text.trim(),
                            'email': emailCtrl.text.trim().isEmpty
                                ? null
                                : emailCtrl.text.trim(),
                            'documento': docCtrl.text.trim().isEmpty
                                ? null
                                : docCtrl.text.trim(),
                          });
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      if (updated) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Cliente actualizado exitosamente'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    child: const Text('Actualizar Cliente'),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        );
      },
    );
  }
}
