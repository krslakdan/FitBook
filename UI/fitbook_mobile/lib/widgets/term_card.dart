import 'package:flutter/material.dart';

import '../models/responses/training_term_response.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class TermCard extends StatelessWidget {
  const TermCard({super.key, required this.term, required this.onTap});

  final TrainingTermResponse term;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final trainer = '${term.trainerFirstName} ${term.trainerLastName}'.trim();

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.infoSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.event_outlined, size: 22, color: AppColors.onInfoSoft),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatDateWithWeekday(term.startTimeUtc.toLocal()),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatTimeRange(term.startTimeUtc, term.endTimeUtc),
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    TermInfoLine(icon: Icons.person_outline, text: trainer.isEmpty ? 'Trener' : trainer),
                    const SizedBox(height: 4),
                    TermInfoLine(icon: Icons.place_outlined, text: term.hallName),
                    const SizedBox(height: 8),
                    TermCapacityPill(reserved: term.reservedCount, max: term.maxParticipants),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 6, top: 2),
                child: Icon(Icons.chevron_right, size: 20, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TermCapacityPill extends StatelessWidget {
  const TermCapacityPill({super.key, required this.reserved, required this.max});

  final int reserved;
  final int max;

  @override
  Widget build(BuildContext context) {
    final free = (max - reserved).clamp(0, max);
    final isFull = reserved >= max;
    final (background, foreground) = isFull
        ? (AppColors.dangerSoft, AppColors.onDangerSoft)
        : (AppColors.primarySoft, AppColors.onPrimarySoft);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isFull ? Icons.block : Icons.people_alt_outlined, size: 13, color: foreground),
          const SizedBox(width: 5),
          Text(
            isFull ? 'Popunjeno · $reserved/$max' : '$free slobodnih · $reserved/$max',
            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: foreground),
          ),
        ],
      ),
    );
  }
}

class TermInfoLine extends StatelessWidget {
  const TermInfoLine({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

class MessageBox extends StatelessWidget {
  const MessageBox({super.key, required this.icon, required this.message, this.action});

  final IconData icon;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13.5, height: 1.4, color: AppColors.textSecondary),
          ),
          if (action != null) ...[
            const SizedBox(height: 16),
            action!,
          ],
        ],
      ),
    );
  }
}
