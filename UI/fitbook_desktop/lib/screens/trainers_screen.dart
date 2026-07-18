import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../layouts/master_screen.dart';
import '../models/common/page_result.dart';
import '../models/responses/specialization_response.dart';
import '../models/responses/trainer_response.dart';
import '../models/search_objects/specialization_search_object.dart';
import '../models/search_objects/trainer_search_object.dart';
import '../models/search_objects/user_search_object.dart';
import '../providers/specialization_provider.dart';
import '../providers/trainer_provider.dart';
import '../providers/user_account_provider.dart';
import '../theme/app_theme.dart';
import '../utils/api_client_exception.dart';
import '../utils/app_config.dart';
import '../utils/app_roles.dart';
import '../utils/formatters.dart';
import '../widgets/crud/add_record_button.dart';
import '../widgets/crud/confirm_dialog.dart';
import '../widgets/crud/data_table_card.dart';
import '../widgets/crud/filter_bar.dart';
import '../widgets/crud/form_dialog.dart';
import '../widgets/crud/table_action_buttons.dart';
import '../widgets/status_chip.dart';
import 'trainers_details_screen.dart';

class TrainersScreen extends StatefulWidget {
  const TrainersScreen({super.key});

  @override
  State<TrainersScreen> createState() => _TrainersScreenState();
}

