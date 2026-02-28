import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';

import '../../core/providers/inventario_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/shimmer_widgets.dart';
import '../../core/models/models.dart';

class InventarioScreen extends StatefulWidget {
  const InventarioScreen({super.key});

  @override
  State<InventarioScreen> createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final inv = context.read<InventarioProvider>();
      inv.setSearch('');
      if (auth.isAuthenticated) {
        inv.loadStockSucursal(auth.sucursalId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InventarioProvider>();
    final currencyFmt = NumberFormat.currency(
      locale: 'es_NI',
      symbol: 'C\$',
      decimalDigits: 2,
    );

    // Calculate metrics
    final double totalValue = provider.productos.fold(
      0,
      (sum, p) => sum + ((p.existencia ?? 0) * p.costoDisplay),
    );

    // Low stock threshold hardcoded to 5 for now, or per product if model supports it
    final int lowStockCount = provider.productos
        .where((p) => (p.existencia ?? 0) <= 5)
        .length;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('Inventario'),
            floating: true,
            pinned: true,
            actions: [
              IconButton(
                onPressed: () {
                  final auth = context.read<AuthProvider>();
                  context.read<InventarioProvider>().loadStockSucursal(
                    auth.sucursalId,
                  );
                },
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Actualizar',
              ),
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Historial: Próximamente')),
                  );
                },
                icon: const Icon(Icons.history_rounded),
                tooltip: 'Historial Movimientos',
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => provider.setSearch(v),
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre, SKU o categoría...',
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              provider.setSearch('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      borderSide: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      borderSide: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          if (provider.isLoading)
            const SliverToBoxAdapter(child: ShimmerList(itemCount: 8))
          else ...[
            // ─── Metrics Header ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        'Valor Inventario',
                        currencyFmt.format(totalValue),
                        Icons.monetization_on_rounded,
                        AppColors.success,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _buildMetricCard(
                        'Stock Bajo',
                        '$lowStockCount productos',
                        Icons.warning_amber_rounded,
                        lowStockCount > 0 ? AppColors.error : AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── Product List ───
            if (provider.productos.isEmpty)
              const SliverFillRemaining(
                child: EmptyState(
                  icon: Icons.inventory_2_outlined,
                  title: 'Inventario vacío',
                  subtitle: 'No hay productos en esta sucursal',
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final prod = provider.productos[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.xs,
                    ),
                    child: _buildProductItem(prod, currencyFmt),
                  );
                }, childCount: provider.productos.length),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showMovementDialog(context),
        label: const Text('Registrar Entrada'),
        icon: const Icon(Icons.add_box_rounded),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildMetricCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
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
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 8),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(Producto prod, NumberFormat currencyFmt) {
    // Determine status based on generic threshold 5, since model doesn't store 'minimo' yet based on inspection
    // If 'minimo' exists in backend but not model, we'd need to update model. Assuming 5 for safety or visual cue.
    final bool isLow = (prod.existencia ?? 0) <= 5;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isLow
              ? AppColors.error.withValues(alpha: 0.3)
              : AppColors.border,
        ),
        boxShadow: AppColors.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showProductKardex(context, prod, currencyFmt),
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    Icons.inventory_2_outlined,
                    color: isLow ? AppColors.error : AppColors.textTertiary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prod.nombre,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        prod.categoria ?? 'Sin Categoría',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${prod.existencia ?? 0} un',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: isLow ? AppColors.error : AppColors.textPrimary,
                      ),
                    ),
                    if (isLow)
                      const Text(
                        'BAJO STOCK',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    else
                      Text(
                        currencyFmt.format(
                          prod.costoDisplay,
                        ), // Showing cost as this is inventory view
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMovementDialog(BuildContext context) {
    final cantidadCtrl = TextEditingController();
    Producto? selectedProduct;
    String tipoMovimiento = 'Entrada';
    String? sucursalDestinoId;

    final provider = context.read<InventarioProvider>();
    final auth = context.read<AuthProvider>();
    final currentSucursalId = auth.sucursalId;

    final otrasSucursales =
        auth.user?.sucursales
            .where((s) => s.id != currentSucursalId)
            .toList() ??
        [];

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
                    'Registrar Movimiento',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Tipo de Movimiento',
                      prefixIcon: Icon(Icons.swap_horiz_rounded),
                    ),
                    initialValue: tipoMovimiento,
                    isExpanded: true,
                    items: ['Entrada', 'Merma', 'Traslado'].map((t) {
                      return DropdownMenuItem(value: t, child: Text(t));
                    }).toList(),
                    onChanged: (v) => setModalState(() => tipoMovimiento = v!),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  DropdownButtonFormField<Producto>(
                    decoration: const InputDecoration(
                      labelText: 'Producto',
                      prefixIcon: Icon(Icons.inventory_2_outlined),
                    ),
                    initialValue: selectedProduct,
                    isExpanded: true,
                    items: provider.productos.map((p) {
                      return DropdownMenuItem(
                        value: p,
                        child: Text(p.nombre, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (p) => setModalState(() => selectedProduct = p),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  if (tipoMovimiento == 'Traslado' &&
                      otrasSucursales.isNotEmpty) ...[
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Sucursal Destino',
                        prefixIcon: Icon(Icons.store_rounded),
                      ),
                      initialValue: sucursalDestinoId,
                      isExpanded: true,
                      items: otrasSucursales.map((s) {
                        return DropdownMenuItem(
                          value: s.id,
                          child: Text(
                            s.nombre,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (s) =>
                          setModalState(() => sucursalDestinoId = s),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  TextField(
                    controller: cantidadCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Cantidad',
                      prefixIcon: Icon(Icons.numbers),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        final cant = int.tryParse(cantidadCtrl.text) ?? 0;
                        if (selectedProduct == null || cant <= 0) return;
                        if (tipoMovimiento == 'Traslado' &&
                            sucursalDestinoId == null) {
                          return;
                        }

                        Navigator.pop(ctx);
                        bool success = false;

                        if (tipoMovimiento == 'Entrada') {
                          success = await provider.registrarEntrada(
                            sucursalId: currentSucursalId,
                            productoId: selectedProduct!.id,
                            cantidad: cant,
                            notas: 'Entrada manual desde App',
                          );
                        } else if (tipoMovimiento == 'Merma') {
                          success = await provider.registrarMerma(
                            sucursalId: currentSucursalId,
                            productoId: selectedProduct!.id,
                            cantidad: cant,
                            notas: 'Merma reportada en App',
                          );
                        } else if (tipoMovimiento == 'Traslado') {
                          success = await provider.crearTraslado(
                            sucursalOrigenId: currentSucursalId,
                            sucursalDestinoId: sucursalDestinoId!,
                            productoId: selectedProduct!.id,
                            cantidad: cant,
                          );
                        }

                        if (context.mounted) {
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Stock actualizado exitosamente'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  provider.error ?? 'Error en la operación',
                                ),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        }
                      },
                      child: const Text('Confirmar Movimiento'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showProductKardex(
    BuildContext context,
    Producto prod,
    NumberFormat currencyFmt,
  ) {
    final provider = context.read<InventarioProvider>();
    final auth = context.read<AuthProvider>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.85,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
              const SizedBox(height: 16),
              Text(
                prod.nombre,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Stock actual: ${prod.existencia ?? 0} un',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    'Venta: ${currencyFmt.format(prod.precioDisplay)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),
              const Text(
                'Kardex (Historial de Movimientos)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: FutureBuilder<List<dynamic>>(
                  future: provider.getKardex(auth.sucursalId, prod.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError ||
                        !snapshot.hasData ||
                        snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          'No hay movimientos recientes',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      );
                    }

                    final movimientos = snapshot.data!;
                    return ListView.separated(
                      itemCount: movimientos.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final m = movimientos[i];
                        final isEntrada = m['tipo'] == 'ENTRADA';
                        final date = DateTime.tryParse(m['creado_at'] ?? '');
                        final fmtDate = date != null
                            ? DateFormat('dd/MM HH:mm').format(date)
                            : '';
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: isEntrada
                                ? AppColors.successLight
                                : AppColors.error.withValues(alpha: 0.1),
                            child: Icon(
                              isEntrada
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward,
                              color: isEntrada
                                  ? AppColors.success
                                  : AppColors.error,
                              size: 18,
                            ),
                          ),
                          title: Text(m['ref_tipo'] ?? 'Movimiento'),
                          subtitle: Text(
                            '$fmtDate • ${m['usuario']?['nombre'] ?? 'Sistema'}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Text(
                            '${isEntrada ? '+' : '-'}${m['cantidad']}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isEntrada
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
