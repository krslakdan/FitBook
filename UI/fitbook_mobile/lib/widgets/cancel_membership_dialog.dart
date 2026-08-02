import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

Future<String?> showCancelMembershipDialog(
  BuildContext context, {
  required bool refundExpected,
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _CancelMembershipDialog(refundExpected: refundExpected),
  );
}

class _CancelMembershipDialog extends StatefulWidget {
  const _CancelMembershipDialog({required this.refundExpected});

  final bool refundExpected;

  @override
  State<_CancelMembershipDialog> createState() => _CancelMembershipDialogState();
}

class _CancelMembershipDialogState extends State<_CancelMembershipDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() => _error = 'Razlog otkazivanja je obavezan.');
      return;
    }
    Navigator.of(context).pop(text);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Otkazivanje članarine'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.refundExpected
                ? 'Članarina će biti otkazana, a povrat sredstava na Vašu karticu će biti pokrenut. Ova akcija je nepovratna.'
                : 'Članarina će biti otkazana. Ova akcija je nepovratna.',
            style: const TextStyle(fontSize: 13.5, height: 1.4, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _controller,
            maxLines: 3,
            maxLength: 500,
            inputFormatters: [LengthLimitingTextInputFormatter(500)],
            decoration: InputDecoration(
              hintText: 'Razlog otkazivanja...',
              errorText: _error,
            ),
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Odustani'),
        ),
        FilledButton(
          onPressed: _submit,
          style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
          child: const Text('Otkaži članarinu'),
        ),
      ],
    );
  }
}
