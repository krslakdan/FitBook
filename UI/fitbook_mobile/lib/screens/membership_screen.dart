import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../layouts/master_screen.dart';
import '../models/enums/membership_status.dart';
import '../models/requests/user_membership_insert_request.dart';
import '../models/responses/membership_package_response.dart';
import '../models/responses/user_membership_response.dart';
import '../models/search_objects/membership_package_search_object.dart';
import '../models/search_objects/membership_search_object.dart';
import '../providers/auth_provider.dart';
import '../providers/main_navigation_controller.dart';
import '../providers/membership_package_provider.dart';
import '../providers/user_membership_provider.dart';
import '../theme/app_theme.dart';
import '../utils/api_client_exception.dart';
import '../utils/formatters.dart';
import '../utils/membership_display.dart';
import '../utils/membership_payment_flow.dart';
import '../widgets/status_chip.dart';
import 'membership_details_screen.dart';
import 'membership_history_screen.dart';

class MembershipScreen extends StatefulWidget {
  const MembershipScreen({super.key});

  @override
  State<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends State<MembershipScreen> {
  static const int _navTabIndex = 3;

  final List<UserMembershipResponse> _memberships = [];
  List<MembershipPackageResponse> _packages = const [];

  bool _loading = true;
  bool _busy = false;
  String? _error;
  MainNavigationController? _navigation;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final navigation = context.read<MainNavigationController>();
    if (!identical(navigation, _navigation)) {
      _navigation?.removeListener(_onNavigationChanged);
      _navigation = navigation;
      _navigation!.addListener(_onNavigationChanged);
    }
  }

  void _onNavigationChanged() {
    if (mounted && !_loading && _navigation?.selectedIndex == _navTabIndex) {
      _load();
    }
  }

  @override
  void dispose() {
    _navigation?.removeListener(_onNavigationChanged);
    super.dispose();
  }

  UserMembershipResponse? get _currentMembership {
    final relevant = _memberships.where(isCurrentMembership).toList()
      ..sort((a, b) {
        if (a.status != b.status) {
          return a.status == MembershipStatus.active ? -1 : 1;
        }
        return b.createdAtUtc.compareTo(a.createdAtUtc);
      });
    return relevant.isEmpty ? null : relevant.first;
  }

