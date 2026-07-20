import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../layouts/master_screen.dart';
import '../models/common/page_result.dart';
import '../models/enums/reservation_status.dart';
import '../models/requests/reservation_cancel_request.dart';
import '../models/responses/reservation_response.dart';
import '../models/search_objects/reservation_search_object.dart';
import '../providers/reservation_provider.dart';
import '../theme/app_theme.dart';
import '../utils/api_client_exception.dart';
import '../utils/formatters.dart';
import '../widgets/crud/confirm_dialog.dart';
import '../widgets/crud/data_table_card.dart';
import '../widgets/crud/filter_bar.dart';
import '../widgets/crud/form_dialog.dart';
import '../widgets/crud/table_action_buttons.dart';
import '../widgets/status_chip.dart';

String reservationStatusLabel(ReservationStatus status) => switch (status) {
  ReservationStatus.pending => 'Na čekanju',
  ReservationStatus.confirmed => 'Potvrđena',
  ReservationStatus.cancelled => 'Otkazana',
  ReservationStatus.completed => 'Završena',
};

ChipTone reservationStatusTone(ReservationStatus status) => switch (status) {
  ReservationStatus.pending => ChipTone.warning,
  ReservationStatus.confirmed => ChipTone.info,
  ReservationStatus.cancelled => ChipTone.danger,
  ReservationStatus.completed => ChipTone.success,
};

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key});

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  ReservationStatus? _status;
  DateTime? _reservedFrom;
  DateTime? _reservedTo;

  int _page = 1;
  int _pageSize = 10;

  PageResult<ReservationResponse>? _data;
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
      final result = await context.read<ReservationProvider>().get(
        filter: ReservationSearchObject(
          page: _page,
          pageSize: _pageSize,
          search: _searchController.text.trim(),
          status: _status,
          reservedFromUtc: _reservedFrom?.toUtc(),
          reservedToUtc: _reservedTo
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
      _reservedFrom = null;
      _reservedTo = null;
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

  String _userFullName(ReservationResponse reservation) =>
      '${reservation.userFirstName} ${reservation.userLastName}';

  Future<void> _openDetails(ReservationResponse reservation) {
    return showDialog<void>(
      context: context,
      builder: (_) => _ReservationDetailsDialog(reservation: reservation),
    );
  }

  Future<void> _confirm(ReservationResponse reservation) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Potvrda rezervacije',
      message:
          'Da li ste sigurni da želite potvrditi rezervaciju korisnika "${_userFullName(reservation)}" '
          'za trening "${reservation.trainingName}"?',
      confirmLabel: 'Potvrdi',
      danger: false,
    );
    if (!confirmed || !mounted) return;

    try {
      await context.read<ReservationProvider>().confirm(reservation.id);
      if (!mounted) return;
      _showSuccess(
        'Rezervacija korisnika "${_userFullName(reservation)}" je potvrđena.',
      );
      await _load();
    } on ApiClientException catch (e) {
      if (!mounted) return;
      _showError(e.message);
    }
  }

  Future<void> _cancel(ReservationResponse reservation) async {
    final reason = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _CancelReservationDialog(),
    );
    if (reason == null || !mounted) return;

    try {
      await context.read<ReservationProvider>().cancel(
        reservation.id,
        ReservationCancelRequest(reason: reason),
      );
      if (!mounted) return;
      _showSuccess(
        'Rezervacija korisnika "${_userFullName(reservation)}" je otkazana.',
      );
      await _load();
    } on ApiClientException catch (e) {
      if (!mounted) return;
      _showError(e.message);
    }
  }

  Future<void> _complete(ReservationResponse reservation) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Završavanje rezervacije',
      message:
          'Da li ste sigurni da želite označiti rezervaciju korisnika "${_userFullName(reservation)}" kao završenu?',
      confirmLabel: 'Označi kao završenu',
      danger: false,
    );
    if (!confirmed || !mounted) return;

    try {
      await context.read<ReservationProvider>().complete(reservation.id);
      if (!mounted) return;
      _showSuccess(
        'Rezervacija korisnika "${_userFullName(reservation)}" je označena kao završena.',
      );
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

  Widget _userCell(ReservationResponse reservation) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _userFullName(reservation),
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
        ),
        Text(
          reservation.userEmail,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Rezervacije',
      subtitle: 'Pregled i upravljanje rezervacijama',
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
                      hintText: 'Korisnik ili trening...',
                      prefixIcon: Icon(Icons.search, size: 20),
                    ),
                  ),
                ),
                FilterField(
                  label: 'Status',
                  width: 160,
                  child: DropdownButtonFormField<ReservationStatus?>(
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
                      for (final status in ReservationStatus.values)
                        DropdownMenuItem(
                          value: status,
                          child: Text(reservationStatusLabel(status)),
                        ),
                    ],
                    onChanged: (value) =>
                        _applyFilterChange(() => _status = value),
                  ),
                ),
                _dateFilterField(
                  label: 'Datum od',
                  value: _reservedFrom,
                  onChanged: (value) => _reservedFrom = value,
                ),
                _dateFilterField(
                  label: 'Datum do',
                  value: _reservedTo,
                  onChanged: (value) => _reservedTo = value,
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
              child: DataTableCard<ReservationResponse>(
                title: 'Lista rezervacija',
                loading: _loading,
                error: _error,
                items: _data?.items ?? const [],
                page: _page,
                pageSize: _pageSize,
                totalCount: _data?.totalCount,
                totalPages: _data?.totalPages,
                itemsLabel: 'rezervacija',
                emptyMessage: 'Nema rezervacija za zadate filtere.',
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
                  ColumnSpec('Trening', flex: 3),
                  ColumnSpec('Termin', width: 130),
                  ColumnSpec('Rezervisano', width: 130),
                  ColumnSpec('Status', width: 110),
                  ColumnSpec('Akcije', width: 160),
                ],
                cellsBuilder: (context, reservation) {
                  final pending =
                      reservation.status == ReservationStatus.pending;
                  final confirmed =
                      reservation.status == ReservationStatus.confirmed;
                  return [
                    _userCell(reservation),
                    Text(
                      reservation.trainingName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13),
                    ),
                    Text(
                      formatDateTime(reservation.trainingTermStartTimeUtc),
                      style: const TextStyle(fontSize: 12.5),
                    ),
                    Text(
                      formatDateTime(reservation.reservedAtUtc),
                      style: const TextStyle(fontSize: 12.5),
                    ),
                    StatusChip(
                      label: reservationStatusLabel(reservation.status),
                      tone: reservationStatusTone(reservation.status),
                    ),
                    TableActionButtons(
                      onView: () => _openDetails(reservation),
                      showDelete: false,
                      extras: [
                        TableActionExtra(
                          icon: Icons.check_circle_outline,
                          tooltip: pending
                              ? 'Potvrdi rezervaciju'
                              : 'Rezervacija se ne može potvrditi.',
                          onTap: pending
                              ? () => _confirm(reservation)
                              : null,
                        ),
                        TableActionExtra(
                          icon: Icons.task_alt_outlined,
                          tooltip: confirmed
                              ? 'Označi kao završenu'
                              : 'Rezervacija se ne može završiti.',
                          onTap: confirmed
                              ? () => _complete(reservation)
                              : null,
                        ),
                        TableActionExtra(
                          icon: Icons.event_busy_outlined,
                          tooltip: pending || confirmed
                              ? 'Otkaži rezervaciju'
                              : 'Rezervacija se ne može otkazati.',
                          danger: true,
                          onTap: pending || confirmed
                              ? () => _cancel(reservation)
                              : null,
                        ),
                      ],
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

class _CancelReservationDialog extends StatefulWidget {
  const _CancelReservationDialog();

  @override
  State<_CancelReservationDialog> createState() =>
      _CancelReservationDialogState();
}

class _CancelReservationDialogState extends State<_CancelReservationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(_reasonController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return FormDialogShell(
      title: 'Otkazivanje rezervacije',
      maxWidth: 480,
      saveLabel: 'Otkaži rezervaciju',
      onSave: _submit,
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Rezervacija će biti otkazana, a korisnik će biti obaviješten o razlogu otkazivanja.',
              style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            const FormFieldLabel('Razlog otkazivanja', required: true),
            TextFormField(
              controller: _reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Unesite razlog otkazivanja',
              ),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return 'Razlog otkazivanja je obavezan.';
                if (text.length < 3) {
                  return 'Razlog mora imati najmanje 3 karaktera.';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ReservationDetailsDialog extends StatelessWidget {
  const _ReservationDetailsDialog({required this.reservation});

  final ReservationResponse reservation;

  @override
  Widget build(BuildContext context) {
    return FormDialogShell(
      title: 'Detalji rezervacije',
      maxWidth: 560,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${reservation.userFirstName} ${reservation.userLastName}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              StatusChip(
                label: reservationStatusLabel(reservation.status),
                tone: reservationStatusTone(reservation.status),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),
          DetailRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: reservation.userEmail,
          ),
          DetailRow(
            icon: Icons.fitness_center,
            label: 'Trening',
            value: reservation.trainingName,
          ),
          DetailRow(
            icon: Icons.play_circle_outline,
            label: 'Termin početak',
            value: formatDateTime(reservation.trainingTermStartTimeUtc),
          ),
          DetailRow(
            icon: Icons.stop_circle_outlined,
            label: 'Termin kraj',
            value: formatDateTime(reservation.trainingTermEndTimeUtc),
          ),
          DetailRow(
            icon: Icons.event_available_outlined,
            label: 'Rezervisano',
            value: formatDateTime(reservation.reservedAtUtc),
          ),
          DetailRow(
            icon: Icons.check_circle_outline,
            label: 'Potvrđeno',
            value: formatDateTime(reservation.confirmedAtUtc),
          ),
          DetailRow(
            icon: Icons.task_alt_outlined,
            label: 'Završeno',
            value: formatDateTime(reservation.completedAtUtc),
          ),
          DetailRow(
            icon: Icons.event_busy_outlined,
            label: 'Otkazano',
            value: formatDateTime(reservation.cancelledAtUtc),
          ),
          DetailRow(
            icon: Icons.notes_outlined,
            label: 'Razlog otkazivanja',
            value: reservation.cancellationReason ?? '',
          ),
        ],
      ),
    );
  }
}
