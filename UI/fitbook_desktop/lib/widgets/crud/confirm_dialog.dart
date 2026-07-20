import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Obriši',
  bool danger = true,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: danger ? AppColors.dangerSoft : AppColors.warningSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              danger ? Icons.delete_outline : Icons.help_outline,
              size: 22,
              color: danger ? AppColors.onDangerSoft : AppColors.onWarningSoft,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
        ],
      ),
      content: Text(message, style: const TextStyle(fontSize: 13.5, color: AppColors.textSecondary)),
      actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Otkaži'),
        ),
        FilledButton(
          style: danger
              ? FilledButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white)
              : null,
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return confirmed == true;
}
