import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../layouts/master_screen.dart';
import '../providers/system_notification_provider.dart';
import '../widgets/coming_soon_view.dart';
import '../widgets/notification_bell.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final SystemNotificationProvider _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = context.read<SystemNotificationProvider>();
    _notifications.refreshUnreadCount();
    _notifications.startPolling();
  }

  @override
  void dispose() {
    _notifications.stopPolling();
    super.dispose();
  }

  void _openNotifications() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'FitBook',
      subtitle: 'Vaš pregled aktivnosti',
      actions: [NotificationBell(onTap: _openNotifications)],
      child: const ComingSoonView(
        icon: Icons.dashboard_customize_outlined,
        message:
            'Početni ekran sa aktivnim rezervacijama, sljedećim treningom i preporukama je u pripremi.',
      ),
    );
  }
}
