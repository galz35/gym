import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';

import '../../core/providers/inventario_provider.dart';
import '../../core/models/models.dart';

class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key});

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'Todos';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventarioProvider>().loadProductos();
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

    // Filter logic
    final filtered = provider.productos.where((p) {
      if (_selectedCategory == 'Todos') return true;
      return (p.categoria ?? 'Sin Categoría') == _selectedCategory;
    }).toList();

    // Extract categories
    final categories = [
      'Todos',
      ...provider.productos
          .map((p) => p.categoria ?? 'Sin Categoría')
          .toSet()
          .toSet(),
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('Catálogo de Productos'),
            floating: true,
            pinned: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(110),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => provider.setSearch(v),
                      decoration: InputDecoration(
                        hintText: 'Buscar productos...',
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: AppColors.textTertiary,
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        final isSelected = _selectedCategory == cat;
                        return FilterChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (_) =>
                              setState(() => _selectedCategory = cat),
                          selectedColor: AppColors.primary.withValues(
                            alpha: 0.1,
                          ),
                          checkmarkColor: AppColors.primary,
                          backgroundColor: AppColors.surface,
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.border,
                          ),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          if (provider.isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else if (filtered.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Text(
                  'No se encontraron productos',
                  style: TextStyle(color: AppColors.textTertiary),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75, // Taller for more info
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final p = filtered[index];
                  return _buildProductCard(p, currencyFmt);
                }, childCount: filtered.length),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateProductDialog(context),
        icon: const Icon(Icons.add_box_rounded),
        label: const Text('Nuevo Producto'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildProductCard(Producto p, NumberFormat currencyFmt) {
    final margin = p.precioCentavos > 0
        ? ((p.precioCentavos - p.costoCentavos) / p.precioCentavos * 100)
              .toStringAsFixed(0)
        : '0';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: AppSpacing.lg),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              _getIconForCategory(p.categoria),
              size: 24,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              p.nombre,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            p.categoria ?? 'General',
            style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
          ),
          const Spacer(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(AppRadius.lg),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      currencyFmt.format(p.precioDisplay),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.successLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '$margin%',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Costo: ${currencyFmt.format(p.costoDisplay)}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
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
    return Icons.sell_rounded;
  }

  void _showCreateProductDialog(BuildContext context) {
    final nombreCtrl = TextEditingController();
    final precioCtrl = TextEditingController();
    final costoCtrl = TextEditingController();
    String category = 'Bebidas'; // Default

    final categories = [
      'Bebidas',
      'Suplementos',
      'Snacks',
      'Accesorios',
      'Ropa',
      'Servicios',
      'Otros',
    ];

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
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Nuevo Producto',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: nombreCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del Producto',
                      prefixIcon: Icon(Icons.tag),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: category,
                    decoration: const InputDecoration(
                      labelText: 'Categoría',
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setModalState(() => category = v!),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: precioCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Precio Venta',
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: costoCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Costo',
                            prefixIcon: Icon(Icons.money_off),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        final nombre = nombreCtrl.text;
                        final precio = double.tryParse(precioCtrl.text) ?? 0;
                        final costo = double.tryParse(costoCtrl.text) ?? 0;

                        if (nombre.isEmpty || precio <= 0) return;

                        Navigator.pop(ctx);

                        final provider = context.read<InventarioProvider>();
                        final result = await provider.createProducto({
                          'nombre': nombre,
                          'categoria': category,
                          'precio': precio,
                          'costo': costo,
                          'estado': 'ACTIVO',
                        });

                        if (!context.mounted) return;

                        if (result != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Producto creado'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(provider.error ?? 'Error al crear'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      },
                      child: const Text('Guardar Producto'),
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
