import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/system_notification_provider.dart';
import '../screens/home_screen.dart';
import '../screens/membership_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/reservations_screen.dart';
import '../screens/trainings_screen.dart';
import '../widgets/app_bottom_nav.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    final userId = context.read<AuthProvider>().currentUserId;
    context.read<SystemNotificationProvider>().setUserScope(userId);
  }

  static const List<Widget> _screens = [
    HomeScreen(),
    TrainingsScreen(),
    ReservationsScreen(),
    MembershipScreen(),
    ProfileScreen(),
  ];

  static const List<AppBottomNavItem> _items = [
    AppBottomNavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Početna'),
    AppBottomNavItem(
      icon: Icons.fitness_center,
      activeIcon: Icons.fitness_center,
      label: 'Treninzi',
    ),
    AppBottomNavItem(
      icon: Icons.event_available_outlined,
      activeIcon: Icons.event_available,
      label: 'Rezervacije',
    ),
    AppBottomNavItem(
      icon: Icons.workspace_premium_outlined,
      activeIcon: Icons.workspace_premium,
      label: 'Članarina',
    ),
    AppBottomNavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profil'),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: _items,
      ),
    );
  }
}
