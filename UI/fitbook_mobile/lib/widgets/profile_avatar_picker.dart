import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/app_theme.dart';
import '../utils/app_config.dart';

class ProfileAvatarPicker extends StatelessWidget {
  const ProfileAvatarPicker({
    super.key,
    required this.initials,
    required this.onPicked,
    this.pickedBytes,
    this.existingImageUrl,
    this.enabled = true,
  });

  final String initials;
  final Uint8List? pickedBytes;
  final String? existingImageUrl;
  final bool enabled;
  final void Function(Uint8List bytes, String fileName) onPicked;

  static const double _size = 108;

  Future<void> _pick() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    onPicked(bytes, file.name);
  }

  @override
  Widget build(BuildContext context) {
    final existingUrl = AppConfig.absoluteFileUrl(existingImageUrl);

    Widget avatar;
    if (pickedBytes != null) {
      avatar = Image.memory(pickedBytes!, width: _size, height: _size, fit: BoxFit.cover);
    } else if (existingUrl != null) {
      avatar = Image.network(
        existingUrl,
        width: _size,
        height: _size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _initialsAvatar(),
      );
    } else {
      avatar = _initialsAvatar();
    }

    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: _size,
            height: _size,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border, width: 2),
            ),
            child: avatar,
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: Material(
              color: enabled ? AppColors.primary : AppColors.textSecondary,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: enabled ? _pick : null,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: 2),
                  ),
                  child: const Icon(Icons.camera_alt_outlined, size: 18, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _initialsAvatar() {
    return Container(
      width: _size,
      height: _size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
      ),
      child: Text(
        initials,
        style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w700),
      ),
    );
  }
}
