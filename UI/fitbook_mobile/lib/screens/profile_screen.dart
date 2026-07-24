import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../layouts/master_screen.dart';
import '../models/responses/user_account_response.dart';
import '../providers/auth_provider.dart';
import '../providers/user_account_provider.dart';
import '../theme/app_theme.dart';
import '../utils/api_client_exception.dart';
import '../utils/app_config.dart';
import '../utils/app_roles.dart';
import '../widgets/status_chip.dart';
import 'change_password_screen.dart';
import 'edit_profile_screen.dart';
import 'news_screen.dart';
import 'notifications_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserAccountResponse? _user;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final userId = context.read<AuthProvider>().currentUserId;
    if (userId == null) {
      setState(() {
        _loading = false;
        _error = 'Nije moguće učitati profil. Prijavite se ponovo.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final user = await context.read<UserAccountProvider>().getById(userId);
      if (!mounted) return;
      setState(() {
        _user = user;
        _loading = false;
      });
    } on ApiClientException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  Future<void> _openEditProfile() async {
    final user = _user;
    if (user == null) return;
    final message = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => EditProfileScreen(user: user)),
    );
    if (message == null || !mounted) return;
    await _load();
    if (mounted) _showMessage(message);
  }

  Future<void> _openChangePassword() async {
    final message = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
    );
    if (message == null || !mounted) return;
    _showMessage(message);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _openNotifications() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
  }

  void _openNews() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NewsScreen()),
    );
  }

  Future<void> _confirmLogout() async {
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

    if (shouldLogout != true || !mounted) return;
    await context.read<AuthProvider>().logout();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Profil',
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_user == null) {
      return _ErrorView(
        message: _error ?? 'Nije moguće učitati profil.',
        onRetry: _load,
      );
    }

    final user = _user!;
    final fullName = '${user.firstName} ${user.lastName}'.trim();

    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _ProfileHeader(
            fullName: fullName.isEmpty ? 'Korisnik' : fullName,
            email: user.email,
            username: user.username,
            imageUrl: AppConfig.absoluteFileUrl(user.profileImageUrl),
            initials: _initials(user),
            roleLabel: AppRoles.displayName(user.role),
          ),
          const SizedBox(height: 20),
          _MenuCard(
            children: [
              _MenuTile(
                icon: Icons.person_outline,
                label: 'Uredi profil',
                onTap: _openEditProfile,
              ),
              const _MenuDivider(),
              _MenuTile(
                icon: Icons.lock_outline,
                label: 'Promijeni lozinku',
                onTap: _openChangePassword,
              ),
              const _MenuDivider(),
              _MenuTile(
                icon: Icons.notifications_none,
                label: 'Notifikacije',
                onTap: _openNotifications,
              ),
              const _MenuDivider(),
              _MenuTile(
                icon: Icons.campaign_outlined,
                label: 'Novosti',
                onTap: _openNews,
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
                onTap: _confirmLogout,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _initials(UserAccountResponse user) {
    String pick(String value) => value.trim().isEmpty ? '' : value.trim()[0].toUpperCase();
    final initials = '${pick(user.firstName)}${pick(user.lastName)}';
    if (initials.isNotEmpty) return initials;
    return pick(user.username).isEmpty ? '?' : pick(user.username);
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.fullName,
    required this.email,
    required this.username,
    required this.imageUrl,
    required this.initials,
    required this.roleLabel,
  });

  final String fullName;
  final String email;
  final String username;
  final String? imageUrl;
  final String initials;
  final String roleLabel;

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
          _Avatar(imageUrl: imageUrl, initials: initials),
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
              StatusChip(label: roleLabel, tone: ChipTone.success),
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

class _Avatar extends StatelessWidget {
  const _Avatar({required this.imageUrl, required this.initials});

  final String? imageUrl;
  final String initials;

  static const double _size = 84;

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null) {
      return Container(
        width: _size,
        height: _size,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border, width: 2),
        ),
        child: Image.network(
          imageUrl!,
          width: _size,
          height: _size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _initialsAvatar(),
        ),
      );
    }
    return _initialsAvatar();
  }

  Widget _initialsAvatar() {
    return Container(
      width: _size,
      height: _size,
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
