import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/shimmer_widgets.dart';
import '../../core/widgets/premium_widgets.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/pos_provider.dart';
import '../../core/providers/caja_provider.dart';
import '../../core/models/models.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'Todos';

  @override
  void initState() {
    super.initState();
    // Load products and check caja status on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PosProvider>().loadProductos();
      context.read<CajaProvider>().loadCajaAbierta();
    });
  }

  @override
  Widget build(BuildContext context) {
    final posProvider = context.watch<PosProvider>();
    // final cajaProvider = context.watch<CajaProvider>();

    // Calculate categories from loaded products
    final categories = [
      'Todos',
      ...posProvider.allProductos
          .map((p) => p.categoria ?? 'Sin Categoría')
          .toSet(),
    ];

    // Removed Caja lock as it's now optional.
    // We can show a small warning banner instead or just proceed.

    final filteredProducts = posProvider.productos.where((p) {
      if (_selectedCategory == 'Todos') return true;
      return (p.categoria ?? 'Sin Categoría') == _selectedCategory;
    }).toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('Venta Rápida'),
            floating: true,
            pinned: true,
            actions: [
              Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    onPressed: () => _showCartSheet(context),
                    icon: const Icon(Icons.shopping_cart_rounded),
                    tooltip: 'Ver Carrito',
                  ),
                  if (!posProvider.cartIsEmpty)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${posProvider.totalItems}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 8),
            ],
            // The bottom property of SliverAppBar is removed.
            // The search bar is now a separate SliverToBoxAdapter.
          ),

          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => posProvider.setSearch(v),
                  decoration: InputDecoration(
                    hintText: 'Buscar productos...',
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
                              posProvider.setSearch('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.transparent,
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

          // ─── Categories ───
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: FilterChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() => _selectedCategory = cat);
                      },
                      selectedColor: AppColors.primary.withValues(alpha: 0.1),
                      checkmarkColor: AppColors.primary,
                      backgroundColor: AppColors.surface,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        fontSize: 13,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                      showCheckmark: false,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

          // ─── Product Grid ───
          if (posProvider.isLoading)
            const SliverToBoxAdapter(child: ShimmerProductGrid())
          else if (filteredProducts.isEmpty)
            const SliverFillRemaining(
              child: EmptyState(
                icon: Icons.inventory_2_outlined,
                title: 'No hay productos',
                subtitle: 'No se encontraron productos en esta categoría',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final product = filteredProducts[index];
                  return _buildProductCard(product, context);
                }, childCount: filteredProducts.length),
              ),
            ),

          // Bottom padding to avoid FAB overlap if present
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildProductCard(Producto product, BuildContext context) {
    final currencyFmt = NumberFormat.currency(
      locale: 'es_NI',
      symbol: 'C\$',
      decimalDigits: 2,
    );
    final hasImage = product.fotoUrl != null && product.fotoUrl!.isNotEmpty;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ScaleOnTap(
      onTap: () {
        context.read<PosProvider>().addToCart(product);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(child: Text('${product.nombre} agregado')),
              ],
            ),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.success,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            width: 280,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
          boxShadow: isDark ? AppColors.cardShadowDark : AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.md),
                ),
                child: hasImage
                    ? CachedNetworkImage(
                        imageUrl: product.fotoUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) =>
                            _buildPlaceholder(product),
                      )
                    : _buildPlaceholder(product),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        currencyFmt.format(product.precioDisplay),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(Producto product) {
    final initial = product.nombre.isNotEmpty
        ? product.nombre[0].toUpperCase()
        : '?';
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.primary.withValues(alpha: 0.02),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIconForCategory(product.categoria),
              size: 32,
              color: AppColors.primary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 4),
            Text(
              initial,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForCategory(String? category) {
    if (category == null) return Icons.inventory_2_outlined;
    final cat = category.toLowerCase();
    if (cat.contains('bebida')) return Icons.local_drink_rounded;
    if (cat.contains('snack') || cat.contains('comida')) {
      return Icons.lunch_dining_rounded;
    }
    if (cat.contains('accesorio')) return Icons.fitness_center_rounded;
    if (cat.contains('suplemento')) return Icons.science_rounded;
    if (cat.contains('servicio')) return Icons.spa_rounded;
    return Icons.sell_rounded;
  }

  void _showCartSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const CartSheet(),
    );
  }
}

