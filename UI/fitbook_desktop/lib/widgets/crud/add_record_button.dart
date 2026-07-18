import 'package:flutter/material.dart';

/// Dugme za dodavanje zapisa koje je onemogućeno dok FK preduslovi
/// nisu ispunjeni, uz tooltip sa objašnjenjem razloga nedostupnosti.
class AddRecordButton extends StatelessWidget {
  const AddRecordButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.disabledReason,
  });

  final String label;
  final VoidCallback onPressed;

  /// Kada nije null, dugme je onemogućeno, a razlog se prikazuje kao tooltip.
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
