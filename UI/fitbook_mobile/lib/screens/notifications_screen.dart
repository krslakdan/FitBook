import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../layouts/master_screen.dart';
import '../models/enums/notification_type.dart';
import '../models/responses/system_notification_response.dart';
import '../providers/main_navigation_controller.dart';
import '../providers/system_notification_provider.dart';
import '../theme/app_theme.dart';
import '../utils/api_client_exception.dart';
import '../utils/formatters.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final SystemNotificationProvider _provider;
  Timer? _pollTimer;
  bool _markingAll = false;

  @override
  void initState() {
    super.initState();
    _provider = context.read<SystemNotificationProvider>();
    _provider.loadNotifications();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _provider.loadNotifications(silent: true),
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _onRefresh() => _provider.loadNotifications(silent: true);

  Future<void> _markAsRead(int id) async {
    try {
      await _provider.markAsRead(id);
    } on ApiClientException catch (e) {
      if (mounted) _showError(e.message);
    }
  }

  static const int _reservationsTab = 2;
  static const int _membershipTab = 3;

  void _openTarget(SystemNotificationResponse notification) {
    if (!notification.isRead) _markAsRead(notification.id);
    if (widget.embedded) return;
    final targetTab = _targetTabFor(notification.notificationType);
    if (targetTab == null) return;
    context.read<MainNavigationController>().select(targetTab);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  int? _targetTabFor(NotificationType type) => switch (type) {
    NotificationType.reservationCreated ||
    NotificationType.reservationConfirmed ||
    NotificationType.reservationCancelled ||
    NotificationType.reservationCompleted ||
    NotificationType.reservationReminder => _reservationsTab,
    NotificationType.membershipPaid ||
    NotificationType.membershipExpiringSoon ||
    NotificationType.membershipExpired ||
    NotificationType.membershipCancelled ||
    NotificationType.membershipPaymentFailed => _membershipTab,
    NotificationType.newsPublished ||
    NotificationType.trainerReservationCreated ||
    NotificationType.trainerReservationCancelled ||
    NotificationType.trainerTermReminder => null,
  };

  Future<void> _markAllAsRead() async {
    setState(() => _markingAll = true);
    try {
      await _provider.markAllAsRead();
    } on ApiClientException catch (e) {
      if (mounted) _showError(e.message);
    } finally {
      if (mounted) setState(() => _markingAll = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SystemNotificationProvider>();

    return MasterScreen(
      title: 'Notifikacije',
      subtitle: provider.hasUnread ? '${provider.unreadCount} nepročitanih' : null,
      showBackButton: !widget.embedded,
      actions: [
        if (provider.hasUnread)
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: TextButton(
              onPressed: _markingAll ? null : _markAllAsRead,
              style: TextButton.styleFrom(foregroundColor: AppColors.primaryDark),
              child: _markingAll
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Označi sve'),
            ),
          ),
      ],
      child: _buildBody(provider),
    );
  }

  Widget _buildBody(SystemNotificationProvider provider) {
    if (provider.isLoading && provider.notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null && provider.notifications.isEmpty) {
      return _ErrorView(message: provider.error!, onRetry: () => provider.loadNotifications());
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.primary,
      child: provider.notifications.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [SizedBox(height: 120), _EmptyView()],
            )
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: provider.notifications.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final notification = provider.notifications[index];
                return _NotificationTile(
                  notification: notification,
                  onTap: () => _openTarget(notification),
                );
              },
            ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});

  final SystemNotificationResponse notification;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final visuals = _visualsFor(notification.notificationType);
    final unread = !notification.isRead;

    return Material(
      color: unread ? AppColors.primarySoft.withValues(alpha: 0.35) : AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: unread ? AppColors.primary.withValues(alpha: 0.35) : AppColors.border,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: visuals.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(visuals.icon, size: 22, color: visuals.foreground),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 14.5,
                              height: 1.25,
                              color: AppColors.textPrimary,
                              fontWeight: unread ? FontWeight.w700 : FontWeight.w600,
                            ),
                          ),
                        ),
                        if (unread) ...[
                          const SizedBox(width: 8),
                          Container(
                            margin: const EdgeInsets.only(top: 5),
                            width: 9,
                            height: 9,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.content,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formatRelativeTime(notification.createdAtUtc),
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationVisuals {
  const _NotificationVisuals(this.icon, this.background, this.foreground);

  final IconData icon;
  final Color background;
  final Color foreground;
}

_NotificationVisuals _visualsFor(NotificationType type) {
  return switch (type) {
    NotificationType.reservationCreated => const _NotificationVisuals(
      Icons.event_available_outlined,
      AppColors.infoSoft,
      AppColors.onInfoSoft,
    ),
    NotificationType.reservationConfirmed => const _NotificationVisuals(
      Icons.check_circle_outline,
      AppColors.primarySoft,
      AppColors.onPrimarySoft,
    ),
    NotificationType.reservationCompleted => const _NotificationVisuals(
      Icons.task_alt,
      AppColors.primarySoft,
      AppColors.onPrimarySoft,
    ),
    NotificationType.reservationReminder => const _NotificationVisuals(
      Icons.alarm,
      AppColors.warningSoft,
      AppColors.onWarningSoft,
    ),
    NotificationType.reservationCancelled => const _NotificationVisuals(
      Icons.event_busy_outlined,
      AppColors.dangerSoft,
      AppColors.onDangerSoft,
    ),
    NotificationType.membershipPaid => const _NotificationVisuals(
      Icons.workspace_premium_outlined,
      AppColors.primarySoft,
      AppColors.onPrimarySoft,
    ),
    NotificationType.membershipExpiringSoon => const _NotificationVisuals(
      Icons.hourglass_bottom,
      AppColors.warningSoft,
      AppColors.onWarningSoft,
    ),
    NotificationType.membershipExpired => const _NotificationVisuals(
      Icons.error_outline,
      AppColors.dangerSoft,
      AppColors.onDangerSoft,
    ),
    NotificationType.membershipCancelled => const _NotificationVisuals(
      Icons.cancel_outlined,
      AppColors.dangerSoft,
      AppColors.onDangerSoft,
    ),
    NotificationType.membershipPaymentFailed => const _NotificationVisuals(
      Icons.credit_card_off_outlined,
      AppColors.dangerSoft,
      AppColors.onDangerSoft,
    ),
    NotificationType.newsPublished => const _NotificationVisuals(
      Icons.campaign_outlined,
      AppColors.purpleSoft,
      AppColors.onPurpleSoft,
    ),
    NotificationType.trainerReservationCreated => const _NotificationVisuals(
      Icons.event_available_outlined,
      AppColors.infoSoft,
      AppColors.onInfoSoft,
    ),
    NotificationType.trainerReservationCancelled => const _NotificationVisuals(
      Icons.event_busy_outlined,
      AppColors.dangerSoft,
      AppColors.onDangerSoft,
    ),
    NotificationType.trainerTermReminder => const _NotificationVisuals(
      Icons.alarm,
      AppColors.warningSoft,
      AppColors.onWarningSoft,
    ),
  };
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 92,
              height: 92,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.neutralSoft,
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.notifications_off_outlined,
                size: 44,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Nema notifikacija',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ovdje će se prikazivati obavijesti o Vašim rezervacijama i članarini.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, height: 1.4, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 52, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, height: 1.4, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Pokušaj ponovo'),
            ),
          ],
        ),
      ),
    );
  }
}