class CartSheet extends StatelessWidget {
  const CartSheet({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch PosProvider directly
    final posProvider = context.watch<PosProvider>();
    final currencyFmt = NumberFormat.currency(
      locale: 'es_NI',
      symbol: 'C\$',
      decimalDigits: 2,
    );

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle/Close indicator
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              8,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.shopping_cart_rounded,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Carrito (${posProvider.totalItems})',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                if (!posProvider.cartIsEmpty)
                  TextButton(
                    onPressed: () => posProvider.clearCart(),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                    child: const Text('Vaciar'),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Items
          Expanded(
            child: posProvider.cartIsEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.textTertiary.withValues(
                              alpha: 0.1,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.shopping_basket_outlined,
                            size: 48,
                            color: AppColors.textTertiary.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Tu carrito está vacío',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Agrega productos para realizar una venta',
                          style: TextStyle(color: AppColors.textTertiary),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: posProvider.cart.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final item = posProvider.cart[index];
                      return Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: const Icon(
                              Icons.local_offer,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.producto.nombre,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  currencyFmt.format(
                                    item.producto.precioDisplay,
                                  ),
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                _QuantityButton(
                                  icon: Icons.remove,
                                  onPressed: () => posProvider.updateQuantity(
                                    index,
                                    item.cantidad - 1,
                                  ),
                                ),
                                Container(
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${item.cantidad}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                _QuantityButton(
                                  icon: Icons.add,
                                  onPressed: () => posProvider.updateQuantity(
                                    index,
                                    item.cantidad + 1,
                                  ),
                                  isAdd: true,
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),

          // Footer
          if (!posProvider.cartIsEmpty)
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: AppColors.elevatedShadow,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total a Pagar',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          currencyFmt.format(posProvider.totalDisplay),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => _confirmPurchase(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.check_circle_outline_rounded),
                            SizedBox(width: 12),
                            Text(
                              'Cobrar',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _confirmPurchase(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Método de Pago'),
        content: const Text('Seleccione cómo pagará el cliente las compras:'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        actionsPadding: const EdgeInsets.all(16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ...['EFECTIVO', 'TARJETA', 'TRANSFERENCIA'].map((metodo) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: FilledButton(
                onPressed: () => _processSale(context, ctx, metodo),
                child: Text(metodo),
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _processSale(
    BuildContext context,
    BuildContext dialogContext,
    String metodo,
  ) async {
    Navigator.pop(dialogContext); // Close dialog
    final auth = context.read<AuthProvider>();
    final pos = context.read<PosProvider>();
    final caja = context.read<CajaProvider>();

    final venta = await pos.processSale(
      sucursalId: auth.sucursalId,
      cajaId: caja.hasCajaAbierta ? caja.cajaAbierta!.id : null,
      metodo: metodo,
    );

    if (context.mounted) {
      if (venta != null) {
        Navigator.pop(context); // Close cart sheet
        _showSuccessDialog(context, venta.totalCentavos / 100);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(pos.error ?? 'Error al procesar venta'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showSuccessDialog(BuildContext context, double total) {
    final currencyFmt = NumberFormat.currency(
      locale: 'es_NI',
      symbol: 'C\$',
      decimalDigits: 2,
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        contentPadding: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.successLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: AppColors.success,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '¡Venta Exitosa!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              currencyFmt.format(total),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Nueva Venta'),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isAdd;

  const _QuantityButton({
    required this.icon,
    required this.onPressed,
    this.isAdd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isAdd ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isAdd ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
