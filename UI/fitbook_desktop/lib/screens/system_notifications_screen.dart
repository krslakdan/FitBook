import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../layouts/master_screen.dart';
import '../models/common/page_result.dart';
import '../models/enums/notification_type.dart';
import '../models/responses/system_notification_response.dart';
import '../models/search_objects/system_notification_search_object.dart';
import '../providers/system_notification_provider.dart';
import '../theme/app_theme.dart';
import '../utils/api_client_exception.dart';
import '../utils/formatters.dart';
import '../widgets/crud/data_table_card.dart';
import '../widgets/crud/filter_bar.dart';
import '../widgets/crud/form_dialog.dart';
import '../widgets/crud/table_action_buttons.dart';
import '../widgets/status_chip.dart';

String notificationTypeLabel(NotificationType type) => switch (type) {
  NotificationType.reservationCreated => 'Rezervacija kreirana',
  NotificationType.reservationConfirmed => 'Rezervacija potvrđena',
  NotificationType.reservationCancelled => 'Rezervacija otkazana',
  NotificationType.reservationCompleted => 'Rezervacija završena',
  NotificationType.membershipPaid => 'Članarina plaćena',
  NotificationType.membershipExpiringSoon => 'Članarina uskoro ističe',
  NotificationType.newsPublished => 'Novost objavljena',
  NotificationType.membershipCancelled => 'Članarina otkazana',
  NotificationType.membershipExpired => 'Članarina istekla',
  NotificationType.membershipPaymentFailed => 'Neuspjelo plaćanje',
  NotificationType.reservationReminder => 'Podsjetnik za trening',
  NotificationType.trainerReservationCreated => 'Nova rezervacija (trener)',
  NotificationType.trainerReservationCancelled => 'Otkazana rezervacija (trener)',
  NotificationType.trainerTermReminder => 'Podsjetnik za termin (trener)',
};

ChipTone notificationTypeTone(NotificationType type) => switch (type) {
  NotificationType.reservationCreated => ChipTone.info,
  NotificationType.reservationConfirmed => ChipTone.success,
  NotificationType.reservationCancelled => ChipTone.danger,
  NotificationType.reservationCompleted => ChipTone.success,
  NotificationType.membershipPaid => ChipTone.success,
  NotificationType.membershipExpiringSoon => ChipTone.warning,
  NotificationType.newsPublished => ChipTone.purple,
  NotificationType.membershipCancelled => ChipTone.danger,
  NotificationType.membershipExpired => ChipTone.neutral,
  NotificationType.membershipPaymentFailed => ChipTone.danger,
  NotificationType.reservationReminder => ChipTone.info,
  NotificationType.trainerReservationCreated => ChipTone.info,
  NotificationType.trainerReservationCancelled => ChipTone.warning,
  NotificationType.trainerTermReminder => ChipTone.info,
};

class SystemNotificationsScreen extends StatefulWidget {
  const SystemNotificationsScreen({super.key});

  @override
  State<SystemNotificationsScreen> createState() => _SystemNotificationsScreenState();
}

