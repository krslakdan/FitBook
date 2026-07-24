import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/enums/reservation_status.dart';
import '../models/search_objects/reservation_search_object.dart';
import '../models/search_objects/trainer_search_object.dart';
import '../providers/auth_provider.dart';
import '../providers/reservation_provider.dart';
import '../providers/system_notification_provider.dart';
import '../providers/trainer_provider.dart';
import '../screens/notifications_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/trainer_dashboard_screen.dart';
import '../screens/trainer_terms_screen.dart';
import '../utils/api_client_exception.dart';
import '../widgets/app_bottom_nav.dart';

class TrainerNavigation extends StatefulWidget {
  const TrainerNavigation({super.key});

  @override
  State<TrainerNavigation> createState() => _TrainerNavigationState();
}

class _TrainerNavigationState extends State<TrainerNavigation> {
  static const int _termsTabIndex = 1;
  static const int _notificationsTabIndex = 2;

  int _index = 0;
  int? _trainerId;
  int _pendingCount = 0;
  Timer? _pendingTimer;

  @override
  void initState() {
    super.initState();
    final userId = context.read<AuthProvider>().currentUserId;
    final notifications = context.read<SystemNotificationProvider>();
    notifications.setUserScope(userId);
    notifications.refreshUnreadCount();
    _bootstrap(userId);
    _pendingTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _refreshPending(),
    );
  }

  @override
  void dispose() {
    _pendingTimer?.cancel();
    super.dispose();
  }

  Future<void> _bootstrap(int? userId) async {
    if (userId == null) return;
    try {
      final result = await context.read<TrainerProvider>().get(
        filter: const TrainerSearchObject(pageSize: 100),
      );
      int? trainerId;
      for (final trainer in result.items) {
        if (trainer.userAccountId == userId) {
          trainerId = trainer.id;
          break;
        }
      }
      if (!mounted || trainerId == null) return;
      _trainerId = trainerId;
      await _refreshPending();
    } on ApiClientException {
      return;
    }
  }

  Future<void> _refreshPending() async {
    final trainerId = _trainerId;
    if (trainerId == null) return;
    try {
      final result = await context.read<ReservationProvider>().get(
        filter: ReservationSearchObject(
          trainerId: trainerId,
          status: ReservationStatus.pending,
          pageSize: 1,
          includeTotalCount: true,
        ),
      );
      if (!mounted) return;
      setState(() => _pendingCount = result.totalCount ?? 0);
    } on ApiClientException {
      return;
    }
  }

  void _onTap(int index) {
    setState(() => _index = index);
    if (index == 0 || index == _termsTabIndex) {
      _refreshPending();
    }
    if (index == _notificationsTabIndex) {
      context.read<SystemNotificationProvider>().loadNotifications(silent: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final unread = context.watch<SystemNotificationProvider>().unreadCount;

    final screens = <Widget>[
      TrainerDashboardScreen(onGoToTerms: () => _onTap(_termsTabIndex)),
      const TrainerTermsScreen(),
      const NotificationsScreen(embedded: true),
      const ProfileScreen(),
    ];

    final items = <AppBottomNavItem>[
      const AppBottomNavItem(
        icon: Icons.today_outlined,
        activeIcon: Icons.today,
        label: 'Danas',
      ),
      AppBottomNavItem(
        icon: Icons.event_note_outlined,
        activeIcon: Icons.event_note,
        label: 'Termini',
        badgeCount: _pendingCount,
      ),
      AppBottomNavItem(
        icon: Icons.notifications_none,
        activeIcon: Icons.notifications,
        label: 'Notifikacije',
        badgeCount: unread,
      ),
      const AppBottomNavItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'Profil',
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _index,
        onTap: _onTap,
        items: items,
      ),
    );
  }
}
