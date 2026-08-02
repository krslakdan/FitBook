import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../layouts/master_screen.dart';
import '../models/enums/membership_status.dart';
import '../models/responses/user_membership_response.dart';
import '../models/search_objects/membership_search_object.dart';
import '../providers/auth_provider.dart';
import '../providers/user_membership_provider.dart';
import '../theme/app_theme.dart';
import '../utils/api_client_exception.dart';
import '../utils/formatters.dart';
import '../utils/membership_display.dart';
import '../widgets/status_chip.dart';
import 'membership_details_screen.dart';

class MembershipHistoryScreen extends StatefulWidget {
  const MembershipHistoryScreen({super.key});

  @override
  State<MembershipHistoryScreen> createState() => _MembershipHistoryScreenState();
}

class _MembershipHistoryScreenState extends State<MembershipHistoryScreen> {
  final List<UserMembershipResponse> _all = [];

  MembershipStatus? _filter;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  List<UserMembershipResponse> get _visible {
    final items = _filter == null
        ? [..._all]
        : _all.where((m) => m.status == _filter).toList();
    items.sort((a, b) => b.createdAtUtc.compareTo(a.createdAtUtc));
    return items;
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final provider = context.read<UserMembershipProvider>();
    final userId = context.read<AuthProvider>().currentUserId;
    try {
      final result = await provider.get(
        filter: MembershipSearchObject(
          page: 1,
          pageSize: 100,
          userAccountId: userId,
          includeTotalCount: true,
        ),
      );
      if (!mounted) return;
      setState(() {
        _all
          ..clear()
          ..addAll(result.items);
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

  void _openDetails(UserMembershipResponse membership) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => MembershipDetailsScreen(membership: membership)))
        .then((_) {
      if (mounted) _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Historija članarina',
      subtitle: 'Sve Vaše članarine',
      showBackButton: true,
      child: Column(
        children: [
          if (_all.isNotEmpty) _buildFilterBar(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    const filters = <(String, MembershipStatus?)>[
      ('Sve', null),
      ('Aktivne', MembershipStatus.active),
      ('Na čekanju', MembershipStatus.pending),
      ('Istekle', MembershipStatus.expired),
      ('Otkazane', MembershipStatus.cancelled),
    ];

    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          for (final (label, status) in filters)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(label),
                selected: _filter == status,
                onSelected: (_) => setState(() => _filter = status),
                showCheckmark: false,
                labelStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _filter == status ? Colors.white : AppColors.textSecondary,
                ),
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.surface,
                side: BorderSide(color: _filter == status ? AppColors.primary : AppColors.border),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading && _all.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _all.isEmpty) {
      return _ErrorView(message: _error!, onRetry: _load);
    }

    final items = _visible;

    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.primary,
      child: items.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [SizedBox(height: 100), _EmptyView()],
            )
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _HistoryCard(
                membership: items[index],
                onTap: () => _openDetails(items[index]),
              ),
            ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.membership, required this.onTap});

  final UserMembershipResponse membership;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (statusLabel, statusTone) = membershipStatusDisplay(membership.status);
    final (tileBackground, tileForeground) = membershipStatusColors(membership.status);
    final isPending = membership.status == MembershipStatus.pending;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: tileBackground,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(membershipStatusIcon(membership.status), size: 24, color: tileForeground),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            membership.packageName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusChip(label: statusLabel, tone: statusTone),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _MetaLine(
                      icon: Icons.date_range_outlined,
                      text: isPending
                          ? 'Kreirano ${formatDate(membership.createdAtUtc.toLocal())}'
                          : '${formatDate(membership.startDateUtc.toLocal())} – ${formatDate(membership.endDateUtc.toLocal())}',
                    ),
                    const SizedBox(height: 5),
                    _MetaLine(
                      icon: Icons.payments_outlined,
                      text: formatMoney(membership.packagePrice),
                      strong: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, size: 20, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.icon, required this.text, this.strong = false});

  final IconData icon;
  final String text;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: strong
                ? const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  )
                : const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
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
              child: const Icon(Icons.workspace_premium_outlined, size: 44, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            const Text(
              'Nema članarina',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ovdje se prikazuju sve Vaše aktivne i prethodne članarine.',
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
