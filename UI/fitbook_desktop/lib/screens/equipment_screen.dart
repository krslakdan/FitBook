import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../layouts/master_screen.dart';
import '../models/common/page_result.dart';
import '../models/responses/equipment_response.dart';
import '../models/search_objects/equipment_search_object.dart';
import '../providers/equipment_provider.dart';
import '../theme/app_theme.dart';
import '../utils/api_client_exception.dart';
import '../utils/formatters.dart';
import '../widgets/crud/confirm_dialog.dart';
import '../widgets/crud/data_table_card.dart';
import '../widgets/crud/filter_bar.dart';
import '../widgets/crud/form_dialog.dart';
import '../widgets/crud/table_action_buttons.dart';
import '../widgets/status_chip.dart';
import 'equipment_details_screen.dart';

class EquipmentScreen extends StatefulWidget {
  const EquipmentScreen({super.key});

  @override
  State<EquipmentScreen> createState() => _EquipmentScreenState();
}

class _EquipmentScreenState extends State<EquipmentScreen> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  bool? _isActive;

  int _page = 1;
  int _pageSize = 10;

  PageResult<EquipmentResponse>? _data;
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
      final result = await context.read<EquipmentProvider>().get(
        filter: EquipmentSearchObject(
          page: _page,
          pageSize: _pageSize,
          search: _searchController.text.trim(),
          isActive: _isActive,
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

  Future<void> _openForm({EquipmentResponse? equipment}) async {
    final message = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => EquipmentDetailsScreen(equipment: equipment),
    );
    if (message == null || !mounted) return;
    _showSuccess(message);
    if (equipment == null) {
      setState(() => _page = 1);
    }
    await _load();
  }

  Future<void> _openDetails(EquipmentResponse equipment) {
    return showDialog<void>(
      context: context,
      builder: (_) => _EquipmentDetailsDialog(equipment: equipment),
    );
  }

  Future<void> _delete(EquipmentResponse equipment) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Brisanje opreme',
      message:
          'Da li ste sigurni da želite obrisati opremu "${equipment.name}"?',
    );
    if (!confirmed || !mounted) return;

    try {
      await context.read<EquipmentProvider>().remove(equipment.id);
      if (!mounted) return;
      _showSuccess('Oprema "${equipment.name}" je uspješno obrisana.');
      if (_data != null && _data!.items.length == 1 && _page > 1) _page -= 1;
      await _load();
    } on ApiClientException catch (e) {
      if (!mounted) return;
      _showError(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Oprema',
      subtitle: 'Referentni podaci — oprema za treninge',
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
                      hintText: 'Naziv opreme...',
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
                      DropdownMenuItem(value: true, child: Text('Aktivna')),
                      DropdownMenuItem(value: false, child: Text('Neaktivna')),
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
                  label: const Text('Dodaj opremu'),
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
              child: DataTableCard<EquipmentResponse>(
                title: 'Lista opreme',
                loading: _loading,
                error: _error,
                items: _data?.items ?? const [],
                page: _page,
                pageSize: _pageSize,
                totalCount: _data?.totalCount,
                totalPages: _data?.totalPages,
                itemsLabel: 'opreme',
                emptyMessage: 'Nema opreme za zadate filtere.',
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
                  ColumnSpec('Status', width: 110),
                  ColumnSpec('Kreirano', width: 130),
                  ColumnSpec('Ažurirano', width: 130),
                  ColumnSpec('Akcije', width: 116),
                ],
                cellsBuilder: (context, equipment) => [
                  Text(
                    equipment.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  StatusChip(
                    label: equipment.isActive ? 'Aktivna' : 'Neaktivna',
                    tone: equipment.isActive
                        ? ChipTone.success
                        : ChipTone.warning,
                  ),
                  Text(
                    formatDateTime(equipment.createdAtUtc),
                    style: const TextStyle(fontSize: 12.5),
                  ),
                  Text(
                    formatDateTime(equipment.updatedAtUtc),
                    style: const TextStyle(fontSize: 12.5),
                  ),
                  TableActionButtons(
                    onView: () => _openDetails(equipment),
                    onEdit: () => _openForm(equipment: equipment),
                    onDelete: () => _delete(equipment),
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

class _EquipmentDetailsDialog extends StatelessWidget {
  const _EquipmentDetailsDialog({required this.equipment});

  final EquipmentResponse equipment;

  @override
  Widget build(BuildContext context) {
    return FormDialogShell(
      title: 'Detalji opreme',
      maxWidth: 520,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  equipment.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              StatusChip(
                label: equipment.isActive ? 'Aktivna' : 'Neaktivna',
                tone: equipment.isActive ? ChipTone.success : ChipTone.warning,
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),
          DetailRow(
            icon: Icons.event_outlined,
            label: 'Kreirano',
            value: formatDateTime(equipment.createdAtUtc),
          ),
          DetailRow(
            icon: Icons.update_outlined,
            label: 'Ažurirano',
            value: formatDateTime(equipment.updatedAtUtc),
          ),
        ],
      ),
    );
  }
}
