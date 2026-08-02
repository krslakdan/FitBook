import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../screens/dashboard_screen.dart';
import '../screens/difficulty_levels_screen.dart';
import '../screens/equipment_screen.dart';
import '../screens/halls_screen.dart';
import '../screens/login_screen.dart';
import '../screens/membership_packages_screen.dart';
import '../screens/news_items_screen.dart';
import '../screens/reports_screen.dart';
import '../screens/reservations_screen.dart';
import '../screens/specializations_screen.dart';
import '../screens/system_notifications_screen.dart';
import '../screens/trainers_screen.dart';
import '../screens/training_categories_screen.dart';
import '../screens/training_equipment_screen.dart';
import '../screens/training_terms_screen.dart';
import '../screens/trainings_screen.dart';
import '../screens/user_accounts_screen.dart';
import '../screens/user_memberships_screen.dart';

typedef _ScreenBuilder = Widget Function();

class _NavItem {
  const _NavItem(this.title, this.subtitle, this.icon, this.selectedIcon, this.builder, {String? label})
    : label = label ?? title;

  final String title;
  final String subtitle;
  final IconData icon;
  final IconData selectedIcon;
  final _ScreenBuilder builder;
  final String label;
}

class _NavSection {
  const _NavSection(this.header, this.items);

  final String? header;
  final List<_NavItem> items;
}

final List<_NavSection> _sections = [
  _NavSection(null, [
    _NavItem(
      'Dashboard',
      'Pregled ključnih informacija o sistemu',
      Icons.home_outlined,
      Icons.home,
      () => const DashboardScreen(),
    ),
  ]),
  _NavSection('UPRAVLJANJE', [
    _NavItem(
      'Korisnici',
      'Pregled, pretraga i upravljanje korisnicima',
      Icons.group_outlined,
      Icons.group,
      () => const UserAccountsScreen(),
    ),
    _NavItem(
      'Treneri',
      'Upravljanje trenerima',
      Icons.badge_outlined,
      Icons.badge,
      () => const TrainersScreen(),
    ),
    _NavItem(
      'Treninzi',
      'Upravljanje treninzima',
      Icons.fitness_center,
      Icons.fitness_center,
      () => const TrainingsScreen(),
    ),
    _NavItem(
      'Termini',
      'Upravljanje terminima treninga',
      Icons.calendar_month_outlined,
      Icons.calendar_month,
      () => const TrainingTermsScreen(),
    ),
    _NavItem(
      'Rezervacije',
      'Pregled i upravljanje rezervacijama',
      Icons.event_available_outlined,
      Icons.event_available,
      () => const ReservationsScreen(),
    ),
  ]),
  _NavSection('ČLANARINE', [
    _NavItem(
      'Članarine',
      'Pregled članarina korisnika',
      Icons.loyalty_outlined,
      Icons.loyalty,
      () => const UserMembershipsScreen(),
    ),
    _NavItem(
      'Paketi članarina',
      'Upravljanje paketima članarina',
      Icons.card_membership_outlined,
      Icons.card_membership,
      () => const MembershipPackagesScreen(),
    ),
  ]),
  _NavSection('SADRŽAJ', [
    _NavItem(
      'Kategorije treninga',
      'Referentni podaci — kategorije treninga',
      Icons.category_outlined,
      Icons.category,
      () => const TrainingCategoriesScreen(),
      label: 'Kategorije',
    ),
    _NavItem(
      'Nivoi težine',
      'Referentni podaci — nivoi težine',
      Icons.speed_outlined,
      Icons.speed,
      () => const DifficultyLevelsScreen(),
    ),
    _NavItem(
      'Sale',
      'Referentni podaci — sale',
      Icons.meeting_room_outlined,
      Icons.meeting_room,
      () => const HallsScreen(),
    ),
    _NavItem(
      'Oprema',
      'Referentni podaci — oprema za treninge',
      Icons.sports_gymnastics_outlined,
      Icons.sports_gymnastics,
      () => const EquipmentScreen(),
    ),
    _NavItem(
      'Oprema treninga',
      'Upravljanje opremom dodijeljenom treninzima',
      Icons.construction_outlined,
      Icons.construction,
      () => const TrainingEquipmentScreen(),
    ),
    _NavItem(
      'Specijalizacije',
      'Referentni podaci — specijalizacije trenera',
      Icons.workspace_premium_outlined,
      Icons.workspace_premium,
      () => const SpecializationsScreen(),
    ),
    _NavItem(
      'Novosti',
      'Upravljanje novostima',
      Icons.campaign_outlined,
      Icons.campaign,
      () => const NewsItemsScreen(),
    ),
    _NavItem(
      'Historija obavijesti',
      'Pregled sistemskih obavijesti korisnika',
      Icons.notifications_outlined,
      Icons.notifications,
      () => const SystemNotificationsScreen(),
    ),
  ]),
  _NavSection('IZVJEŠTAJI', [
    _NavItem(
      'Izvještaji',
      'Generisanje PDF izvještaja',
      Icons.assessment_outlined,
      Icons.assessment,
      () => const ReportsScreen(),
    ),
  ]),
];

