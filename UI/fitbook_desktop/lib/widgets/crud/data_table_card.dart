import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class ColumnSpec {
  const ColumnSpec(this.label, {this.flex = 1, this.width, this.alignment = Alignment.centerLeft});

  final String label;
  final int flex;
  final double? width;
  final Alignment alignment;
}

class DataTableCard<T> extends StatelessWidget {
  const DataTableCard({
    super.key,
    required this.title,
    required this.columns,
    required this.items,
    required this.cellsBuilder,
    required this.page,
    required this.pageSize,
    required this.onPageChanged,
    required this.onPageSizeChanged,
    required this.onRefresh,
    this.totalCount,
    this.totalPages,
    this.loading = false,
    this.error,
    this.itemsLabel = 'zapisa',
    this.emptyMessage = 'Nema zapisa za prikaz.',
    this.pageSizeOptions = const [5, 10, 25, 50],
    this.rowHeight = 64,
  });

  final String title;
  final List<ColumnSpec> columns;
  final List<T> items;
  final List<Widget> Function(BuildContext context, T item) cellsBuilder;
  final int page;
  final int pageSize;
  final int? totalCount;
  final int? totalPages;
  final bool loading;
  final String? error;
  final String itemsLabel;
  final String emptyMessage;
  final List<int> pageSizeOptions;
  final double rowHeight;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onPageSizeChanged;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context),
          _buildColumnsRow(),
          Expanded(child: _buildBody(context)),
          const Divider(height: 1),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 16, 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Osvježi',
            onPressed: loading ? null : onRefresh,
            icon: const Icon(Icons.refresh, size: 20),
            style: IconButton.styleFrom(
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: pageSize,
                borderRadius: BorderRadius.circular(10),
                style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                items: [
                  for (final size in pageSizeOptions)
                    DropdownMenuItem(value: size, child: Text('$size po stranici')),
                ],
                onChanged: loading
                    ? null
                    : (value) {
                        if (value != null && value != pageSize) onPageSizeChanged(value);
                      },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColumnsRow() {
    return Container(
      color: AppColors.tableHeaderBackground,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          for (final column in columns)
            _cell(
              column,
              Text(
                column.label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (loading && items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 36, color: AppColors.danger),
            const SizedBox(height: 12),
            Text(error!, style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Pokušaj ponovo'),
            ),
          ],
        ),
      );
    }

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_outlined, size: 36, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(emptyMessage, style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return Opacity(
      opacity: loading ? 0.55 : 1,
      child: IgnorePointer(
        ignoring: loading,
        child: ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final cells = cellsBuilder(context, items[index]);
            assert(cells.length == columns.length, 'Broj ćelija mora odgovarati broju kolona.');
            return SizedBox(
              height: rowHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    for (var i = 0; i < columns.length; i++) _cell(columns[i], cells[i]),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _cell(ColumnSpec spec, Widget child) {
    final aligned = Align(alignment: spec.alignment, child: child);
    if (spec.width != null) {
      return SizedBox(width: spec.width, child: aligned);
    }
    return Expanded(flex: spec.flex, child: aligned);
  }

  Widget _buildFooter(BuildContext context) {
    final from = items.isEmpty ? 0 : (page - 1) * pageSize + 1;
    final to = (page - 1) * pageSize + items.length;
    final total = totalCount;
    final pages = totalPages ?? 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              total == null
                  ? 'Prikazano $from do $to $itemsLabel'
                  : 'Prikazano $from do $to od $total $itemsLabel',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
          _PageButton(
            icon: Icons.arrow_back,
            enabled: page > 1 && !loading,
            onTap: () => onPageChanged(page - 1),
          ),
          for (final item in _pageItems(page, pages)) ...[
            const SizedBox(width: 6),
            if (item == null)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text('…', style: TextStyle(color: AppColors.textSecondary)),
              )
            else
              _PageButton(
                label: '$item',
                selected: item == page,
                enabled: !loading,
                onTap: () => onPageChanged(item),
              ),
          ],
          const SizedBox(width: 6),
          _PageButton(
            icon: Icons.arrow_forward,
            enabled: page < pages && !loading,
            onTap: () => onPageChanged(page + 1),
          ),
        ],
      ),
    );
  }

  static List<int?> _pageItems(int current, int totalPages) {
    if (totalPages <= 1) return [1];
    if (totalPages <= 7) return [for (var i = 1; i <= totalPages; i++) i];

    final pages = <int?>[1];
    if (current > 3) pages.add(null);
    for (var i = current - 1; i <= current + 1; i++) {
      if (i > 1 && i < totalPages) pages.add(i);
    }
    if (current < totalPages - 2) pages.add(null);
    pages.add(totalPages);
    return pages;
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({this.label, this.icon, this.selected = false, this.enabled = true, required this.onTap});

  final String? label;
  final IconData? icon;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = selected
        ? AppColors.onPrimarySoft
        : enabled
        ? AppColors.textPrimary
        : AppColors.textSecondary.withValues(alpha: 0.5);

    return Material(
      color: selected ? AppColors.primarySoft : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: enabled ? onTap : null,
        child: Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: selected ? AppColors.primary : AppColors.border),
          ),
          child: icon != null
              ? Icon(icon, size: 16, color: foreground)
              : Text(
                  label!,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: foreground),
                ),
        ),
      ),
    );
  }
}
