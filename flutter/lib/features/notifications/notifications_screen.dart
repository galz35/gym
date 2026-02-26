import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/premium_widgets.dart';
import '../../core/providers/dashboard_provider.dart';

/// Notifications screen showing upcoming expirations, pending payments, etc.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboard = context.watch<DashboardProvider>();
    final vencimientos = dashboard.vencimientos;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        actions: [
          TextButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Todas las notificaciones marcadas como leídas',
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.done_all_rounded, size: 18),
            label: const Text('Leer todo', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
      body: vencimientos.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_none_rounded,
                      size: 40,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    '¡Todo en orden!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'No hay notificaciones pendientes',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              itemCount: vencimientos.length + 1, // +1 for header
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        PulseDot(color: AppColors.warning, size: 10),
                        const SizedBox(width: AppSpacing.md),
                        Text(
                          '${vencimientos.length} membresías por vencer',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final item = vencimientos[index - 1];
                final daysLeft = item.fin.difference(DateTime.now()).inDays;
                final isUrgent = daysLeft <= 1;
                final expiryLabel = daysLeft <= 0
                    ? 'Vence hoy'
                    : daysLeft == 1
                    ? 'Vence mañana'
                    : 'Vence en $daysLeft días';
                final dateStr = DateFormat(
                  'dd MMM yyyy',
                  'es_ES',
                ).format(item.fin);

                return StaggeredFadeIn(
                  index: index,
                  child: Dismissible(
                    key: ValueKey('notif-${item.id}'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: AppSpacing.xxl),
                      color: AppColors.success.withValues(alpha: 0.1),
                      child: const Icon(
                        Icons.done_rounded,
                        color: AppColors.success,
                      ),
                    ),
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.xs,
                      ),
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: isUrgent
                              ? AppColors.error.withValues(alpha: 0.3)
                              : Theme.of(
                                  context,
                                ).colorScheme.outline.withValues(alpha: 0.2),
                        ),
                        boxShadow: isDark
                            ? AppColors.cardShadowDark
                            : AppColors.cardShadow,
                      ),
                      child: Row(
                        children: [
                          // Icon
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: isUrgent
                                  ? AppColors.error.withValues(alpha: 0.1)
                                  : AppColors.warning.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: Icon(
                              isUrgent
                                  ? Icons.warning_rounded
                                  : Icons.schedule_rounded,
                              color: isUrgent
                                  ? AppColors.error
                                  : AppColors.warning,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          // Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.clienteNombre ?? 'Cliente',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${item.planNombre ?? "Membresía"} • $dateStr',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: isUrgent
                                  ? AppColors.error.withValues(alpha: 0.1)
                                  : AppColors.warning.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(
                                AppRadius.full,
                              ),
                            ),
                            child: Text(
                              expiryLabel,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isUrgent
                                    ? AppColors.error
                                    : AppColors.warning,
                              ),
                            ),
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
}
