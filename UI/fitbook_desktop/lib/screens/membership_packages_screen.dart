import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../layouts/master_screen.dart';
import '../models/common/page_result.dart';
import '../models/responses/membership_package_response.dart';
import '../models/search_objects/membership_package_search_object.dart';
import '../providers/membership_package_provider.dart';
import '../theme/app_theme.dart';
import '../utils/api_client_exception.dart';
import '../utils/formatters.dart';
import '../widgets/crud/confirm_dialog.dart';
import '../widgets/crud/data_table_card.dart';
import '../widgets/crud/filter_bar.dart';
import '../widgets/crud/form_dialog.dart';
import '../widgets/crud/table_action_buttons.dart';
import '../widgets/status_chip.dart';
import 'membership_packages_details_screen.dart';

class MembershipPackagesScreen extends StatefulWidget {
  const MembershipPackagesScreen({super.key});

  @override
  State<MembershipPackagesScreen> createState() =>
      _MembershipPackagesScreenState();
}

class _MembershipPackagesScreenState extends State<MembershipPackagesScreen> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  bool? _isActive;

  int _page = 1;
  int _pageSize = 10;

  PageResult<MembershipPackageResponse>? _data;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
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
      final result = await context.read<MembershipPackageProvider>().get(
        filter: MembershipPackageSearchObject(
          page: _page,
          pageSize: _pageSize,
          search: _searchController.text.trim(),
          isActive: _isActive,
          includeInactive: true,
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
      _isActive = null;
    });
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: AppColors.primaryDark, content: Text(message)),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: AppColors.danger, content: Text(message)),
    );
  }

  Future<void> _openForm({MembershipPackageResponse? package}) async {
    final message = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => MembershipPackagesDetailsScreen(package: package),
    );
    if (message == null || !mounted) return;
    _showSuccess(message);
    if (package == null) {
      setState(() => _page = 1);
    }
    await _load();
  }

  Future<void> _openDetails(MembershipPackageResponse package) {
    return showDialog<void>(
      context: context,
      builder: (_) => _MembershipPackageDetailsDialog(package: package),
    );
  }

  Future<void> _delete(MembershipPackageResponse package) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Brisanje paketa članarine',
      message:
          'Da li ste sigurni da želite obrisati paket članarine "${package.name}"?',
    );
    if (!confirmed || !mounted) return;

    try {
      await context.read<MembershipPackageProvider>().remove(package.id);
      if (!mounted) return;
      _showSuccess('Paket članarine "${package.name}" je uspješno obrisan.');
      if (_data != null && _data!.items.length == 1 && _page > 1) _page -= 1;
      await _load();
    } on ApiClientException catch (e) {
      if (!mounted) return;
      _showError(e.message);
    }
  }

  String _price(double value) => '${value.toStringAsFixed(2)} KM';

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Paketi članarina',
      subtitle: 'Upravljanje paketima članarina',
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
                      hintText: 'Naziv paketa...',
                      prefixIcon: Icon(Icons.search, size: 20),
                    ),
                  ),
                ),
                FilterField(
                  label: 'Status',
                  width: 150,
                  child: DropdownButtonFormField<bool?>(
                    initialValue: _isActive,
                    isExpanded: true,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: AppColors.textPrimary,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Svi statusi')),
                      DropdownMenuItem(value: true, child: Text('Aktivan')),
                      DropdownMenuItem(value: false, child: Text('Neaktivan')),
                    ],
                    onChanged: (value) =>
                        _applyFilterChange(() => _isActive = value),
                  ),
                ),
              ],
              actions: [
                FilledButton.icon(
                  onPressed: () => _openForm(),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Dodaj paket'),
                ),
                OutlinedButton.icon(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
                  label: const Text('Očisti filtere'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: DataTableCard<MembershipPackageResponse>(
                title: 'Lista paketa članarina',
                loading: _loading,
                error: _error,
                items: _data?.items ?? const [],
                page: _page,
                pageSize: _pageSize,
                totalCount: _data?.totalCount,
                totalPages: _data?.totalPages,
                itemsLabel: 'paketa',
                emptyMessage: 'Nema paketa članarina za zadate filtere.',
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
                  ColumnSpec('Naziv', flex: 3),
                  ColumnSpec('Trajanje', width: 110),
                  ColumnSpec('Cijena', width: 110),
                  ColumnSpec('Ušteda', width: 110),
                  ColumnSpec('Status', width: 110),
                  ColumnSpec('Kreirano', width: 130),
                  ColumnSpec('Akcije', width: 116),
                ],
                cellsBuilder: (context, package) => [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        package.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        package.includedBenefits,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${package.durationDays} dana',
                    style: const TextStyle(fontSize: 13),
                  ),
                  Text(
                    _price(package.price),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    package.savingsAmount == null
                        ? '—'
                        : _price(package.savingsAmount!),
                    style: const TextStyle(fontSize: 13),
                  ),
                  StatusChip(
                    label: package.isActive ? 'Aktivan' : 'Neaktivan',
                    tone: package.isActive
                        ? ChipTone.success
                        : ChipTone.warning,
                  ),
                  Text(
                    formatDateTime(package.createdAtUtc),
                    style: const TextStyle(fontSize: 12.5),
                  ),
                  TableActionButtons(
                    onView: () => _openDetails(package),
                    onEdit: () => _openForm(package: package),
                    onDelete: () => _delete(package),
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

class _MembershipPackageDetailsDialog extends StatelessWidget {
  const _MembershipPackageDetailsDialog({required this.package});

  final MembershipPackageResponse package;

  @override
  Widget build(BuildContext context) {
    return FormDialogShell(
      title: 'Detalji paketa članarine',
      maxWidth: 560,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  package.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              StatusChip(
                label: package.isActive ? 'Aktivan' : 'Neaktivan',
                tone: package.isActive ? ChipTone.success : ChipTone.warning,
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),
          DetailRow(
            icon: Icons.timelapse_outlined,
            label: 'Trajanje',
            value: '${package.durationDays} dana',
          ),
          DetailRow(
            icon: Icons.payments_outlined,
            label: 'Cijena',
            value: '${package.price.toStringAsFixed(2)} KM',
          ),
          DetailRow(
            icon: Icons.savings_outlined,
            label: 'Ušteda',
            value: package.savingsAmount == null
                ? ''
                : '${package.savingsAmount!.toStringAsFixed(2)} KM',
          ),
          DetailRow(
            icon: Icons.checklist_outlined,
            label: 'Pogodnosti',
            value: package.includedBenefits,
          ),
          DetailRow(
            icon: Icons.event_outlined,
            label: 'Kreirano',
            value: formatDateTime(package.createdAtUtc),
          ),
          DetailRow(
            icon: Icons.update_outlined,
            label: 'Ažurirano',
            value: formatDateTime(package.updatedAtUtc),
          ),
        ],
      ),
    );
  }
}
