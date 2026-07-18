import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../layouts/master_screen.dart';
import '../models/common/page_result.dart';
import '../models/enums/membership_status.dart';
import '../models/responses/membership_package_response.dart';
import '../models/responses/user_membership_response.dart';
import '../models/search_objects/membership_package_search_object.dart';
import '../models/search_objects/membership_search_object.dart';
import '../providers/membership_package_provider.dart';
import '../providers/user_membership_provider.dart';
import '../theme/app_theme.dart';
import '../utils/api_client_exception.dart';
import '../utils/formatters.dart';
import '../widgets/crud/data_table_card.dart';
import '../widgets/crud/filter_bar.dart';
import '../widgets/crud/form_dialog.dart';
import '../widgets/crud/table_action_buttons.dart';
import '../widgets/status_chip.dart';

String membershipStatusLabel(MembershipStatus status) => switch (status) {
  MembershipStatus.pending => 'Na čekanju',
  MembershipStatus.active => 'Aktivna',
  MembershipStatus.expired => 'Istekla',
  MembershipStatus.cancelled => 'Otkazana',
};

ChipTone membershipStatusTone(MembershipStatus status) => switch (status) {
  MembershipStatus.pending => ChipTone.warning,
  MembershipStatus.active => ChipTone.success,
  MembershipStatus.expired => ChipTone.neutral,
  MembershipStatus.cancelled => ChipTone.danger,
};

class UserMembershipsScreen extends StatefulWidget {
  const UserMembershipsScreen({super.key});

  @override
  State<UserMembershipsScreen> createState() => _UserMembershipsScreenState();
}

