import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../screens/login_screen.dart';
import '../screens/placeholder_screen.dart';

typedef _ScreenBuilder = Widget Function();

class _NavItem {
  const _NavItem(this.label, this.icon, this.builder);

  final String label;
  final IconData icon;
  final _ScreenBuilder builder;
}

Widget _placeholder(String label) =>
    placeholderScreen(label, 'Ekran "$label" biće implementiran u sljedećoj fazi.');

final List<_NavItem> _navItems = [
  _NavItem('Dashboard', Icons.dashboard, () => _placeholder('Dashboard')),
  _NavItem('Korisnici', Icons.people, () => _placeholder('Korisnici')),
  _NavItem('Treneri', Icons.badge, () => _placeholder('Treneri')),
  _NavItem('Treninzi', Icons.fitness_center, () => _placeholder('Treninzi')),
  _NavItem('Termini', Icons.calendar_month, () => _placeholder('Termini')),
  _NavItem('Rezervacije', Icons.book_online, () => _placeholder('Rezervacije')),
  _NavItem('Članarine', Icons.card_membership, () => _placeholder('Članarine')),
  _NavItem('Kategorije treninga', Icons.category, () => _placeholder('Kategorije treninga')),
  _NavItem('Nivoi težine', Icons.trending_up, () => _placeholder('Nivoi težine')),
  _NavItem('Sale', Icons.meeting_room, () => _placeholder('Sale')),
  _NavItem('Obavijesti', Icons.campaign, () => _placeholder('Obavijesti')),
  _NavItem('Izvještaji', Icons.summarize, () => _placeholder('Izvještaji')),
];

class MasterScreen extends StatelessWidget {
  const MasterScreen({super.key, required this.title, required this.child});

  final String title;
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

  void _onDestinationSelected(BuildContext context, int index) {
    final item = _navItems[index];
    if (item.label == title) return;

    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => item.builder()));
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _navItems.indexWhere((item) => item.label == title);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NavigationRail(
            selectedIndex: selectedIndex == -1 ? null : selectedIndex,
            onDestinationSelected: (index) => _onDestinationSelected(context, index),
            labelType: NavigationRailLabelType.selected,
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: IconButton(
                    tooltip: 'Odjava',
                    icon: const Icon(Icons.logout),
                    onPressed: () => _confirmLogout(context),
                  ),
                ),
              ),
            ),
            destinations: [
              for (final item in _navItems)
                NavigationRailDestination(icon: Icon(item.icon), label: Text(item.label)),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}
