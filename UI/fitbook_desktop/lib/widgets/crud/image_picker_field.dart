import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../utils/app_config.dart';

class ImagePickerField extends StatelessWidget {
  const ImagePickerField({
    super.key,
    required this.label,
    required this.onPicked,
    this.pickedBytes,
    this.existingImageUrl,
    this.enabled = true,
    this.errorText,
  });

  final String label;
  final Uint8List? pickedBytes;
  final String? existingImageUrl;
  final bool enabled;
  final String? errorText;
  final void Function(Uint8List bytes, String fileName) onPicked;

  static const _typeGroup = XTypeGroup(
    label: 'Slike',
    extensions: ['jpg', 'jpeg', 'png', 'webp'],
  );

  Future<void> _pick() async {
    final file = await openFile(acceptedTypeGroups: const [_typeGroup]);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    onPicked(bytes, file.name);
  }

  @override
  Widget build(BuildContext context) {
    final existingUrl = AppConfig.absoluteFileUrl(existingImageUrl);

    Widget preview;
    if (pickedBytes != null) {
      preview = ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.memory(pickedBytes!, width: 132, height: 132, fit: BoxFit.cover),
      );
    } else if (existingUrl != null) {
      preview = ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          existingUrl,
          width: 132,
          height: 132,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _placeholderIcon(),
        ),
      );
    } else {
      preview = _placeholderIcon();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: enabled ? _pick : null,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.tableHeaderBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: errorText == null ? AppColors.border : AppColors.danger,
              ),
            ),
            child: Column(
              children: [
                preview,
                const SizedBox(height: 14),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Kliknite za odabir slike',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const Text(
                  'JPG, PNG ili WebP do 5 MB',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              errorText!,
              style: const TextStyle(fontSize: 12, color: AppColors.danger),
            ),
          ),
      ],
    );
  }

  Widget _placeholderIcon() {
    return Container(
      width: 132,
      height: 132,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: const Icon(Icons.image_outlined, size: 44, color: AppColors.textSecondary),
    );
  }
}
