import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class MasterScreen extends StatelessWidget {
  const MasterScreen({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.actions,
    this.showBackButton = false,
    this.floatingActionButton,
    this.safeAreaBottom = true,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final List<Widget>? actions;
  final bool showBackButton;
  final Widget? floatingActionButton;
  final bool safeAreaBottom;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        automaticallyImplyLeading: showBackButton,
        titleSpacing: showBackButton ? 0 : 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title),
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  subtitle!,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
          ],
        ),
        actions: actions,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: SafeArea(bottom: safeAreaBottom, child: child),
      floatingActionButton: floatingActionButton,
    );
  }
}
