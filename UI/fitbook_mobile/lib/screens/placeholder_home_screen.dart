import 'package:flutter/material.dart';

import '../utils/app_config.dart';

class PlaceholderHomeScreen extends StatelessWidget {
  const PlaceholderHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('FitBook')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.fitness_center, size: 64, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text('FitBook Mobile', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                'Osnova aplikacije je spremna (modeli i provideri). Ekrani se dodaju u sljedećem koraku.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              Text('API: ${AppConfig.apiBaseUrl}', style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
