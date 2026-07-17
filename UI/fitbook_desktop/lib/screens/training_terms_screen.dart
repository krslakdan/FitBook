import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../layouts/master_screen.dart';
import '../models/common/page_result.dart';
import '../models/enums/training_term_status.dart';
import '../models/requests/training_term_cancel_request.dart';
import '../models/responses/training_term_response.dart';
import '../models/search_objects/training_term_search_object.dart';
import '../providers/training_term_provider.dart';
import '../theme/app_theme.dart';
import '../utils/api_client_exception.dart';
import '../utils/formatters.dart';
import '../widgets/crud/confirm_dialog.dart';
import '../widgets/crud/data_table_card.dart';
import '../widgets/crud/filter_bar.dart';
import '../widgets/crud/form_dialog.dart';
import '../widgets/crud/table_action_buttons.dart';
import '../widgets/status_chip.dart';
import 'training_terms_details_screen.dart';

String trainingTermStatusLabel(TrainingTermStatus status) => switch (status) {
  TrainingTermStatus.scheduled => 'Zakazan',
  TrainingTermStatus.cancelled => 'Otkazan',
  TrainingTermStatus.completed => 'Završen',
};

ChipTone trainingTermStatusTone(TrainingTermStatus status) => switch (status) {
  TrainingTermStatus.scheduled => ChipTone.info,
  TrainingTermStatus.cancelled => ChipTone.danger,
  TrainingTermStatus.completed => ChipTone.success,
};

class TrainingTermsScreen extends StatefulWidget {
  const TrainingTermsScreen({super.key});

  @override
  State<TrainingTermsScreen> createState() => _TrainingTermsScreenState();
}

