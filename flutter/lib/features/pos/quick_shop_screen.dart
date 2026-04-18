import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/pos_provider.dart';
import '../../core/providers/inventario_provider.dart';
import '../../core/providers/caja_provider.dart';
import '../../core/models/models.dart';

class QuickShopScreen extends StatefulWidget {
  const QuickShopScreen({super.key});

  @override
  State<QuickShopScreen> createState() => _QuickShopScreenState();
}

class _QuickShopScreenState extends State<QuickShopScreen> {
  final NumberFormat _currencyFmt = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );
  late AuthProvider _auth;
  String? _lastSucursalId;

  @override
  void initState() {
    super.initState();
    _auth = context.read<AuthProvider>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _auth = Provider.of<AuthProvider>(context);
    if (_auth.sucursalId == _lastSucursalId) return;
    _lastSucursalId = _auth.sucursalId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PosProvider>().clearCart();
      _loadData();
    });
  }

  void _loadData() {
    final invProv = context.read<InventarioProvider>();
    if (_auth.sucursalId.isNotEmpty) {
      invProv.loadStockSucursal(_auth.sucursalId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final invProv = context.watch<InventarioProvider>();
    final posProv = context.watch<PosProvider>();
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(invProv, cs, isDark),
            Expanded(
              child: invProv.isLoading && invProv.productos.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : invProv.productos.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: isDark
                                ? Colors.white24
                                : AppColors.textTertiary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay productos registrados.\nPresiona "Nuevo Prod." para agregar.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark
                                  ? Colors.white54
                                  : AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      itemCount: invProv.productos.length,
                      itemBuilder: (context, index) {
                        final prod = invProv.productos[index];
                        return _buildProductCard(
                          context,
                          prod,
                          posProv,
                          invProv,
                          cs,
                          isDark,
                        );
                      },
                    ),
            ),
            if (!posProv.cartIsEmpty) _buildCartBottomBar(posProv, cs, isDark),
          ],
        ),
      ),
      floatingActionButton: posProv.cartIsEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _showNewProductSheet(context, invProv),
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Nuevo Prod.',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildHeader(InventarioProvider invProv, ColorScheme cs, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark : AppColors.primarySurface,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Tienda & Stock',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(14),
              boxShadow: isDark
                  ? AppColors.cardShadowDark
                  : AppColors.cardShadow,
            ),
            child: TextField(
              onChanged: (val) => invProv.setSearch(val),
              decoration: InputDecoration(
                hintText: 'Buscar agua, proteína...',
                hintStyle: TextStyle(color: AppColors.textTertiary),
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    Producto prod,
    PosProvider posProv,
    InventarioProvider invProv,
    ColorScheme cs,
    bool isDark,
  ) {
    final stock = prod.existencia ?? 0;
    final isLowStock = stock <= 0;

    return GestureDetector(
      onTap: () {
        if (!isLowStock) {
          posProv.addToCart(prod);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sin stock disponible'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isLowStock
                ? Colors.red.withValues(alpha: 0.3)
                : (isDark ? AppColors.borderDark : AppColors.border),
          ),
          boxShadow: isDark ? AppColors.cardShadowDark : AppColors.cardShadow,
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Placeholder para la imagen
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Container(
                      color: isDark
                          ? AppColors.surfaceVariantDark
                          : AppColors.surfaceVariant,
                      child: Center(
                        child: Icon(
                          Icons.inventory_2_outlined,
                          size: 40,
                          color: isDark
                              ? Colors.white24
                              : AppColors.textTertiary.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prod.nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _currencyFmt.format(prod.precioCentavos / 100),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Badge de stock
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isLowStock
                      ? AppColors.errorLight
                      : (isDark ? AppColors.surfaceDark : cs.surface),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isLowStock
                        ? Colors.red
                        : (isDark ? AppColors.borderDark : AppColors.border),
                  ),
                ),
                child: Text(
                  '$stock disp.',
                  style: TextStyle(
                    color: isLowStock
                        ? AppColors.error
                        : (isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Botón de agregar stock
            Positioned(
              top: 8,
              left: 8,
              child: InkWell(
                onTap: () => _showAddStockDialog(context, invProv, prod),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.infoLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_box,
                    size: 16,
                    color: AppColors.info,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartBottomBar(PosProvider posProv, ColorScheme cs, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: isDark ? AppColors.cardShadowDark : AppColors.elevatedShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: posProv.cart.length,
              itemBuilder: (ctx, i) {
                final item = posProv.cart[i];
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceVariantDark
                        : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${item.cantidad}x ${item.producto.nombre}',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => posProv.removeFromCart(i),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                      fontSize: 12,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _currencyFmt.format(posProv.totalDisplay),
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: posProv.isProcessing
                      ? null
                      : () => _showPaymentOptions(context, posProv),
                  child: posProv.isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'COBRAR',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showPaymentOptions(
    BuildContext parentContext,
    PosProvider posProv,
  ) async {
    final cajaProv = parentContext.read<CajaProvider>();
    if (cajaProv.cajaAbierta == null) {
      ScaffoldMessenger.of(parentContext).showSnackBar(
        const SnackBar(
          content: Text('No hay caja abierta para asignar la venta'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: parentContext,
      backgroundColor: Theme.of(parentContext).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'MÉTODO DE PAGO',
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 16),
                _btnPay(
                  parentContext,
                  bottomSheetContext,
                  posProv,
                  'EFECTIVO',
                  Icons.payments,
                  Colors.green,
                ),
                const SizedBox(height: 12),
                _btnPay(
                  parentContext,
                  bottomSheetContext,
                  posProv,
                  'TARJETA',
                  Icons.credit_card,
                  Colors.blue,
                ),
                const SizedBox(height: 12),
                _btnPay(
                  parentContext,
                  bottomSheetContext,
                  posProv,
                  'TRANSFERENCIA',
                  Icons.sync_alt,
                  Colors.orange,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _btnPay(
    BuildContext screenCtx,
    BuildContext sheetCtx,
    PosProvider posProv,
    String method,
    IconData icon,
    Color color,
  ) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.15),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withValues(alpha: 0.4)),
        ),
        elevation: 0,
      ),
      icon: Icon(icon, color: color),
      label: Text(
        method,
        style: TextStyle(fontWeight: FontWeight.bold, color: color),
      ),
      onPressed: () async {
        Navigator.pop(sheetCtx);
        final venta = await posProv.processSale(
          sucursalId: _auth.sucursalId,
          cajaId: screenCtx.read<CajaProvider>().cajaAbierta?.id,
          metodo: method,
        );

        if (venta != null && screenCtx.mounted) {
          ScaffoldMessenger.of(screenCtx).showSnackBar(
            SnackBar(content: Text('Venta cobrada con éxito ($method)')),
          );
          screenCtx.read<InventarioProvider>().loadStockSucursal(
            _auth.sucursalId,
          );
        } else if (posProv.error != null && screenCtx.mounted) {
          ScaffoldMessenger.of(screenCtx).showSnackBar(
            SnackBar(
              content: Text(posProv.error!),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

  void _showAddStockDialog(
    BuildContext context,
    InventarioProvider invProv,
    Producto prod,
  ) {
    final ctrl = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark
            ? AppColors.surfaceDark
            : Theme.of(context).colorScheme.surface,
        title: Text(
          'Trajeron mercancía',
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Producto: ${prod.nombre}',
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              style: TextStyle(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
                fontSize: 24,
              ),
              decoration: InputDecoration(
                labelText: 'Cantidad ingresada',
                labelStyle: TextStyle(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final val = int.tryParse(ctrl.text);
              if (val != null && val > 0) {
                Navigator.pop(ctx);
                final ok = await invProv.registrarEntrada(
                  sucursalId: _auth.sucursalId,
                  productoId: prod.id,
                  cantidad: val,
                );
                if (ok && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Stock actualizado')),
                  );
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(invProv.error ?? 'Error al actualizar'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showNewProductSheet(BuildContext context, InventarioProvider invProv) {
    final nombreCtrl = TextEditingController();
    final precioCtrl = TextEditingController();
    final stockCtrl = TextEditingController();
    bool isLoading = false;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
              top: 24,
              left: 24,
              right: 24,
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceDark
                  : Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'NUEVO PRODUCTO',
                  style: TextStyle(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nombreCtrl,
                  style: TextStyle(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Nombre ej. Agua 600ml',
                    labelStyle: TextStyle(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: precioCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Precio \$',
                          labelStyle: TextStyle(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: stockCtrl,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Stock Inicial',
                          labelStyle: TextStyle(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (nombreCtrl.text.isEmpty ||
                              precioCtrl.text.isEmpty) {
                            return;
                          }
                          setState(() => isLoading = true);

                          final pre = double.tryParse(precioCtrl.text) ?? 0;
                          final stk = int.tryParse(stockCtrl.text) ?? 0;

                          final prod = await invProv.createProducto({
                            'empresaId': _auth.empresaId,
                            'nombre': nombreCtrl.text,
                            'precio': pre,
                            'costo': pre * 0.5,
                            'categoria': 'Bebidas',
                          });

                          if (prod != null && stk > 0) {
                            await invProv.registrarEntrada(
                              sucursalId: _auth.sucursalId,
                              productoId: prod.id,
                              cantidad: stk,
                            );
                          }

                          setState(() => isLoading = false);
                          if (sheetCtx.mounted) Navigator.pop(sheetCtx);
                          if (prod != null && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Producto creado')),
                            );
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'GUARDAR',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