  int? get _bestValuePackageId {
    MembershipPackageResponse? best;
    for (final package in _packages) {
      final savings = package.savingsAmount ?? 0;
      if (savings <= 0) continue;
      if (best == null || savings > (best.savingsAmount ?? 0)) best = package;
    }
    return best?.id;
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final membershipProvider = context.read<UserMembershipProvider>();
    final packageProvider = context.read<MembershipPackageProvider>();
    final userId = context.read<AuthProvider>().currentUserId;

    try {
      final results = await Future.wait([
        membershipProvider.get(
          filter: MembershipSearchObject(
            page: 1,
            pageSize: 100,
            userAccountId: userId,
            includeTotalCount: true,
          ),
        ),
        packageProvider.get(
          filter: const MembershipPackageSearchObject(page: 1, pageSize: 100, isActive: true),
        ),
      ]);

      if (!mounted) return;

      final memberships = results[0].items.cast<UserMembershipResponse>();
      final packages = results[1].items.cast<MembershipPackageResponse>().toList()
        ..sort((a, b) => a.price.compareTo(b.price));

      setState(() {
        _memberships
          ..clear()
          ..addAll(memberships);
        _packages = packages;
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

  void _openHistory() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const MembershipHistoryScreen()))
        .then((_) {
      if (mounted) _load();
    });
  }

  void _openDetails(UserMembershipResponse membership) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => MembershipDetailsScreen(membership: membership)))
        .then((_) {
      if (mounted) _load();
    });
  }

  Future<void> _buyPackage(MembershipPackageResponse package) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PurchaseSheet(package: package),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    final provider = context.read<UserMembershipProvider>();

    try {
      final membership = await provider.create(
        UserMembershipInsertRequest(membershipPackageId: package.id),
      );
      await _runPayment(provider, membership.id);
    } on ApiClientException catch (e) {
      if (!mounted) return;
      _showMessage(e.message);
      await _load();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _payCurrent(UserMembershipResponse membership) async {
    setState(() => _busy = true);
    final provider = context.read<UserMembershipProvider>();
    try {
      await _runPayment(provider, membership.id);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _runPayment(UserMembershipProvider provider, int membershipId) async {
    final result = await MembershipPaymentFlow.pay(provider: provider, membershipId: membershipId);
    if (!mounted) return;

    final (message, success) = membershipPaymentResultMessage(result);
    _showMessage(message, success: success);

    await _load();
  }

  void _showMessage(String message, {bool success = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: success ? AppColors.primaryDark : null,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Članarina',
      subtitle: 'Vaše članstvo i paketi',
      actions: [
        IconButton(
          onPressed: _loading ? null : _openHistory,
          icon: const Icon(Icons.receipt_long_outlined),
          tooltip: 'Historija članarina',
        ),
      ],
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading && _memberships.isEmpty && _packages.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _packages.isEmpty) {
      return _ErrorView(message: _error!, onRetry: _load);
    }

    final current = _currentMembership;
    final bestValueId = _bestValuePackageId;
    final blockReason = _packageBlockReason(current);

    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.primary,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          if (current != null) ...[
            _CurrentMembershipCard(membership: current, onTap: () => _openDetails(current)),
            if (current.status == MembershipStatus.pending) ...[
              const SizedBox(height: 12),
              _PayButton(busy: _busy, onPay: () => _payCurrent(current)),
            ],
          ] else
            const _NoMembershipCard(),
          const SizedBox(height: 28),
          _SectionHeader(
            title: 'Paketi članarine',
            subtitle: current == null
                ? 'Odaberite paket i platite sigurno karticom.'
                : null,
          ),
          const SizedBox(height: 14),
          for (final package in _packages) ...[
            _PackageCard(
              package: package,
              accent: _accentFor(_packages.indexOf(package)),
              isBestValue: package.id == bestValueId,
              disabledReason: blockReason,
              busy: _busy,
              onSelect: () => _buyPackage(package),
            ),
            const SizedBox(height: 14),
          ],
          if (_packages.isEmpty)
            const _MessageBox(
              icon: Icons.workspace_premium_outlined,
              message: 'Trenutno nema dostupnih paketa članarine.',
            ),
        ],
      ),
    );
  }

  String? _packageBlockReason(UserMembershipResponse? current) {
    if (current == null) return null;
    return current.status == MembershipStatus.active
        ? 'Već imate aktivnu članarinu.'
        : 'Već imate članarinu koja čeka na plaćanje.';
  }

  (Color, Color) _accentFor(int index) {
    const accents = [
      (AppColors.primarySoft, AppColors.onPrimarySoft),
      (AppColors.infoSoft, AppColors.onInfoSoft),
      (AppColors.purpleSoft, AppColors.onPurpleSoft),
    ];
    return accents[index % accents.length];
  }
}

class _CurrentMembershipCard extends StatelessWidget {
  const _CurrentMembershipCard({required this.membership, required this.onTap});

  final UserMembershipResponse membership;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isActive = membership.status == MembershipStatus.active;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: isActive
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primaryDark],
                )
              : null,
          color: isActive ? null : AppColors.surface,
          border: isActive ? null : Border.all(color: AppColors.warningSoft, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: isActive
                  ? AppColors.primary.withValues(alpha: 0.28)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: isActive ? _buildActive(context) : _buildPending(context),
          ),
        ),
      ),
    );
  }

  Widget _buildActive(BuildContext context) {
    final end = membership.endDateUtc.toLocal();
    final start = membership.startDateUtc.toLocal();
    final now = DateTime.now();
    final totalSpan = end.difference(start).inSeconds;
    final used = now.difference(start).inSeconds;
    final progress = totalSpan <= 0 ? 1.0 : (used / totalSpan).clamp(0.0, 1.0);
    final daysLeft = membershipDaysRemaining(membership);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.workspace_premium, size: 24, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Aktivna članarina',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    membership.packageName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white70),
          ],
        ),
        const SizedBox(height: 18),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 7,
            backgroundColor: Colors.white.withValues(alpha: 0.24),
            valueColor: const AlwaysStoppedAnimation(Colors.white),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.event_available_outlined, size: 16, color: Colors.white70),
            const SizedBox(width: 6),
            Text(
              'Vrijedi do ${formatDate(end)}',
              style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                formatDaysRemaining(daysLeft),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPending(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.warningSoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.hourglass_top, size: 24, color: AppColors.onWarningSoft),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Čeka na plaćanje',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                          color: AppColors.onWarningSoft,
                        ),
                      ),
                      const Spacer(),
                      const StatusChip(label: 'Na čekanju', tone: ChipTone.warning),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    membership.packageName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            _InlineMeta(
              icon: Icons.timelapse_outlined,
              text: formatMembershipDuration(membership.packageDurationDays),
            ),
            const SizedBox(width: 16),
            _InlineMeta(
              icon: Icons.payments_outlined,
              text: formatMoney(membership.packagePrice),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ],
    );
  }
}

