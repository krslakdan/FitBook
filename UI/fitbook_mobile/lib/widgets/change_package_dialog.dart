import 'package:flutter/material.dart';

import '../models/responses/membership_package_response.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

Future<MembershipPackageResponse?> showChangePackageDialog(
  BuildContext context, {
  required List<MembershipPackageResponse> packages,
  required String currentPackageName,
  required bool refundExpected,
}) {
  return showDialog<MembershipPackageResponse>(
    context: context,
    builder: (_) => _ChangePackageDialog(
      packages: packages,
      currentPackageName: currentPackageName,
      refundExpected: refundExpected,
    ),
  );
}

class _ChangePackageDialog extends StatefulWidget {
  const _ChangePackageDialog({
    required this.packages,
    required this.currentPackageName,
    required this.refundExpected,
  });

  final List<MembershipPackageResponse> packages;
  final String currentPackageName;
  final bool refundExpected;

  @override
  State<_ChangePackageDialog> createState() => _ChangePackageDialogState();
}

class _ChangePackageDialogState extends State<_ChangePackageDialog> {
  int? _selectedId;

  @override
  Widget build(BuildContext context) {
    final selected = _selectedId;

    return AlertDialog(
      title: const Text('Promjena paketa'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trenutni paket: ${widget.currentPackageName}',
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.refundExpected
                  ? 'Trenutna članarina će biti otkazana, a povrat sredstava na Vašu karticu će biti pokrenut. Nakon toga slijedi plaćanje novog paketa.'
                  : 'Trenutna članarina će biti otkazana, a zatim ćete platiti novi paket. Ova akcija je nepovratna.',
              style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            Flexible(
              child: SingleChildScrollView(
                child: RadioGroup<int>(
                  groupValue: _selectedId,
                  onChanged: (value) => setState(() => _selectedId = value),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final package in widget.packages)
                        RadioListTile<int>(
                          value: package.id,
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            package.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            '${formatMoney(package.price)} · ${package.durationDays} dana',
                            style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Odustani'),
        ),
        FilledButton(
          onPressed: selected == null
              ? null
              : () => Navigator.of(context).pop(
                  widget.packages.firstWhere((package) => package.id == selected),
                ),
          child: const Text('Promijeni paket'),
        ),
      ],
    );
  }
}
