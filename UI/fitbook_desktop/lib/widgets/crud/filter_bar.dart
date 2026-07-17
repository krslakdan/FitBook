import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class FilterBar extends StatelessWidget {
  const FilterBar({super.key, required this.fields, this.actions = const []});

  final List<Widget> fields;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Wrap(spacing: 16, runSpacing: 12, children: fields),
          ),
          if (actions.isNotEmpty) ...[
            const SizedBox(width: 16),           
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < actions.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    actions[i],
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class FilterField extends StatelessWidget {
  const FilterField({super.key, required this.label, required this.child, this.width = 220});

  final String label;
  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}