class _SystemNotificationsScreenState extends State<SystemNotificationsScreen> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  NotificationType? _notificationType;
  bool? _isRead;
  DateTime? _createdFrom;
  DateTime? _createdTo;

  int _page = 1;
  int _pageSize = 10;

  PageResult<SystemNotificationResponse>? _data;
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
      final result = await context.read<SystemNotificationProvider>().get(
        filter: SystemNotificationSearchObject(
          page: _page,
          pageSize: _pageSize,
          search: _searchController.text.trim(),
          notificationType: _notificationType,
          isRead: _isRead,
          createdFromUtc: _createdFrom?.toUtc(),
          createdToUtc: _createdTo
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
      _notificationType = null;
      _isRead = null;
      _createdFrom = null;
      _createdTo = null;
    });
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

  Future<void> _openDetails(SystemNotificationResponse notification) {
    return showDialog<void>(
      context: context,
      builder: (_) => _SystemNotificationDetailsDialog(notification: notification),
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

  Widget _notificationCell(SystemNotificationResponse notification) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          notification.title,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
        ),
        Text(
          notification.content,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Historija obavijesti',
      subtitle: 'Pregled sistemskih obavijesti korisnika',
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
                      hintText: 'Naslov, sadržaj ili korisnik...',
                      prefixIcon: Icon(Icons.search, size: 20),
                    ),
                  ),
                ),
                FilterField(
                  label: 'Tip',
                  width: 200,
                  child: _dropdown<NotificationType?>(
                    value: _notificationType,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Svi tipovi')),
                      for (final type in NotificationType.values)
                        DropdownMenuItem(
                          value: type,
                          child: Text(
                            notificationTypeLabel(type),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: (value) =>
                        _applyFilterChange(() => _notificationType = value),
                  ),
                ),
                FilterField(
                  label: 'Status',
                  width: 150,
                  child: _dropdown<bool?>(
                    value: _isRead,
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Svi statusi')),
                      DropdownMenuItem(value: false, child: Text('Nepročitano')),
                      DropdownMenuItem(value: true, child: Text('Pročitano')),
                    ],
                    onChanged: (value) => _applyFilterChange(() => _isRead = value),
                  ),
                ),
                _dateFilterField(
                  label: 'Datum od',
                  value: _createdFrom,
                  onChanged: (value) => _createdFrom = value,
                ),
                _dateFilterField(
                  label: 'Datum do',
                  value: _createdTo,
                  onChanged: (value) => _createdTo = value,
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
              child: DataTableCard<SystemNotificationResponse>(
                title: 'Lista obavijesti',
                loading: _loading,
                error: _error,
                items: _data?.items ?? const [],
                page: _page,
                pageSize: _pageSize,
                totalCount: _data?.totalCount,
                totalPages: _data?.totalPages,
                itemsLabel: 'obavijesti',
                emptyMessage: 'Nema obavijesti za zadate filtere.',
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
                  ColumnSpec('Obavijest', flex: 4),
                  ColumnSpec('Korisnik', flex: 2),
                  ColumnSpec('Tip', width: 180),
                  ColumnSpec('Vrijeme', width: 150),
                  ColumnSpec('Status', width: 120),
                  ColumnSpec('Akcije', width: 60),
                ],
                cellsBuilder: (context, notification) => [
                  _notificationCell(notification),
                  Text(
                    notification.userFullName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                  StatusChip(
                    label: notificationTypeLabel(notification.notificationType),
                    tone: notificationTypeTone(notification.notificationType),
                  ),
                  Text(
                    formatDateTime(notification.createdAtUtc),
                    style: const TextStyle(fontSize: 12.5),
                  ),
                  StatusChip(
                    label: notification.isRead ? 'Pročitano' : 'Nepročitano',
                    tone: notification.isRead ? ChipTone.neutral : ChipTone.warning,
                  ),
                  TableActionButtons(
                    onView: () => _openDetails(notification),
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

class _SystemNotificationDetailsDialog extends StatelessWidget {
  const _SystemNotificationDetailsDialog({required this.notification});

  final SystemNotificationResponse notification;

  @override
  Widget build(BuildContext context) {
    return FormDialogShell(
      title: 'Detalji obavijesti',
      maxWidth: 560,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  notification.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              StatusChip(
                label: notificationTypeLabel(notification.notificationType),
                tone: notificationTypeTone(notification.notificationType),
              ),
              const SizedBox(width: 8),
              StatusChip(
                label: notification.isRead ? 'Pročitano' : 'Nepročitano',
                tone: notification.isRead ? ChipTone.neutral : ChipTone.warning,
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),
          DetailRow(
            icon: Icons.notes_outlined,
            label: 'Sadržaj',
            value: notification.content,
          ),
          DetailRow(
            icon: Icons.person_outline,
            label: 'Korisnik',
            value: notification.userFullName,
          ),
          DetailRow(
            icon: Icons.event_outlined,
            label: 'Kreirano',
            value: formatDateTime(notification.createdAtUtc),
          ),
          DetailRow(
            icon: Icons.mark_email_read_outlined,
            label: 'Pročitano',
            value: notification.readAtUtc == null
                ? ''
                : formatDateTime(notification.readAtUtc!),
          ),
        ],
      ),
    );
  }
}
