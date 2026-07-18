import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../layouts/master_screen.dart';
import '../models/common/page_result.dart';
import '../models/responses/difficulty_level_response.dart';
import '../models/responses/training_category_response.dart';
import '../models/responses/training_response.dart';
import '../models/search_objects/difficulty_level_search_object.dart';
import '../models/search_objects/training_category_search_object.dart';
import '../models/search_objects/training_search_object.dart';
import '../providers/difficulty_level_provider.dart';
import '../providers/training_category_provider.dart';
import '../providers/training_provider.dart';
import '../theme/app_theme.dart';
import '../utils/api_client_exception.dart';
import '../utils/formatters.dart';
import '../widgets/crud/add_record_button.dart';
import '../widgets/crud/confirm_dialog.dart';
import '../widgets/crud/data_table_card.dart';
import '../widgets/crud/filter_bar.dart';
import '../widgets/crud/form_dialog.dart';
import '../widgets/crud/table_action_buttons.dart';
import '../widgets/status_chip.dart';
import 'trainings_details_screen.dart';

class TrainingsScreen extends StatefulWidget {
  const TrainingsScreen({super.key});

  @override
  State<TrainingsScreen> createState() => _TrainingsScreenState();
}

class _TrainingsScreenState extends State<TrainingsScreen> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  int? _trainingCategoryId;
  int? _difficultyLevelId;
  bool? _isActive;

  int _page = 1;
  int _pageSize = 10;

  PageResult<TrainingResponse>? _data;
  List<TrainingCategoryResponse> _categories = const [];
  List<DifficultyLevelResponse> _levels = const [];
  bool _lookupsLoaded = false;
  bool _lookupsFailed = false;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
    _loadLookups();
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
      final result = await context.read<TrainingProvider>().get(
        filter: TrainingSearchObject(
          page: _page,
          pageSize: _pageSize,
          search: _searchController.text.trim(),
          trainingCategoryId: _trainingCategoryId,
          difficultyLevelId: _difficultyLevelId,
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

  Future<void> _loadLookups() async {
    try {
      final categories = await context.read<TrainingCategoryProvider>().get(
        filter: const TrainingCategorySearchObject(pageSize: 100),
      );
      if (!mounted) return;
      final levels = await context.read<DifficultyLevelProvider>().get(
        filter: const DifficultyLevelSearchObject(pageSize: 100),
      );
      if (!mounted) return;
      setState(() {
        _categories = categories.items;
        _levels = levels.items;
        _lookupsLoaded = true;
      });
    } on ApiClientException {
      if (!mounted) return;
      setState(() => _lookupsFailed = true);
    }
  }

  String? get _addDisabledReason {
    if (_lookupsFailed) return null;
    if (!_lookupsLoaded) return 'Provjera preduslova je u toku...';
    if (_categories.isEmpty) {
      return 'Dodavanje nije moguće: prvo dodajte barem jednu kategoriju treninga.';
    }
    if (_levels.isEmpty) {
      return 'Dodavanje nije moguće: prvo dodajte barem jedan nivo težine.';
    }
    return null;
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
      _trainingCategoryId = null;
      _difficultyLevelId = null;
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

  Future<void> _openForm({TrainingResponse? training}) async {
    final message = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => TrainingsDetailsScreen(training: training),
    );
    if (message == null || !mounted) return;
    _showSuccess(message);
    if (training == null) {
      setState(() => _page = 1);
    }
    await _load();
  }

  Future<void> _openDetails(TrainingResponse training) {
    return showDialog<void>(
      context: context,
      builder: (_) => _TrainingDetailsDialog(training: training),
    );
  }

  Future<void> _delete(TrainingResponse training) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Brisanje treninga',
      message:
          'Da li ste sigurni da želite obrisati trening "${training.name}"?',
    );
    if (!confirmed || !mounted) return;

    try {
      await context.read<TrainingProvider>().remove(training.id);
      if (!mounted) return;
      _showSuccess('Trening "${training.name}" je uspješno obrisan.');
      if (_data != null && _data!.items.length == 1 && _page > 1) _page -= 1;
      await _load();
    } on ApiClientException catch (e) {
      if (!mounted) return;
      _showError(e.message);
    }
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

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Treninzi',
      subtitle: 'Upravljanje treninzima',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilterBar(
              fields: [
                FilterField(
                  label: 'Pretraga',
                  width: 240,
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: const InputDecoration(
                      hintText: 'Naziv treninga...',
                      prefixIcon: Icon(Icons.search, size: 20),
                    ),
                  ),
                ),
                FilterField(
                  label: 'Kategorija',
                  width: 180,
                  child: _dropdown<int?>(
                    value: _trainingCategoryId,
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Sve kategorije'),
                      ),
                      for (final category in _categories)
                        DropdownMenuItem(
                          value: category.id,
                          child: Text(
                            category.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: (value) =>
                        _applyFilterChange(() => _trainingCategoryId = value),
                  ),
                ),
                FilterField(
                  label: 'Nivo težine',
                  width: 170,
                  child: _dropdown<int?>(
                    value: _difficultyLevelId,
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Svi nivoi'),
                      ),
                      for (final level in _levels)
                        DropdownMenuItem(
                          value: level.id,
                          child: Text(
                            level.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: (value) =>
                        _applyFilterChange(() => _difficultyLevelId = value),
                  ),
                ),
                FilterField(
                  label: 'Status',
                  width: 150,
                  child: _dropdown<bool?>(
                    value: _isActive,
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
                AddRecordButton(
                  label: 'Dodaj trening',
                  onPressed: () => _openForm(),
                  disabledReason: _addDisabledReason,
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
              child: DataTableCard<TrainingResponse>(
                title: 'Lista treninga',
                loading: _loading,
                error: _error,
                items: _data?.items ?? const [],
                page: _page,
                pageSize: _pageSize,
                totalCount: _data?.totalCount,
                totalPages: _data?.totalPages,
                itemsLabel: 'treninga',
                emptyMessage: 'Nema treninga za zadate filtere.',
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
                  ColumnSpec('Trening', flex: 3),
                  ColumnSpec('Kategorija', flex: 2),
                  ColumnSpec('Nivo težine', width: 130),
                  ColumnSpec('Trajanje', width: 90),
                  ColumnSpec('Učesnici', width: 90),
                  ColumnSpec('Status', width: 110),
                  ColumnSpec('Akcije', width: 116),
                ],
                cellsBuilder: (context, training) => [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        training.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        training.description,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    training.trainingCategoryName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                  StatusChip(
                    label: training.difficultyLevelName,
                    tone: ChipTone.info,
                  ),
                  Text(
                    '${training.durationMinutes} min',
                    style: const TextStyle(fontSize: 13),
                  ),
                  Text(
                    '${training.maxParticipants}',
                    style: const TextStyle(fontSize: 13),
                  ),
                  StatusChip(
                    label: training.isActive ? 'Aktivan' : 'Neaktivan',
                    tone: training.isActive
                        ? ChipTone.success
                        : ChipTone.warning,
                  ),
                  TableActionButtons(
                    onView: () => _openDetails(training),
                    onEdit: () => _openForm(training: training),
                    onDelete: () => _delete(training),
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

class _TrainingDetailsDialog extends StatelessWidget {
  const _TrainingDetailsDialog({required this.training});

  final TrainingResponse training;

  @override
  Widget build(BuildContext context) {
    return FormDialogShell(
      title: 'Detalji treninga',
      maxWidth: 560,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  training.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              StatusChip(
                label: training.difficultyLevelName,
                tone: ChipTone.info,
              ),
              const SizedBox(width: 8),
              StatusChip(
                label: training.isActive ? 'Aktivan' : 'Neaktivan',
                tone: training.isActive ? ChipTone.success : ChipTone.warning,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            training.description,
            style: const TextStyle(fontSize: 13.5, height: 1.5),
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),
          DetailRow(
            icon: Icons.category_outlined,
            label: 'Kategorija',
            value: training.trainingCategoryName,
          ),
          DetailRow(
            icon: Icons.speed_outlined,
            label: 'Nivo težine',
            value: training.difficultyLevelName,
          ),
          DetailRow(
            icon: Icons.timer_outlined,
            label: 'Trajanje',
            value: '${training.durationMinutes} minuta',
          ),
          DetailRow(
            icon: Icons.people_outline,
            label: 'Max učesnika',
            value: '${training.maxParticipants}',
          ),
          DetailRow(
            icon: Icons.event_outlined,
            label: 'Kreirano',
            value: formatDateTime(training.createdAtUtc),
          ),
          DetailRow(
            icon: Icons.update_outlined,
            label: 'Ažurirano',
            value: formatDateTime(training.updatedAtUtc),
          ),
        ],
      ),
    );
  }
}