class _UserMembershipsScreenState extends State<UserMembershipsScreen> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  MembershipStatus? _status;
  int? _membershipPackageId;

  int _page = 1;
  int _pageSize = 10;

  PageResult<UserMembershipResponse>? _data;
  List<MembershipPackageResponse> _packages = const [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
    _loadPackages();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await context.read<UserMembershipProvider>().get(
        filter: MembershipSearchObject(
          page: _page,
          pageSize: _pageSize,
          search: _searchController.text.trim(),
          status: _status,
          membershipPackageId: _membershipPackageId,
          includeTotalCount: true,
        ),
      );
      if (!mounted) return;
      setState(() => _data = result);
    } on ApiClientException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadPackages() async {
    try {
      final result = await context.read<MembershipPackageProvider>().get(
        filter: const MembershipPackageSearchObject(pageSize: 100),
      );
      if (!mounted) return;
      setState(() => _packages = result.items);
    } on ApiClientException {
      if (!mounted) return;
    }
  }

  void _onSearchChanged(String _) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 450), () {
      _page = 1;
      _load();
    });
  }

  void _applyFilterChange(VoidCallback change) {
    setState(() {
      change();
      _page = 1;
    });
    _load();
  }

  void _clearFilters() {
    _searchDebounce?.cancel();
    _searchController.clear();
    _applyFilterChange(() {
      _status = null;
      _membershipPackageId = null;
    });
  }

  Future<void> _openDetails(UserMembershipResponse membership) {
    return showDialog<void>(
      context: context,
      builder: (_) => _UserMembershipDetailsDialog(membership: membership),
    );
  }

  Widget _dropdown<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      isExpanded: true,
      style: const TextStyle(fontSize: 13.5, color: AppColors.textPrimary),
      borderRadius: BorderRadius.circular(10),
      onChanged: (v) => onChanged(v as T),
    );
  }

  Widget _userCell(UserMembershipResponse membership) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          membership.userFullName,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
        ),
        Text(
          membership.userEmail,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Članarine',
      subtitle: 'Pregled članarina korisnika',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilterBar(
              fields: [
                FilterField(
                  label: 'Pretraga',
                  width: 260,
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: const InputDecoration(
                      hintText: 'Korisnik, email ili paket...',
                      prefixIcon: Icon(Icons.search, size: 20),
                    ),
                  ),
                ),
                FilterField(
                  label: 'Status',
                  width: 170,
                  child: _dropdown<MembershipStatus?>(
                    value: _status,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Svi statusi')),
                      for (final status in MembershipStatus.values)
                        DropdownMenuItem(
                          value: status,
                          child: Text(membershipStatusLabel(status)),
                        ),
                    ],
                    onChanged: (value) => _applyFilterChange(() => _status = value),
                  ),
                ),
                FilterField(
                  label: 'Paket',
                  width: 200,
                  child: _dropdown<int?>(
                    value: _membershipPackageId,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Svi paketi')),
                      for (final package in _packages)
                        DropdownMenuItem(
                          value: package.id,
                          child: Text(package.name, overflow: TextOverflow.ellipsis),
                        ),
                    ],
                    onChanged: (value) =>
                        _applyFilterChange(() => _membershipPackageId = value),
                  ),
                ),
              ],
              actions: [
                OutlinedButton.icon(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
                  label: const Text('Očisti filtere'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: DataTableCard<UserMembershipResponse>(
                title: 'Lista članarina',
                loading: _loading,
                error: _error,
                items: _data?.items ?? const [],
                page: _page,
                pageSize: _pageSize,
                totalCount: _data?.totalCount,
                totalPages: _data?.totalPages,
                itemsLabel: 'članarina',
                emptyMessage: 'Nema članarina za zadate filtere.',
                onRefresh: _load,
                onPageChanged: (page) {
                  setState(() => _page = page);
                  _load();
                },
                onPageSizeChanged: (size) {
                  setState(() {
                    _pageSize = size;
                    _page = 1;
                  });
                  _load();
                },
                columns: const [
                  ColumnSpec('Korisnik', flex: 3),
                  ColumnSpec('Paket', flex: 2),
                  ColumnSpec('Period', width: 190),
                  ColumnSpec('Status', width: 110),
                  ColumnSpec('Plaćanje', width: 120),
                  ColumnSpec('Akcije', width: 60),
                ],
                cellsBuilder: (context, membership) => [
                  _userCell(membership),
                  Text(
                    membership.packageName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                  Text(
                    '${formatDate(membership.startDateUtc.toLocal())} — ${formatDate(membership.endDateUtc.toLocal())}',
                    style: const TextStyle(fontSize: 12.5),
                  ),
                  StatusChip(
                    label: membershipStatusLabel(membership.status),
                    tone: membershipStatusTone(membership.status),
                  ),
                  StatusChip(
                    label: membership.isPaid ? 'Plaćena' : 'Nije plaćena',
                    tone: membership.isPaid ? ChipTone.success : ChipTone.warning,
                  ),
                  TableActionButtons(
                    onView: () => _openDetails(membership),
                    showDelete: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserMembershipDetailsDialog extends StatelessWidget {
  const _UserMembershipDetailsDialog({required this.membership});

  final UserMembershipResponse membership;

  @override
  Widget build(BuildContext context) {
    return FormDialogShell(
      title: 'Detalji članarine',
      maxWidth: 560,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  membership.userFullName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              StatusChip(
                label: membershipStatusLabel(membership.status),
                tone: membershipStatusTone(membership.status),
              ),
              const SizedBox(width: 8),
              StatusChip(
                label: membership.isPaid ? 'Plaćena' : 'Nije plaćena',
                tone: membership.isPaid ? ChipTone.success : ChipTone.warning,
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),
          DetailRow(
            icon: Icons.email_outlined,
            label: 'Email korisnika',
            value: membership.userEmail,
          ),
          DetailRow(
            icon: Icons.card_membership_outlined,
            label: 'Paket',
            value: membership.packageName,
          ),
          DetailRow(
            icon: Icons.payments_outlined,
            label: 'Cijena paketa',
            value: '${membership.packagePrice.toStringAsFixed(2)} KM',
          ),
          DetailRow(
            icon: Icons.timelapse_outlined,
            label: 'Trajanje paketa',
            value: '${membership.packageDurationDays} dana',
          ),
          DetailRow(
            icon: Icons.play_arrow_outlined,
            label: 'Vrijedi od',
            value: formatDate(membership.startDateUtc.toLocal()),
          ),
          DetailRow(
            icon: Icons.stop_outlined,
            label: 'Vrijedi do',
            value: formatDate(membership.endDateUtc.toLocal()),
          ),
          DetailRow(
            icon: Icons.schedule_outlined,
            label: 'Sljedeća uplata',
            value: membership.nextPaymentDateUtc == null
                ? ''
                : formatDate(membership.nextPaymentDateUtc!.toLocal()),
          ),
          DetailRow(
            icon: Icons.event_outlined,
            label: 'Kreirano',
            value: formatDateTime(membership.createdAtUtc),
          ),
          DetailRow(
            icon: Icons.update_outlined,
            label: 'Ažurirano',
            value: formatDateTime(membership.updatedAtUtc),
          ),
        ],
      ),
    );
  }
}
