import 'package:flutter/material.dart';

import '../layouts/master_screen.dart';
import '../models/responses/news_item_response.dart';
import '../theme/app_theme.dart';
import '../utils/app_config.dart';
import '../utils/formatters.dart';

class NewsDetailScreen extends StatelessWidget {
  const NewsDetailScreen({super.key, required this.item});

  final NewsItemResponse item;

  @override
  Widget build(BuildContext context) {
    final imageUrl = AppConfig.absoluteFileUrl(item.imageUrl);

    return MasterScreen(
      title: 'Novost',
      showBackButton: true,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          if (imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const _ImageFallback(),
              ),
            ),
          if (imageUrl != null) const SizedBox(height: 18),
          Row(
            children: [
              const Icon(Icons.schedule_outlined, size: 15, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                formatDate(item.publishedAtUtc.toLocal()),
                style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 22,
              height: 1.25,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            item.content,
            style: const TextStyle(fontSize: 15, height: 1.55, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      alignment: Alignment.center,
      color: AppColors.neutralSoft,
      child: const Icon(Icons.image_not_supported_outlined, size: 40, color: AppColors.textSecondary),
    );
  }
}
