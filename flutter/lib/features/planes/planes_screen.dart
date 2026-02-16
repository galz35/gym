import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/providers/membresias_provider.dart';
import '../../core/models/models.dart';

class PlanesScreen extends StatefulWidget {
  const PlanesScreen({super.key});

  @override
  State<PlanesScreen> createState() => _PlanesScreenState();
}

class _PlanesScreenState extends State<PlanesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlanesProvider>().loadPlanes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlanesProvider>();
    final planes = provider.planes;
    final currencyFmt = NumberFormat.simpleCurrency(locale: 'es_GT', name: 'Q');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Planes y Servicios'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.sort_rounded),
            tooltip: 'Ordenar',
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : planes.isEmpty
          ? const Center(
              child: Text(
                'No hay planes registrados',
                style: TextStyle(color: AppColors.textTertiary),
              ),
            )
          : RefreshIndicator(
              onRefresh: () async => provider.loadPlanes(),
              color: AppColors.primary,
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: planes.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  final plan = planes[index];
                  // Simple color coding logic based on duration/type
                  Color color = AppColors.primary;
                  IconData icon = Icons.card_membership_rounded;

                  if ((plan.dias ?? 0) == 1) {
                    color = AppColors.info;
                    icon = Icons.today_rounded;
                  } else if ((plan.dias ?? 0) <= 7) {
                    color = AppColors.warning;
                    icon = Icons.date_range_rounded;
                  } else if ((plan.dias ?? 0) > 90) {
                    color = Colors.purple;
                    icon = Icons.star_rounded;
                  }

                  return AnimatedListItem(
                    index: index,
                    child: InkWell(
                      onTap: () => _showPlanDetail(plan),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: AppColors.border),
                          boxShadow: AppColors.cardShadow,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.md,
                                ),
                              ),
                              child: Icon(icon, color: color, size: 28),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    plan.nombre,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.surfaceVariant,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          '${plan.dias ?? 0} Días',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (plan.descripcion != null)
                                        Expanded(
                                          child: Text(
                                            plan.descripcion!,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textTertiary,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  currencyFmt.format(plan.precioDisplay),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                StatusPill(
                                  text: plan.estado,
                                  color: plan.estado == 'ACTIVO'
                                      ? AppColors.activeGreen
                                      : AppColors.textTertiary,
                                  small: true,
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPlanForm(),
        icon: const Icon(Icons.add_rounded, size: 20),
        label: const Text('Nuevo Plan'),
      ),
    );
  }

  void _showPlanDetail(PlanMembresia plan) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              Text(
                plan.nombre,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              InfoRow(label: 'Precio', value: 'Q${plan.precioDisplay}'),
              InfoRow(label: 'Duración', value: '${plan.dias ?? 0} días'),
              if (plan.descripcion != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(plan.descripcion!, textAlign: TextAlign.center),
                ),
              const SizedBox(height: AppSpacing.xxl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _showPlanForm(plan: plan);
                  },
                  icon: const Icon(Icons.edit_rounded),
                  label: const Text('Editar Plan'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPlanForm({PlanMembresia? plan}) {
    final nameCtrl = TextEditingController(text: plan?.nombre);
    final descCtrl = TextEditingController(text: plan?.descripcion);
    final priceCtrl = TextEditingController(
      text: plan?.precioDisplay.toString(),
    );
    final daysCtrl = TextEditingController(text: plan?.dias?.toString());
    String tipo = plan?.tipo ?? 'DIAS';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
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
                  Text(
                    plan == null ? 'Nuevo Plan' : 'Editar Plan',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: descCtrl,
                    decoration: const InputDecoration(labelText: 'Descripción'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: priceCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Precio (Q)',
                            prefixText: 'Q',
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: TextField(
                          controller: daysCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Días'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (nameCtrl.text.isEmpty || priceCtrl.text.isEmpty) {
                          return;
                        }
                        final data = {
                          'nombre': nameCtrl.text,
                          'descripcion': descCtrl.text,
                          'precio': double.tryParse(priceCtrl.text) ?? 0.0,
                          'dias': int.tryParse(daysCtrl.text) ?? 30,
                          'tipo': tipo,
                        };

                        final provider = context.read<PlanesProvider>();
                        bool success;
                        if (plan == null) {
                          final res = await provider.createPlan(data);
                          success = res != null;
                        } else {
                          success = await provider.updatePlan(plan.id, data);
                        }

                        if (ctx.mounted && success) {
                          Navigator.pop(ctx);
                        }

                        if (success) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                plan == null
                                    ? 'Plan creado'
                                    : 'Plan actualizado',
                              ),
                            ),
                          );
                          provider.loadPlanes();
                        }
                      },
                      child: Text(
                        plan == null ? 'Crear Plan' : 'Guardar Cambios',
                      ),
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
}
