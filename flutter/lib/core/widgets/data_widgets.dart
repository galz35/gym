import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// ─── Paginated Data Table Widget ──────────────────────────────
class PaginatedDataWidget<T extends Object> extends StatefulWidget {
  final List<T> items;
  final int itemsPerPage;
  final Widget Function(T item, int index) itemBuilder;
  final String? emptyMessage;
  final bool isLoading;
  final VoidCallback? onLoadMore;
  final bool hasMore;

  const PaginatedDataWidget({
    super.key,
    required this.items,
    this.itemsPerPage = 20,
    required this.itemBuilder,
    this.emptyMessage,
    this.isLoading = false,
    this.onLoadMore,
    this.hasMore = false,
  });

  @override
  State<PaginatedDataWidget<T>> createState() => _PaginatedDataWidgetState<T>();
}

class _PaginatedDataWidgetState<T extends Object>
    extends State<PaginatedDataWidget<T>> {
  int _currentPage = 0;

  int get _totalPages =>
      (widget.items.length / widget.itemsPerPage).ceil().clamp(1, 9999);

  List<T> get _pageItems {
    final start = _currentPage * widget.itemsPerPage;
    final end = (start + widget.itemsPerPage).clamp(0, widget.items.length);
    if (start >= widget.items.length) return [];
    return widget.items.sublist(start, end);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xxxl),
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (widget.items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxxl),
          child: Text(
            widget.emptyMessage ?? 'No hay datos',
            style: const TextStyle(color: AppColors.textTertiary, fontSize: 14),
          ),
        ),
      );
    }

    return Column(
      children: [
        ...List.generate(_pageItems.length, (i) {
          final globalIndex = _currentPage * widget.itemsPerPage + i;
          return widget.itemBuilder(_pageItems[i], globalIndex);
        }),
        if (_totalPages > 1) _buildPagination(),
      ],
    );
  }

  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _PaginationButton(
            icon: Icons.chevron_left_rounded,
            enabled: _currentPage > 0,
            onTap: () => setState(() => _currentPage--),
          ),
          const SizedBox(width: AppSpacing.sm),
          ...List.generate(_totalPages.clamp(0, 5), (i) {
            final pageIndex = _getPageIndex(i);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: _PageNumber(
                number: pageIndex + 1,
                isActive: pageIndex == _currentPage,
                onTap: () => setState(() => _currentPage = pageIndex),
              ),
            );
          }),
          if (_totalPages > 5) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                '...',
                style: TextStyle(color: AppColors.textTertiary),
              ),
            ),
            _PageNumber(
              number: _totalPages,
              isActive: _currentPage == _totalPages - 1,
              onTap: () => setState(() => _currentPage = _totalPages - 1),
            ),
          ],
          const SizedBox(width: AppSpacing.sm),
          _PaginationButton(
            icon: Icons.chevron_right_rounded,
            enabled: _currentPage < _totalPages - 1,
            onTap: () => setState(() => _currentPage++),
          ),
        ],
      ),
    );
  }

  int _getPageIndex(int displayIndex) {
    if (_totalPages <= 5) return displayIndex;
    if (_currentPage < 3) return displayIndex;
    if (_currentPage > _totalPages - 4) return _totalPages - 5 + displayIndex;
    return _currentPage - 2 + displayIndex;
  }
}

class _PaginationButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _PaginationButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: enabled ? AppColors.surfaceVariant : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled ? AppColors.textPrimary : AppColors.textTertiary,
        ),
      ),
    );
  }
}

class _PageNumber extends StatelessWidget {
  final int number;
  final bool isActive;
  final VoidCallback onTap;

  const _PageNumber({
    required this.number,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        alignment: Alignment.center,
        child: Text(
          '$number',
          style: TextStyle(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// ─── Autocomplete Search Field ─────────────────────────────────
class AutocompleteSearchField<T extends Object> extends StatelessWidget {
  final List<T> options;
  final String Function(T) displayStringForOption;
  final ValueChanged<T> onSelected;
  final String hint;
  final Widget Function(BuildContext, T, bool)? optionBuilder;

  const AutocompleteSearchField({
    super.key,
    required this.options,
    required this.displayStringForOption,
    required this.onSelected,
    this.hint = 'Buscar...',
    this.optionBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Autocomplete<T>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) return const Iterable.empty();
        final query = textEditingValue.text.toLowerCase();
        return options.where(
          (o) => displayStringForOption(o).toLowerCase().contains(query),
        );
      },
      displayStringForOption: displayStringForOption,
      onSelected: onSelected,
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppColors.textTertiary,
              size: 20,
            ),
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    onPressed: () => controller.clear(),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.textTertiary,
                      size: 18,
                    ),
                  )
                : null,
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 240),
              width: MediaQuery.of(context).size.width - AppSpacing.lg * 2,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.border),
              ),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                shrinkWrap: true,
                itemCount: options.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final option = options.elementAt(i);
                  final isHighlighted =
                      AutocompleteHighlightedOption.of(context) == i;
                  if (optionBuilder != null) {
                    return GestureDetector(
                      onTap: () => onSelected(option),
                      child: optionBuilder!(context, option, isHighlighted),
                    );
                  }
                  return ListTile(
                    dense: true,
                    selected: isHighlighted,
                    selectedTileColor: AppColors.primarySurface,
                    title: Text(
                      displayStringForOption(option),
                      style: const TextStyle(fontSize: 14),
                    ),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
