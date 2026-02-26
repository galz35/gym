import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/sucursales_riverpod_provider.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/shimmer_widgets.dart';

class SucursalesScreen extends ConsumerStatefulWidget {
  const SucursalesScreen({super.key});

  @override
  ConsumerState<SucursalesScreen> createState() => _SucursalesScreenState();
}

class _SucursalesScreenState extends ConsumerState<SucursalesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sucursalesRiverpodProvider.notifier).loadSucursales();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sucursalesRiverpodProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Sucursales')),
      body: state.isLoading && state.sucursales.isEmpty
          ? const ShimmerList(itemCount: 4)
          : state.sucursales.isEmpty
          ? const EmptyState(
              icon: Icons.store_rounded,
              title: 'No hay sucursales',
              subtitle: 'Comienza agregando tu primera sucursal',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: state.sucursales.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, i) {
                final b = state.sucursales[i];
                final isActive = b.estado == 'ACTIVO';
                return Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: isActive
                          ? AppColors.border
                          : AppColors.borderLight,
                    ),
                    boxShadow: isActive ? AppColors.cardShadow : [],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: isActive
                                  ? const LinearGradient(
                                      colors: [
                                        AppColors.primary,
                                        AppColors.primaryLight,
                                      ],
                                    )
                                  : null,
                              color: isActive ? null : AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: Icon(
                              Icons.store_rounded,
                              color: isActive
                                  ? Colors.white
                                  : AppColors.textTertiary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  b.nombre,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: isActive
                                        ? Theme.of(
                                            context,
                                          ).colorScheme.onSurface
                                        : Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.5),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  b.direccion ?? 'Sin dirección',
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
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppColors.successLight
                                  : AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(
                                AppRadius.pill,
                              ),
                            ),
                            child: Text(
                              isActive ? 'ACTIVO' : 'INACTIVO',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isActive
                                    ? AppColors.success
                                    : AppColors.textTertiary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context),
        icon: const Icon(Icons.add_business_rounded),
        label: const Text('Nueva Sucursal'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final addressCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nueva Sucursal',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre de Sucursal',
                  prefixIcon: Icon(Icons.store),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: addressCtrl,
                decoration: const InputDecoration(
                  labelText: 'Dirección',
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (nameCtrl.text.isEmpty) return;
                    Navigator.pop(ctx);
                    final success = await ref
                        .read(sucursalesRiverpodProvider.notifier)
                        .createSucursal(
                          nombre: nameCtrl.text,
                          direccion: addressCtrl.text,
                        );
                    if (context.mounted) {
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Sucursal creada exitosamente'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              ref.read(sucursalesRiverpodProvider).error ?? 'Error',
                            ),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Crear Sucursal'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