class _InlineMeta extends StatelessWidget {
  const _InlineMeta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _PayButton extends StatelessWidget {
  const _PayButton({required this.busy, required this.onPay});

  final bool busy;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: busy ? null : onPay,
      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
      icon: busy
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
            )
          : const Icon(Icons.lock_outline, size: 20),
      label: Text(busy ? 'Obrada...' : 'Dovršite plaćanje'),
    );
  }
}

class _NoMembershipCard extends StatelessWidget {
  const _NoMembershipCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.workspace_premium_outlined, size: 32, color: AppColors.onPrimarySoft),
          ),
          const SizedBox(height: 16),
          const Text(
            'Nemate aktivnu članarinu',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          const Text(
            'Odaberite jedan od paketa ispod i otključajte pristup treninzima.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.5, height: 1.4, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 3),
          Text(
            subtitle!,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ],
    );
  }
}

class _PackageCard extends StatelessWidget {
  const _PackageCard({
    required this.package,
    required this.accent,
    required this.isBestValue,
    required this.disabledReason,
    required this.busy,
    required this.onSelect,
  });

  final MembershipPackageResponse package;
  final (Color, Color) accent;
  final bool isBestValue;
  final String? disabledReason;
  final bool busy;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final benefits = _parseBenefits(package.includedBenefits);
    final savings = package.savingsAmount ?? 0;
    final disabled = disabledReason != null;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isBestValue ? AppColors.primary : AppColors.border,
          width: isBestValue ? 1.6 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isBestValue)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              color: AppColors.primary,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star, size: 14, color: Colors.white),
                  SizedBox(width: 6),
                  Text(
                    'NAJBOLJA VRIJEDNOST',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: accent.$1,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.workspace_premium, size: 24, color: accent.$2),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            package.name,
                            style: const TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Trajanje: ${formatMembershipDuration(package.durationDays)}',
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatMoney(package.price),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (savings > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: StatusChip(
                          label: 'Ušteda ${formatMoney(savings)}',
                          tone: ChipTone.success,
                        ),
                      ),
                  ],
                ),
                if (benefits.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 14),
                  for (final benefit in benefits) ...[
                    _BenefitRow(text: benefit),
                    const SizedBox(height: 10),
                  ],
                ],
                const SizedBox(height: 6),
                FilledButton(
                  onPressed: (disabled || busy) ? null : onSelect,
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  child: const Text('Odaberi paket'),
                ),
                if (disabled) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.info_outline, size: 15, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          disabledReason!,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<String> _parseBenefits(String raw) {
    return raw
        .split(',')
        .map((part) => part.trim().replaceAll(RegExp(r'\.$'), '').trim())
        .where((part) => part.isNotEmpty)
        .toList();
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(Icons.check, size: 13, color: AppColors.onPrimarySoft),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13.5, height: 1.35, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}

class _PurchaseSheet extends StatelessWidget {
  const _PurchaseSheet({required this.package});

  final MembershipPackageResponse package;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  'Potvrda kupovine',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  icon: const Icon(Icons.close, size: 22),
                  tooltip: 'Zatvori',
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.pageBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _SummaryRow(label: 'Paket', value: package.name),
                  const SizedBox(height: 10),
                  _SummaryRow(
                    label: 'Trajanje',
                    value: formatMembershipDuration(package.durationDays),
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text(
                        'Ukupno',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        formatMoney(package.price),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lock_outline, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Plaćanje je sigurno i procesirano putem Stripe-a. Podaci o kartici se ne pohranjuju.',
                    style: TextStyle(fontSize: 12.5, height: 1.4, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                    child: const Text('Odustani'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                    icon: const Icon(Icons.credit_card, size: 20),
                    label: Text('Plati ${formatMoney(package.price)}'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13.5, color: AppColors.textSecondary)),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _MessageBox extends StatelessWidget {
  const _MessageBox({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13.5, height: 1.4, color: AppColors.textSecondary),
          ),
        ],
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
