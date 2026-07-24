import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../layouts/master_screen.dart';
import '../models/enums/reservation_status.dart';
import '../models/requests/reservation_cancel_request.dart';
import '../models/responses/reservation_response.dart';
import '../providers/reservation_provider.dart';
import '../theme/app_theme.dart';
import '../utils/api_client_exception.dart';
import '../utils/formatters.dart';
import '../utils/reservation_display.dart';

class ReservationDetailsScreen extends StatefulWidget {
  const ReservationDetailsScreen({super.key, required this.reservation});

  final ReservationResponse reservation;

  @override
  State<ReservationDetailsScreen> createState() => _ReservationDetailsScreenState();
}

class _ReservationDetailsScreenState extends State<ReservationDetailsScreen> {
  late ReservationResponse _reservation;
  bool _cancelling = false;

  @override
  void initState() {
    super.initState();
    _reservation = widget.reservation;
    _refresh();
  }

  Future<void> _refresh() async {
    try {
      final updated = await context.read<ReservationProvider>().getById(widget.reservation.id);
      if (!mounted) return;
      setState(() => _reservation = updated);
    } on ApiClientException {
      return;
    }
  }

  Future<void> _cancel() async {
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => const _CancelReasonDialog(),
    );
    if (reason == null || !mounted) return;

    setState(() => _cancelling = true);
    try {
      final updated = await context.read<ReservationProvider>().cancel(
        _reservation.id,
        ReservationCancelRequest(reason: reason),
      );
      if (!mounted) return;
      setState(() {
        _reservation = updated;
        _cancelling = false;
      });
      _showMessage('Rezervacija je otkazana.');
    } on ApiClientException catch (e) {
      if (!mounted) return;
      setState(() => _cancelling = false);
      _showMessage(e.message);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final reservation = _reservation;
    final reason = reservation.cancellationReason?.trim() ?? '';
    final showReason = reservation.status == ReservationStatus.cancelled && reason.isNotEmpty;
    final trainer = '${reservation.trainerFirstName} ${reservation.trainerLastName}'.trim();

    final rows = <(IconData, String, String)>[
      (
        Icons.event_outlined,
        'Datum',
        formatDateWithWeekday(reservation.trainingTermStartTimeUtc.toLocal()),
      ),
      (
        Icons.schedule_outlined,
        'Vrijeme',
        formatTimeRange(
          reservation.trainingTermStartTimeUtc,
          reservation.trainingTermEndTimeUtc,
        ),
      ),
      (Icons.person_outline, 'Trener', trainer.isEmpty ? '—' : trainer),
      (Icons.place_outlined, 'Sala', reservation.hallName.isEmpty ? '—' : reservation.hallName),
      (Icons.bookmark_added_outlined, 'Rezervisano', formatDateTime(reservation.reservedAtUtc)),
      if (reservation.confirmedAtUtc != null)
        (Icons.check_circle_outline, 'Potvrđeno', formatDateTime(reservation.confirmedAtUtc)),
      if (reservation.completedAtUtc != null)
        (Icons.task_alt, 'Završeno', formatDateTime(reservation.completedAtUtc)),
      if (reservation.cancelledAtUtc != null)
        (Icons.cancel_outlined, 'Otkazano', formatDateTime(reservation.cancelledAtUtc)),
    ];

    return MasterScreen(
      title: reservation.trainingName,
      subtitle: 'Detalji rezervacije',
      showBackButton: true,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _StatusHero(reservation: reservation),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < rows.length; i++)
                  _Line(
                    icon: rows[i].$1,
                    label: rows[i].$2,
                    value: rows[i].$3,
                    last: i == rows.length - 1,
                  ),
              ],
            ),
          ),
          if (showReason) ...[
            const SizedBox(height: 16),
            _ReasonBox(reason: reason),
          ],
          const SizedBox(height: 24),
          _buildAction(),
        ],
      ),
    );
  }

  Widget _buildAction() {
    if (!isActiveReservation(_reservation)) {
      return const SizedBox.shrink();
    }

    return FilledButton.icon(
      onPressed: _cancelling ? null : _cancel,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.danger,
        minimumSize: const Size.fromHeight(52),
      ),
      icon: _cancelling
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
            )
          : const Icon(Icons.close, size: 20),
      label: Text(_cancelling ? 'Otkazivanje...' : 'Otkaži rezervaciju'),
    );
  }
}

class _StatusHero extends StatelessWidget {
  const _StatusHero({required this.reservation});

  final ReservationResponse reservation;

  @override
  Widget build(BuildContext context) {
    final (statusLabel, _) = reservationStatusDisplay(reservation.status);
    final (background, foreground) = reservationStatusColors(reservation.status);
    final start = reservation.trainingTermStartTimeUtc.toLocal();
    final when = '${formatDateWithWeekday(start)} · '
        '${formatTimeRange(reservation.trainingTermStartTimeUtc, reservation.trainingTermEndTimeUtc)}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(reservationStatusIcon(reservation.status), size: 24, color: foreground),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusLabel,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: foreground),
                ),
                const SizedBox(height: 4),
                Text(
                  when,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.3,
                    fontWeight: FontWeight.w500,
                    color: foreground.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({
    required this.icon,
    required this.label,
    required this.value,
    this.last = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 19, color: AppColors.onPrimarySoft),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReasonBox extends StatelessWidget {
  const _ReasonBox({required this.reason});

  final String reason;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.dangerSoft.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 18, color: AppColors.onDangerSoft),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Razlog otkazivanja',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onDangerSoft,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  reason,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: AppColors.onDangerSoft,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CancelReasonDialog extends StatefulWidget {
  const _CancelReasonDialog();

  @override
  State<_CancelReasonDialog> createState() => _CancelReasonDialogState();
}

class _CancelReasonDialogState extends State<_CancelReasonDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() => _error = 'Razlog otkazivanja je obavezan.');
      return;
    }
    Navigator.of(context).pop(text);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Otkazivanje rezervacije'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Unesite razlog otkazivanja rezervacije:'),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            maxLines: 3,
            maxLength: 500,
            inputFormatters: [LengthLimitingTextInputFormatter(500)],
            decoration: InputDecoration(
              hintText: 'Razlog...',
              errorText: _error,
            ),
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Odustani'),
        ),
        FilledButton(
          onPressed: _submit,
          style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
          child: const Text('Otkaži rezervaciju'),
        ),
      ],
    );
  }
}
