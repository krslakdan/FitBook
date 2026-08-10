import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/app_config.dart';
import '../utils/image_headers.dart';

class TrainerAvatar extends StatelessWidget {
  const TrainerAvatar({
    super.key,
    required this.firstName,
    required this.lastName,
    this.imageUrl,
    this.size = 38,
    this.borderRadius = 11,
  });

  final String firstName;
  final String lastName;
  final String? imageUrl;
  final double size;
  final double borderRadius;

  String get _initials {
    final first = firstName.trim();
    final last = lastName.trim();
    final letters =
        '${first.isEmpty ? '' : first[0]}${last.isEmpty ? '' : last[0]}';
    return letters.isEmpty ? '?' : letters.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final absoluteUrl = AppConfig.absoluteFileUrl(imageUrl);
    final radius = BorderRadius.circular(borderRadius);

    if (absoluteUrl == null) return _fallback(radius);

    return ClipRRect(
      borderRadius: radius,
      child: Image.network(
        absoluteUrl,
        headers: authorizedImageHeaders(),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _fallback(radius),
      ),
    );
  }

  Widget _fallback(BorderRadius radius) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: radius,
      ),
      child: Text(
        _initials,
        style: TextStyle(
          fontSize: size * 0.36,
          fontWeight: FontWeight.w700,
          color: AppColors.onPrimarySoft,
        ),
      ),
    );
  }
}
