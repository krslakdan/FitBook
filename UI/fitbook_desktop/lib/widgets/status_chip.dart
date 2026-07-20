import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum ChipTone { success, warning, info, purple, neutral, danger }

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, required this.tone});

  final String label;
  final ChipTone tone;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (tone) {
      ChipTone.success => (AppColors.primarySoft, AppColors.onPrimarySoft),
      ChipTone.warning => (AppColors.warningSoft, AppColors.onWarningSoft),
      ChipTone.info => (AppColors.infoSoft, AppColors.onInfoSoft),
      ChipTone.purple => (AppColors.purpleSoft, AppColors.onPurpleSoft),
      ChipTone.neutral => (AppColors.neutralSoft, AppColors.onNeutralSoft),
      ChipTone.danger => (AppColors.dangerSoft, AppColors.onDangerSoft),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: foreground),
      ),
    );
  }
}