class _TrainingTermsScreenState extends State<TrainingTermsScreen> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  TrainingTermStatus? _status;
  DateTime? _startFrom;
  DateTime? _startTo;

  int _page = 1;
  int _pageSize = 10;

  PageResult<TrainingTermResponse>? _data;
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
      final result = await context.read<TrainingTermProvider>().get(
        filter: TrainingTermSearchObject(
          page: _page,
          pageSize: _pageSize,
          search: _searchController.text.trim(),
          status: _status,
          startFromUtc: _startFrom?.toUtc(),
          startToUtc: _startTo
              ?.add(const Duration(days: 1))
              .subtract(const Duration(seconds: 1))
              .toUtc(),
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
      _status = null;
      _startFrom = null;
      _startTo = null;
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

  Future<void> _pickDate({
    required DateTime? current,
    required ValueChanged<DateTime?> onPicked,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked == null) return;
    onPicked(picked);
  }

  Future<void> _openForm({TrainingTermResponse? term}) async {
    final message = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => TrainingTermsDetailsScreen(term: term),
    );
    if (message == null || !mounted) return;
    _showSuccess(message);
    if (term == null) {
      setState(() => _page = 1);
    }
    await _load();
  }

  Future<void> _openDetails(TrainingTermResponse term) {
    return showDialog<void>(
      context: context,
      builder: (_) => _TrainingTermDetailsDialog(term: term),
    );
  }

  Future<void> _cancelTerm(TrainingTermResponse term) async {
    final reason = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _CancelTermDialog(),
    );
    if (reason == null || !mounted) return;

    try {
      await context.read<TrainingTermProvider>().cancel(
        term.id,
        TrainingTermCancelRequest(reason: reason.isEmpty ? null : reason),
      );
      if (!mounted) return;
      _showSuccess('Termin treninga "${term.trainingName}" je otkazan.');
      await _load();
    } on ApiClientException catch (e) {
      if (!mounted) return;
      _showError(e.message);
    }
  }

  Future<void> _completeTerm(TrainingTermResponse term) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Završavanje termina',
      message:
          'Da li ste sigurni da želite označiti termin treninga "${term.trainingName}" kao završen?',
      confirmLabel: 'Označi kao završen',
      danger: false,
    );
    if (!confirmed || !mounted) return;

    try {
      await context.read<TrainingTermProvider>().complete(term.id);
      if (!mounted) return;
      _showSuccess(
        'Termin treninga "${term.trainingName}" je označen kao završen.',
      );
      await _load();
    } on ApiClientException catch (e) {
      if (!mounted) return;
      _showError(e.message);
    }
  }

  Future<void> _delete(TrainingTermResponse term) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Brisanje termina',
      message:
          'Da li ste sigurni da želite obrisati termin treninga "${term.trainingName}" '
          'zakazan za ${formatDateTime(term.startTimeUtc)}?',
    );
    if (!confirmed || !mounted) return;

    try {
      await context.read<TrainingTermProvider>().remove(term.id);
      if (!mounted) return;
      _showSuccess('Termin treninga "${term.trainingName}" je obrisan.');
      if (_data != null && _data!.items.length == 1 && _page > 1) _page -= 1;
      await _load();
    } on ApiClientException catch (e) {
      if (!mounted) return;
      _showError(e.message);
    }
  }

  Widget _dateFilterField({
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime?> onChanged,
  }) {
    return FilterField(
      label: label,
      width: 160,
      child: TextField(
        readOnly: true,
        controller: TextEditingController(text: formatDate(value)),
        onTap: () => _pickDate(
          current: value,
          onPicked: (picked) => _applyFilterChange(() => onChanged(picked)),
        ),
        decoration: const InputDecoration(
          hintText: 'Odaberite datum',
          prefixIcon: Icon(Icons.calendar_today_outlined, size: 18),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Termini',
      subtitle: 'Upravljanje terminima treninga',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilterBar(
              fields: [
                FilterField(
                  label: 'Pretraga',
                  width: 220,
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
                  label: 'Status',
                  width: 160,
                  child: DropdownButtonFormField<TrainingTermStatus?>(
                    initialValue: _status,
                    isExpanded: true,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: AppColors.textPrimary,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Svi statusi'),
                      ),
                      for (final status in TrainingTermStatus.values)
                        DropdownMenuItem(
                          value: status,
                          child: Text(trainingTermStatusLabel(status)),
                        ),
                    ],
                    onChanged: (value) =>
                        _applyFilterChange(() => _status = value),
                  ),
                ),
                _dateFilterField(
                  label: 'Datum od',
                  value: _startFrom,
                  onChanged: (value) => _startFrom = value,
                ),
                _dateFilterField(
                  label: 'Datum do',
                  value: _startTo,
                  onChanged: (value) => _startTo = value,
                ),
              ],
              actions: [
                FilledButton.icon(
                  onPressed: () => _openForm(),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Dodaj termin'),
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
              child: DataTableCard<TrainingTermResponse>(
                title: 'Lista termina',
                loading: _loading,
                error: _error,
                items: _data?.items ?? const [],
                page: _page,
                pageSize: _pageSize,
                totalCount: _data?.totalCount,
                totalPages: _data?.totalPages,
                itemsLabel: 'termina',
                emptyMessage: 'Nema termina za zadate filtere.',
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
                  ColumnSpec('Sala', flex: 2),
                  ColumnSpec('Početak', width: 130),
                  ColumnSpec('Kraj', width: 130),
                  ColumnSpec('Učesnici', width: 80),
                  ColumnSpec('Status', width: 100),
                  ColumnSpec('Akcije', width: 190),
                ],
                cellsBuilder: (context, term) {
                  final scheduled =
                      term.status == TrainingTermStatus.scheduled;
                  return [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          term.trainingName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${term.trainerFirstName} ${term.trainerLastName}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      term.hallName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13),
                    ),
                    Text(
                      formatDateTime(term.startTimeUtc),
                      style: const TextStyle(fontSize: 12.5),
                    ),
                    Text(
                      formatDateTime(term.endTimeUtc),
                      style: const TextStyle(fontSize: 12.5),
                    ),
                    Text(
                      '${term.maxParticipants}',
                      style: const TextStyle(fontSize: 13),
                    ),
                    StatusChip(
                      label: trainingTermStatusLabel(term.status),
                      tone: trainingTermStatusTone(term.status),
                    ),
                    TableActionButtons(
                      onView: () => _openDetails(term),
                      onEdit: scheduled ? () => _openForm(term: term) : null,
                      extras: [
                        TableActionExtra(
                          icon: Icons.event_busy_outlined,
                          tooltip: scheduled
                              ? 'Otkaži termin'
                              : 'Termin se ne može otkazati.',
                          danger: true,
                          onTap: scheduled ? () => _cancelTerm(term) : null,
                        ),
                        TableActionExtra(
                          icon: Icons.task_alt_outlined,
                          tooltip: scheduled
                              ? 'Označi kao završen'
                              : 'Termin se ne može završiti.',
                          onTap: scheduled ? () => _completeTerm(term) : null,
                        ),
                      ],
                      onDelete: () => _delete(term),
                    ),
                  ];
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CancelTermDialog extends StatefulWidget {
  const _CancelTermDialog();

  @override
  State<_CancelTermDialog> createState() => _CancelTermDialogState();
}

class _CancelTermDialogState extends State<_CancelTermDialog> {
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormDialogShell(
      title: 'Otkazivanje termina',
      maxWidth: 480,
      saveLabel: 'Otkaži termin',
      onSave: () => Navigator.of(context).pop(_reasonController.text.trim()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Termin će biti otkazan, a sve aktivne rezervacije za ovaj termin će biti poništene.',
            style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          const FormFieldLabel('Razlog otkazivanja'),
          TextField(
            controller: _reasonController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Unesite razlog otkazivanja (opcionalno)',
            ),
          ),
        ],
      ),
    );
  }
}

class _TrainingTermDetailsDialog extends StatelessWidget {
  const _TrainingTermDetailsDialog({required this.term});

  final TrainingTermResponse term;

  @override
  Widget build(BuildContext context) {
    return FormDialogShell(
      title: 'Detalji termina',
      maxWidth: 560,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  term.trainingName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              StatusChip(
                label: trainingTermStatusLabel(term.status),
                tone: trainingTermStatusTone(term.status),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),
          DetailRow(
            icon: Icons.badge_outlined,
            label: 'Trener',
            value: '${term.trainerFirstName} ${term.trainerLastName}',
          ),
          DetailRow(
            icon: Icons.meeting_room_outlined,
            label: 'Sala',
            value: term.hallName,
          ),
          DetailRow(
            icon: Icons.play_circle_outline,
            label: 'Početak',
            value: formatDateTime(term.startTimeUtc),
          ),
          DetailRow(
            icon: Icons.stop_circle_outlined,
            label: 'Kraj',
            value: formatDateTime(term.endTimeUtc),
          ),
          DetailRow(
            icon: Icons.people_outline,
            label: 'Max učesnika',
            value: '${term.maxParticipants}',
          ),
          DetailRow(
            icon: Icons.event_outlined,
            label: 'Kreirano',
            value: formatDateTime(term.createdAtUtc),
          ),
          DetailRow(
            icon: Icons.update_outlined,
            label: 'Ažurirano',
            value: formatDateTime(term.updatedAtUtc),
          ),
        ],
      ),
    );
  }
}
