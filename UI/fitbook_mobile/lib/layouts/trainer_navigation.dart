import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/system_notification_provider.dart';
import '../screens/profile_screen.dart';
import '../screens/trainer_terms_screen.dart';
import '../widgets/app_bottom_nav.dart';

class TrainerNavigation extends StatefulWidget {
  const TrainerNavigation({super.key});

  @override
  State<TrainerNavigation> createState() => _TrainerNavigationState();
}

class _TrainerNavigationState extends State<TrainerNavigation> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    final userId = context.read<AuthProvider>().currentUserId;
    context.read<SystemNotificationProvider>().setUserScope(userId);
  }

  static const List<Widget> _screens = [
    TrainerTermsScreen(),
    ProfileScreen(),
  ];

  static const List<AppBottomNavItem> _items = [
    AppBottomNavItem(
      icon: Icons.event_note_outlined,
      activeIcon: Icons.event_note,
      label: 'Termini',
    ),
    AppBottomNavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _index,
        onTap: (index) => setState(() => _index = index),
        items: _items,
      ),
    );
  }
}