Widget dashboardScreen() => _sections.first.items.first.builder();

class MasterScreen extends StatelessWidget {
  const MasterScreen({super.key, required this.title, this.subtitle, required this.child});

  final String title;
  final String? subtitle;
  final Widget child;

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Odjava'),
        content: const Text('Da li ste sigurni da se želite odjaviti?'),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Otkaži'),
          ),
          const SizedBox(width: 12),
          FilledButton(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Odjavi se'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    await context.read<AuthProvider>().logout();

    if (!context.mounted) return;
    Navigator.of(
      context,
    ).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
  }

  void _openItem(BuildContext context, _NavItem item) {
    if (item.title == title) return;

    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => item.builder()));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSidebar(context),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTopBar(context),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      width: double.infinity,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: child,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: 232,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(right: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.fitness_center, size: 22, color: colorScheme.onPrimaryContainer),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FitBook',
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Admin Panel',
                      style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              children: [
                for (final section in _sections) ...[
                  if (section.header != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 18, 12, 6),
                      child: Text(
                        section.header!,
                        style: textTheme.labelSmall?.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.1,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  for (final item in section.items)
                    _SidebarTile(
                      icon: item.title == title ? item.selectedIcon : item.icon,
                      label: item.label,
                      selected: item.title == title,
                      onTap: () => _openItem(context, item),
                    ),
                ],
              ],
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.all(12),
            child: _SidebarTile(
              icon: Icons.logout,
              label: 'Odjava',
              foreground: colorScheme.error,
              onTap: () => _confirmLogout(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final auth = context.watch<AuthProvider>();

    final firstName = auth.currentFirstName ?? '';
    final lastName = auth.currentLastName ?? '';
    final fullName = [firstName, lastName].where((part) => part.isNotEmpty).join(' ');
    final displayName = fullName.isEmpty ? (auth.currentUsername ?? '') : fullName;
    final role = auth.currentRole ?? '';
    final initials = '${firstName.isEmpty ? '' : firstName[0]}${lastName.isEmpty ? '' : lastName[0]}';

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      subtitle!,
                      style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ),
              ],
            ),
          ),
          if (displayName.isNotEmpty) ...[
            const SizedBox(width: 16),
            CircleAvatar(
              radius: 18,
              backgroundColor: colorScheme.primaryContainer,
              child: Text(
                initials.isEmpty ? displayName[0].toUpperCase() : initials,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(displayName, style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
                if (role.isNotEmpty)
                  Text(
                    role,
                    style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SidebarTile extends StatelessWidget {
  const _SidebarTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
    this.foreground,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = foreground ?? (selected ? colorScheme.primary : colorScheme.onSurfaceVariant);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: selected ? colorScheme.primaryContainer.withValues(alpha: 0.5) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      color: selected || foreground != null ? color : colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
