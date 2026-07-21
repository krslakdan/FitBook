import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../layouts/master_screen.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/status_chip.dart';
import 'notifications_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final firstName = auth.currentFirstName ?? '';
    final lastName = auth.currentLastName ?? '';
    final fullName = '$firstName $lastName'.trim();
    final email = auth.currentEmail ?? '';
    final username = auth.currentUsername ?? '';

    return MasterScreen(
      title: 'Profil',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ProfileHeader(
              fullName: fullName.isEmpty ? 'Korisnik' : fullName,
              email: email,
              username: username,
              initials: _initials(firstName, lastName, username),
            ),
            const SizedBox(height: 20),
            _MenuCard(
              children: [
                _MenuTile(
                  icon: Icons.person_outline,
                  label: 'Uredi profil',
                  onTap: () => _showComingSoon(context),
                ),
                const _MenuDivider(),
                _MenuTile(
                  icon: Icons.lock_outline,
                  label: 'Promijeni lozinku',
                  onTap: () => _showComingSoon(context),
                ),
                const _MenuDivider(),
                _MenuTile(
                  icon: Icons.notifications_none,
                  label: 'Notifikacije',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _MenuCard(
              children: [
                _MenuTile(
                  icon: Icons.logout,
                  label: 'Odjava',
                  danger: true,
                  onTap: () => _confirmLogout(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String firstName, String lastName, String username) {
    String pick(String value) => value.trim().isEmpty ? '' : value.trim()[0].toUpperCase();
    final initials = '${pick(firstName)}${pick(lastName)}';
    if (initials.isNotEmpty) return initials;
    return pick(username).isEmpty ? '?' : pick(username);
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ova funkcionalnost je u pripremi.')),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Odjava'),
        content: const Text('Jeste li sigurni da se želite odjaviti?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Odustani'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Odjavi se'),
          ),
        ],
      ),
    );

    if (shouldLogout != true || !context.mounted) return;
    await context.read<AuthProvider>().logout();
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.fullName,
    required this.email,
    required this.username,
    required this.initials,
  });

  final String fullName;
  final String email;
  final String username;
  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            fullName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          if (email.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              email,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const StatusChip(label: 'Član', tone: ChipTone.success),
              if (username.isNotEmpty) ...[
                const SizedBox(width: 8),
                StatusChip(label: '@$username', tone: ChipTone.neutral),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.danger : AppColors.textPrimary;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            Icon(icon, size: 22, color: danger ? AppColors.danger : AppColors.textSecondary),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: color),
              ),
            ),
            if (!danger)
              const Icon(Icons.chevron_right, size: 22, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _MenuDivider extends StatelessWidget {
  const _MenuDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, indent: 52, color: AppColors.border);
  }
}