class _TrainersScreenState extends State<TrainersScreen> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  int? _specializationId;
  bool? _isAvailable;
  bool? _isActive;

  int _page = 1;
  int _pageSize = 10;

  PageResult<TrainerResponse>? _data;
  List<SpecializationResponse> _specializations = const [];
  bool _hasTrainerAccounts = false;
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
      final result = await context.read<TrainerProvider>().get(
        filter: TrainerSearchObject(
          page: _page,
          pageSize: _pageSize,
          search: _searchController.text.trim(),
          specializationId: _specializationId,
          isAvailable: _isAvailable,
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
      final specializations = await context.read<SpecializationProvider>().get(
        filter: const SpecializationSearchObject(pageSize: 100),
      );
      if (!mounted) return;
      final trainerAccounts = await context.read<UserAccountProvider>().get(
        filter: const UserSearchObject(
          pageSize: 1,
          role: AppRoles.trainer,
          isActive: true,
        ),
      );
      if (!mounted) return;
      setState(() {
        _specializations = specializations.items;
        _hasTrainerAccounts = trainerAccounts.items.isNotEmpty;
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
    if (_specializations.isEmpty) {
      return 'Dodavanje nije moguće: prvo dodajte barem jednu specijalizaciju.';
    }
    if (!_hasTrainerAccounts) {
      return 'Dodavanje nije moguće: ne postoji nijedan aktivan korisnik sa ulogom "Trener".';
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
      _specializationId = null;
      _isAvailable = null;
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

  Future<void> _openForm({TrainerResponse? trainer}) async {
    final message = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => TrainersDetailsScreen(trainer: trainer),
    );
    if (message == null || !mounted) return;
    _showSuccess(message);
    if (trainer == null) {
      setState(() => _page = 1);
    }
    await _load();
  }

  Future<void> _openDetails(TrainerResponse trainer) {
    return showDialog<void>(
      context: context,
      builder: (_) => _TrainerDetailsDialog(trainer: trainer),
    );
  }

  Future<void> _delete(TrainerResponse trainer) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Brisanje trenera',
      message:
          'Da li ste sigurni da želite obrisati trenera "${trainer.fullName}"?',
    );
    if (!confirmed || !mounted) return;

    try {
      await context.read<TrainerProvider>().remove(trainer.id);
      if (!mounted) return;
      _showSuccess('Trener "${trainer.fullName}" je uspješno obrisan.');
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

  Widget _trainerCell(TrainerResponse trainer) {
    final imageUrl = AppConfig.absoluteFileUrl(trainer.imageUrl);
    final initials =
        '${trainer.firstName.isEmpty ? '' : trainer.firstName[0]}${trainer.lastName.isEmpty ? '' : trainer.lastName[0]}';

    return Row(
      children: [
        CircleAvatar(
          radius: 19,
          backgroundColor: AppColors.primarySoft,
          foregroundImage: imageUrl == null ? null : NetworkImage(imageUrl),
          child: Text(
            initials.toUpperCase(),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.onPrimarySoft,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                trainer.fullName,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                trainer.specializationName,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Treneri',
      subtitle: 'Upravljanje trenerima',
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
                      hintText: 'Ime ili prezime trenera...',
                      prefixIcon: Icon(Icons.search, size: 20),
                    ),
                  ),
                ),
                FilterField(
                  label: 'Specijalizacija',
                  width: 190,
                  child: _dropdown<int?>(
                    value: _specializationId,
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Sve specijalizacije'),
                      ),
                      for (final specialization in _specializations)
                        DropdownMenuItem(
                          value: specialization.id,
                          child: Text(
                            specialization.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: (value) =>
                        _applyFilterChange(() => _specializationId = value),
                  ),
                ),
                FilterField(
                  label: 'Dostupnost',
                  width: 160,
                  child: _dropdown<bool?>(
                    value: _isAvailable,
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Sve')),
                      DropdownMenuItem(value: true, child: Text('Dostupan')),
                      DropdownMenuItem(value: false, child: Text('Nedostupan')),
                    ],
                    onChanged: (value) =>
                        _applyFilterChange(() => _isAvailable = value),
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
                  label: 'Dodaj trenera',
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
              child: DataTableCard<TrainerResponse>(
                title: 'Lista trenera',
                loading: _loading,
                error: _error,
                items: _data?.items ?? const [],
                page: _page,
                pageSize: _pageSize,
                totalCount: _data?.totalCount,
                totalPages: _data?.totalPages,
                itemsLabel: 'trenera',
                emptyMessage: 'Nema trenera za zadate filtere.',
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
                  ColumnSpec('Trener', flex: 3),
                  ColumnSpec('Biografija', flex: 3),
                  ColumnSpec('Dostupnost', width: 120),
                  ColumnSpec('Status', width: 110),
                  ColumnSpec('Kreirano', width: 130),
                  ColumnSpec('Akcije', width: 116),
                ],
                cellsBuilder: (context, trainer) => [
                  _trainerCell(trainer),
                  Text(
                    trainer.biography ?? '—',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: const TextStyle(fontSize: 13),
                  ),
                  StatusChip(
                    label: trainer.isAvailable ? 'Dostupan' : 'Nedostupan',
                    tone: trainer.isAvailable ? ChipTone.info : ChipTone.neutral,
                  ),
                  StatusChip(
                    label: trainer.isActive ? 'Aktivan' : 'Neaktivan',
                    tone: trainer.isActive ? ChipTone.success : ChipTone.warning,
                  ),
                  Text(
                    formatDateTime(trainer.createdAtUtc),
                    style: const TextStyle(fontSize: 12.5),
                  ),
                  TableActionButtons(
                    onView: () => _openDetails(trainer),
                    onEdit: () => _openForm(trainer: trainer),
                    onDelete: () => _delete(trainer),
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

class _TrainerDetailsDialog extends StatelessWidget {
  const _TrainerDetailsDialog({required this.trainer});

  final TrainerResponse trainer;

  @override
  Widget build(BuildContext context) {
    final imageUrl = AppConfig.absoluteFileUrl(trainer.imageUrl);
    final initials =
        '${trainer.firstName.isEmpty ? '' : trainer.firstName[0]}${trainer.lastName.isEmpty ? '' : trainer.lastName[0]}';

    return FormDialogShell(
      title: 'Detalji trenera',
      maxWidth: 560,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 34,
                backgroundColor: AppColors.primarySoft,
                foregroundImage: imageUrl == null
                    ? null
                    : NetworkImage(imageUrl),
                child: Text(
                  initials.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onPrimarySoft,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trainer.fullName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        StatusChip(
                          label: trainer.isAvailable
                              ? 'Dostupan'
                              : 'Nedostupan',
                          tone: trainer.isAvailable
                              ? ChipTone.info
                              : ChipTone.neutral,
                        ),
                        const SizedBox(width: 8),
                        StatusChip(
                          label: trainer.isActive ? 'Aktivan' : 'Neaktivan',
                          tone: trainer.isActive
                              ? ChipTone.success
                              : ChipTone.warning,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),
          DetailRow(
            icon: Icons.workspace_premium_outlined,
            label: 'Specijalizacija',
            value: trainer.specializationName,
          ),
          DetailRow(
            icon: Icons.notes_outlined,
            label: 'Biografija',
            value: trainer.biography ?? '',
          ),
          DetailRow(
            icon: Icons.event_outlined,
            label: 'Kreirano',
            value: formatDateTime(trainer.createdAtUtc),
          ),
          DetailRow(
            icon: Icons.update_outlined,
            label: 'Ažurirano',
            value: formatDateTime(trainer.updatedAtUtc),
          ),
        ],
      ),
    );
  }
}
