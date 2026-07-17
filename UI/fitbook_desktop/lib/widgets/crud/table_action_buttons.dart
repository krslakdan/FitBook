import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class TableActionExtra {
  const TableActionExtra({
    required this.icon,
    required this.tooltip,
    this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final bool danger;
}

class TableActionButtons extends StatelessWidget {
  const TableActionButtons({
    super.key,
    this.onView,
    this.onEdit,
    this.onDelete,
    this.deleteDisabledReason,
    this.extras = const [],
    this.showDelete = true,
  });

  final VoidCallback? onView;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final String? deleteDisabledReason;
  final List<TableActionExtra> extras;
  final bool showDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onView != null)
          _ActionIcon(
            icon: Icons.visibility_outlined,
            tooltip: 'Pregled',
            onTap: onView,
          ),
        if (onEdit != null) ...[
          const SizedBox(width: 6),
          _ActionIcon(
            icon: Icons.edit_outlined,
            tooltip: 'Izmijeni',
            onTap: onEdit,
          ),
        ],
        for (final extra in extras) ...[
          const SizedBox(width: 6),
          _ActionIcon(
            icon: extra.icon,
            tooltip: extra.tooltip,
            foreground: extra.danger ? AppColors.onDangerSoft : null,
            background: extra.danger ? AppColors.dangerSoft : null,
            onTap: extra.onTap,
          ),
        ],
        if (showDelete) ...[
          const SizedBox(width: 6),
          _ActionIcon(
            icon: Icons.delete_outline,
            tooltip: onDelete == null ? (deleteDisabledReason ?? 'Brisanje nije dostupno.') : 'Obriši',
            foreground: AppColors.onDangerSoft,
            background: AppColors.dangerSoft,
            onTap: onDelete,
          ),
        ],
      ],
    );
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({
    required this.icon,
    required this.tooltip,
    this.onTap,
    this.foreground,
    this.background,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final Color? foreground;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final fg = enabled
        ? (foreground ?? AppColors.textSecondary)
        : AppColors.textSecondary.withValues(alpha: 0.35);

    return Tooltip(
      message: tooltip,
      child: Material(
        color: enabled ? (background ?? AppColors.neutralSoft) : AppColors.neutralSoft.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: SizedBox(
            width: 30,
            height: 30,
            child: Icon(icon, size: 16, color: fg),
          ),
        ),
      ),
    );
  }
}
