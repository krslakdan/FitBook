import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../layouts/master_screen.dart';
import '../models/common/page_result.dart';
import '../models/responses/difficulty_level_response.dart';
import '../models/search_objects/difficulty_level_search_object.dart';
import '../providers/difficulty_level_provider.dart';
import '../theme/app_theme.dart';
import '../utils/api_client_exception.dart';
import '../utils/formatters.dart';
import '../widgets/crud/confirm_dialog.dart';
import '../widgets/crud/data_table_card.dart';
import '../widgets/crud/filter_bar.dart';
import '../widgets/crud/form_dialog.dart';
import '../widgets/crud/table_action_buttons.dart';
import '../widgets/status_chip.dart';
import 'difficulty_levels_details_screen.dart';

class DifficultyLevelsScreen extends StatefulWidget {
  const DifficultyLevelsScreen({super.key});

  @override
  State<DifficultyLevelsScreen> createState() => _DifficultyLevelsScreenState();
}

class _DifficultyLevelsScreenState extends State<DifficultyLevelsScreen> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  bool? _isActive;

  int _page = 1;
  int _pageSize = 10;

  PageResult<DifficultyLevelResponse>? _data;
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
      final result = await context.read<DifficultyLevelProvider>().get(
        filter: DifficultyLevelSearchObject(
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

  Future<void> _openForm({DifficultyLevelResponse? level}) async {
    final message = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => DifficultyLevelsDetailsScreen(level: level),
    );
    if (message == null || !mounted) return;
    _showSuccess(message);
    if (level == null) {
      setState(() => _page = 1);
    }
    await _load();
  }

  Future<void> _openDetails(DifficultyLevelResponse level) {
    return showDialog<void>(
      context: context,
      builder: (_) => _DifficultyLevelDetailsDialog(level: level),
    );
  }

  Future<void> _delete(DifficultyLevelResponse level) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Brisanje nivoa težine',
      message:
          'Da li ste sigurni da želite obrisati nivo težine "${level.name}"?',
    );
    if (!confirmed || !mounted) return;

    try {
      await context.read<DifficultyLevelProvider>().remove(level.id);
      if (!mounted) return;
      _showSuccess('Nivo težine "${level.name}" je uspješno obrisan.');
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
      title: 'Nivoi težine',
      subtitle: 'Referentni podaci — nivoi težine',
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
                      hintText: 'Naziv nivoa težine...',
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
                  label: const Text('Dodaj nivo težine'),
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
              child: DataTableCard<DifficultyLevelResponse>(
                title: 'Lista nivoa težine',
                loading: _loading,
                error: _error,
                items: _data?.items ?? const [],
                page: _page,
                pageSize: _pageSize,
                totalCount: _data?.totalCount,
                totalPages: _data?.totalPages,
                itemsLabel: 'nivoa težine',
                emptyMessage: 'Nema nivoa težine za zadate filtere.',
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
                  ColumnSpec('Redoslijed', width: 110),
                  ColumnSpec('Status', width: 110),
                  ColumnSpec('Kreirano', width: 130),
                  ColumnSpec('Ažurirano', width: 130),
                  ColumnSpec('Akcije', width: 116),
                ],
                cellsBuilder: (context, level) => [
                  Text(
                    level.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${level.sortOrder}',
                    style: const TextStyle(fontSize: 13),
                  ),
                  StatusChip(
                    label: level.isActive ? 'Aktivan' : 'Neaktivan',
                    tone: level.isActive ? ChipTone.success : ChipTone.warning,
                  ),
                  Text(
                    formatDateTime(level.createdAtUtc),
                    style: const TextStyle(fontSize: 12.5),
                  ),
                  Text(
                    formatDateTime(level.updatedAtUtc),
                    style: const TextStyle(fontSize: 12.5),
                  ),
                  TableActionButtons(
                    onView: () => _openDetails(level),
                    onEdit: () => _openForm(level: level),
                    onDelete: () => _delete(level),
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

class _DifficultyLevelDetailsDialog extends StatelessWidget {
  const _DifficultyLevelDetailsDialog({required this.level});

  final DifficultyLevelResponse level;

  @override
  Widget build(BuildContext context) {
    return FormDialogShell(
      title: 'Detalji nivoa težine',
      maxWidth: 520,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  level.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              StatusChip(
                label: level.isActive ? 'Aktivan' : 'Neaktivan',
                tone: level.isActive ? ChipTone.success : ChipTone.warning,
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),
          DetailRow(
            icon: Icons.low_priority_outlined,
            label: 'Redoslijed',
            value: '${level.sortOrder}',
          ),
          DetailRow(
            icon: Icons.event_outlined,
            label: 'Kreirano',
            value: formatDateTime(level.createdAtUtc),
          ),
          DetailRow(
            icon: Icons.update_outlined,
            label: 'Ažurirano',
            value: formatDateTime(level.updatedAtUtc),
          ),
        ],
      ),
    );
  }
}
