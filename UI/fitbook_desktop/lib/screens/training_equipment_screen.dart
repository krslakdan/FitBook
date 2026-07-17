import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../layouts/master_screen.dart';
import '../models/common/page_result.dart';
import '../models/responses/training_equipment_response.dart';
import '../models/responses/training_response.dart';
import '../models/search_objects/training_equipment_search_object.dart';
import '../models/search_objects/training_search_object.dart';
import '../providers/training_equipment_provider.dart';
import '../providers/training_provider.dart';
import '../theme/app_theme.dart';
import '../utils/api_client_exception.dart';
import '../utils/formatters.dart';
import '../widgets/crud/confirm_dialog.dart';
import '../widgets/crud/data_table_card.dart';
import '../widgets/crud/filter_bar.dart';
import '../widgets/crud/form_dialog.dart';
import '../widgets/crud/table_action_buttons.dart';
import '../widgets/status_chip.dart';
import 'training_equipment_details_screen.dart';

class TrainingEquipmentScreen extends StatefulWidget {
  const TrainingEquipmentScreen({super.key});

  @override
  State<TrainingEquipmentScreen> createState() =>
      _TrainingEquipmentScreenState();
}

class _TrainingEquipmentScreenState extends State<TrainingEquipmentScreen> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  int? _trainingId;

  int _page = 1;
  int _pageSize = 10;

  PageResult<TrainingEquipmentResponse>? _data;
  List<TrainingResponse> _trainings = const [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
    _loadTrainings();
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
      final result = await context.read<TrainingEquipmentProvider>().get(
        filter: TrainingEquipmentSearchObject(
          page: _page,
          pageSize: _pageSize,
          search: _searchController.text.trim(),
          trainingId: _trainingId,
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

  Future<void> _loadTrainings() async {
    try {
      final result = await context.read<TrainingProvider>().get(
        filter: const TrainingSearchObject(pageSize: 100),
      );
      if (!mounted) return;
      setState(() => _trainings = result.items);
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
      _trainingId = null;
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

  Future<void> _openForm({TrainingEquipmentResponse? trainingEquipment}) async {
    final message = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => TrainingEquipmentDetailsScreen(
        trainingEquipment: trainingEquipment,
      ),
    );
    if (message == null || !mounted) return;
    _showSuccess(message);
    if (trainingEquipment == null) {
      setState(() => _page = 1);
    }
    await _load();
  }

  Future<void> _openDetails(TrainingEquipmentResponse trainingEquipment) {
    return showDialog<void>(
      context: context,
      builder: (_) =>
          _TrainingEquipmentDetailsDialog(trainingEquipment: trainingEquipment),
    );
  }

  String _trainingName(TrainingEquipmentResponse trainingEquipment) {
    for (final training in _trainings) {
      if (training.id == trainingEquipment.trainingId) return training.name;
    }
    return 'Trening #${trainingEquipment.trainingId}';
  }

  Future<void> _delete(TrainingEquipmentResponse trainingEquipment) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Brisanje opreme treninga',
      message:
          'Da li ste sigurni da želite ukloniti opremu "${trainingEquipment.equipmentName}" sa treninga?',
    );
    if (!confirmed || !mounted) return;

    try {
      await context.read<TrainingEquipmentProvider>().remove(
        trainingEquipment.id,
      );
      if (!mounted) return;
      _showSuccess(
        'Oprema "${trainingEquipment.equipmentName}" je uspješno uklonjena sa treninga.',
      );
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
      title: 'Oprema treninga',
      subtitle: 'Upravljanje opremom dodijeljenom treninzima',
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
                  label: 'Trening',
                  width: 220,
                  child: DropdownButtonFormField<int?>(
                    initialValue: _trainingId,
                    isExpanded: true,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: AppColors.textPrimary,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Svi treninzi'),
                      ),
                      for (final training in _trainings)
                        DropdownMenuItem(
                          value: training.id,
                          child: Text(
                            training.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: (value) =>
                        _applyFilterChange(() => _trainingId = value),
                  ),
                ),
              ],
              actions: [
                FilledButton.icon(
                  onPressed: () => _openForm(),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Dodaj opremu treningu'),
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
              child: DataTableCard<TrainingEquipmentResponse>(
                title: 'Lista opreme treninga',
                loading: _loading,
                error: _error,
                items: _data?.items ?? const [],
                page: _page,
                pageSize: _pageSize,
                totalCount: _data?.totalCount,
                totalPages: _data?.totalPages,
                itemsLabel: 'zapisa',
                emptyMessage: 'Nema opreme treninga za zadate filtere.',
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
                  ColumnSpec('Oprema', flex: 2),
                  ColumnSpec('Trening', flex: 2),
                  ColumnSpec('Obavezna', width: 110),
                  ColumnSpec('Napomena', flex: 2),
                  ColumnSpec('Kreirano', width: 130),
                  ColumnSpec('Akcije', width: 116),
                ],
                cellsBuilder: (context, trainingEquipment) => [
                  Text(
                    trainingEquipment.equipmentName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _trainingName(trainingEquipment),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                  StatusChip(
                    label: trainingEquipment.isRequired
                        ? 'Obavezna'
                        : 'Opcionalna',
                    tone: trainingEquipment.isRequired
                        ? ChipTone.purple
                        : ChipTone.neutral,
                  ),
                  Text(
                    trainingEquipment.note ?? '—',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: const TextStyle(fontSize: 13),
                  ),
                  Text(
                    formatDateTime(trainingEquipment.createdAtUtc),
                    style: const TextStyle(fontSize: 12.5),
                  ),
                  TableActionButtons(
                    onView: () => _openDetails(trainingEquipment),
                    onEdit: () => _openForm(trainingEquipment: trainingEquipment),
                    onDelete: () => _delete(trainingEquipment),
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

class _TrainingEquipmentDetailsDialog extends StatelessWidget {
  const _TrainingEquipmentDetailsDialog({required this.trainingEquipment});

  final TrainingEquipmentResponse trainingEquipment;

  @override
  Widget build(BuildContext context) {
    return FormDialogShell(
      title: 'Detalji opreme treninga',
      maxWidth: 520,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  trainingEquipment.equipmentName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              StatusChip(
                label: trainingEquipment.isRequired ? 'Obavezna' : 'Opcionalna',
                tone: trainingEquipment.isRequired
                    ? ChipTone.purple
                    : ChipTone.neutral,
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),
          DetailRow(
            icon: Icons.notes_outlined,
            label: 'Napomena',
            value: trainingEquipment.note ?? '',
          ),
          DetailRow(
            icon: Icons.event_outlined,
            label: 'Kreirano',
            value: formatDateTime(trainingEquipment.createdAtUtc),
          ),
          DetailRow(
            icon: Icons.update_outlined,
            label: 'Ažurirano',
            value: formatDateTime(trainingEquipment.updatedAtUtc),
          ),
        ],
      ),
    );
  }
}
