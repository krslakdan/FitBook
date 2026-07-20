import 'package:flutter/material.dart';

class AddRecordButton extends StatelessWidget {
  const AddRecordButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.disabledReason,
  });

  final String label;
  final VoidCallback onPressed;

  final String? disabledReason;

  @override
  Widget build(BuildContext context) {
    final button = FilledButton.icon(
      onPressed: disabledReason == null ? onPressed : null,
      icon: const Icon(Icons.add, size: 18),
      label: Text(label),
    );
    if (disabledReason == null) return button;
    return Tooltip(message: disabledReason!, child: button);
  }
}
