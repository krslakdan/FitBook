import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../layouts/master_screen.dart';
import '../models/enums/reservation_status.dart';
import '../models/enums/training_term_status.dart';
import '../models/requests/reservation_cancel_request.dart';
import '../models/requests/training_term_cancel_request.dart';
import '../models/responses/reservation_response.dart';
import '../models/responses/training_term_response.dart';
import '../models/search_objects/reservation_search_object.dart';
import '../providers/reservation_provider.dart';
import '../providers/training_term_provider.dart';
import '../theme/app_theme.dart';
import '../utils/api_client_exception.dart';
import '../utils/app_config.dart';
import '../utils/formatters.dart';
import '../utils/reservation_display.dart';
import '../widgets/status_chip.dart';

class TrainerTermDetailScreen extends StatefulWidget {
  const TrainerTermDetailScreen({super.key, required this.term});

  final TrainingTermResponse term;

  @override
  State<TrainerTermDetailScreen> createState() => _TrainerTermDetailScreenState();
}

class _TrainerTermDetailScreenState extends State<TrainerTermDetailScreen> {
  final List<ReservationResponse> _reservations = [];
  late TrainingTermResponse _term = widget.term;
  bool _loading = true;
  bool _termBusy = false;
  String? _error;
  int? _busyId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  bool get _termEnded => _term.endTimeUtc.isBefore(DateTime.now().toUtc());

  int get _activeCount => _reservations
      .where((r) =>
          r.status == ReservationStatus.pending || r.status == ReservationStatus.confirmed)
      .length;

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await context.read<ReservationProvider>().get(
        filter: ReservationSearchObject(
          trainingTermId: _term.id,
          pageSize: 100,
          includeTotalCount: true,
        ),
      );
      if (!mounted) return;
      final items = [...result.items]..sort(_sortReservations);
      setState(() {
        _reservations
          ..clear()
          ..addAll(items);
        _loading = false;
      });
    } on ApiClientException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  int _statusOrder(ReservationStatus status) => switch (status) {
    ReservationStatus.pending => 0,
    ReservationStatus.confirmed => 1,
    ReservationStatus.completed => 2,
    ReservationStatus.cancelled => 3,
  };

  int _sortReservations(ReservationResponse a, ReservationResponse b) {
    final byStatus = _statusOrder(a.status).compareTo(_statusOrder(b.status));
    if (byStatus != 0) return byStatus;
    return b.reservedAtUtc.compareTo(a.reservedAtUtc);
  }

  String _userName(ReservationResponse reservation) {
    final name = '${reservation.userFirstName} ${reservation.userLastName}'.trim();
    return name.isEmpty ? reservation.userEmail : name;
  }

  Future<void> _confirm(ReservationResponse reservation) async {
    final provider = context.read<ReservationProvider>();
    final ok = await _confirmDialog(
      'Potvrda rezervacije',
      'Potvrditi rezervaciju korisnika ${_userName(reservation)}?',
      'Potvrdi',
    );
    if (ok != true) return;
    await _runAction(
      reservation,
      () => provider.confirm(reservation.id),
      'Rezervacija je potvrđena.',
    );
  }

  Future<void> _complete(ReservationResponse reservation) async {
    final provider = context.read<ReservationProvider>();
    final ok = await _confirmDialog(
      'Završavanje treninga',
      'Označiti trening korisnika ${_userName(reservation)} kao završen?',
      'Završi',
    );
    if (ok != true) return;
    await _runAction(
      reservation,
      () => provider.complete(reservation.id),
      'Trening je označen kao završen.',
    );
  }

  Future<void> _cancel(ReservationResponse reservation) async {
    final provider = context.read<ReservationProvider>();
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => const _ReasonDialog(),
    );
    if (reason == null) return;
    await _runAction(
      reservation,
      () => provider.cancel(reservation.id, ReservationCancelRequest(reason: reason)),
      'Rezervacija je otkazana.',
    );
  }

  Future<void> _runAction(
    ReservationResponse reservation,
    Future<ReservationResponse> Function() action,
    String successMessage,
  ) async {
    setState(() => _busyId = reservation.id);
    try {
      await action();
      if (!mounted) return;
      _showMessage(successMessage);
      await _load();
    } on ApiClientException catch (e) {
      if (!mounted) return;
      _showMessage(e.message);
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  Future<void> _completeTerm() async {
    final provider = context.read<TrainingTermProvider>();
    final ok = await _confirmDialog(
      'Završavanje termina',
      'Označiti ovaj termin kao završen? Ova radnja se ne može poništiti.',
      'Završi',
    );
    if (ok != true) return;
    await _runTermAction(() => provider.complete(_term.id), 'Termin je označen kao završen.');
  }

  Future<void> _cancelTerm() async {
    final provider = context.read<TrainingTermProvider>();
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => const _ReasonDialog(
        title: 'Otkazivanje termina',
        message: 'Unesite razlog otkazivanja termina. Sve aktivne rezervacije će biti otkazane:',
        confirmLabel: 'Otkaži termin',
      ),
    );
    if (reason == null) return;
    await _runTermAction(
      () => provider.cancel(_term.id, TrainingTermCancelRequest(reason: reason)),
      'Termin je otkazan.',
    );
  }

  Future<void> _runTermAction(
    Future<TrainingTermResponse> Function() action,
    String successMessage,
  ) async {
    setState(() => _termBusy = true);
    try {
      final updated = await action();
      if (!mounted) return;
      setState(() => _term = updated);
      _showMessage(successMessage);
      await _load();
    } on ApiClientException catch (e) {
      if (!mounted) return;
      _showMessage(e.message);
    } finally {
      if (mounted) setState(() => _termBusy = false);
    }
  }

  Future<bool?> _confirmDialog(String title, String message, String confirmLabel) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Odustani'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: _term.trainingName,
      subtitle: 'Rezervacije termina',
      showBackButton: true,
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading && _reservations.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _reservations.isEmpty) {
      return _ErrorView(message: _error!, onRetry: _load);
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.primary,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          _TermInfoCard(
            term: _term,
            activeCount: _activeCount,
          ),
          const SizedBox(height: 16),
          _TermActions(
            status: _term.status,
            ended: _termEnded,
            busy: _termBusy,
            onComplete: _completeTerm,
            onCancel: _cancelTerm,
          ),
          Text(
            'Rezervacije (${_reservations.length})',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          if (_reservations.isEmpty)
            const _EmptyReservations()
          else
            for (final reservation in _reservations) ...[
              _ReservationActionTile(
                reservation: reservation,
                userName: _userName(reservation),
                busy: _busyId == reservation.id,
                onConfirm: reservation.status == ReservationStatus.pending
                    ? () => _confirm(reservation)
                    : null,
                onComplete:
                    reservation.status == ReservationStatus.confirmed && _termEnded
                        ? () => _complete(reservation)
                        : null,
                onCancel: reservation.status == ReservationStatus.pending ||
                        reservation.status == ReservationStatus.confirmed
                    ? () => _cancel(reservation)
                    : null,
              ),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }
}

class _TermInfoCard extends StatelessWidget {
  const _TermInfoCard({required this.term, required this.activeCount});

  final TrainingTermResponse term;
  final int activeCount;

  @override
  Widget build(BuildContext context) {
    final free = (term.maxParticipants - activeCount).clamp(0, term.maxParticipants);
    final isFull = activeCount >= term.maxParticipants;
    final accent = isFull ? AppColors.danger : AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoLine(
            icon: Icons.event_outlined,
            label: 'Datum',
            value: formatDateWithWeekday(term.startTimeUtc.toLocal()),
          ),
          _InfoLine(
            icon: Icons.schedule_outlined,
            label: 'Vrijeme',
            value: formatTimeRange(term.startTimeUtc, term.endTimeUtc),
          ),
          _InfoLine(
            icon: Icons.place_outlined,
            label: 'Sala',
            value: term.hallName,
            last: true,
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isFull ? AppColors.dangerSoft : AppColors.primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.people_alt_outlined, size: 18, color: accent),
                const SizedBox(width: 8),
                Text(
                  isFull ? 'Popunjeno' : 'Slobodna mjesta: $free',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isFull ? AppColors.onDangerSoft : AppColors.onPrimarySoft,
                  ),
                ),
                const Spacer(),
                Text(
                  '$activeCount / ${term.maxParticipants}',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: accent),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TermActions extends StatelessWidget {
  const _TermActions({
    required this.status,
    required this.ended,
    required this.busy,
    required this.onComplete,
    required this.onCancel,
  });

  final TrainingTermStatus status;
  final bool ended;
  final bool busy;
  final VoidCallback onComplete;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final scheduled = status == TrainingTermStatus.scheduled;
    final canComplete = scheduled && ended;
    final canCancel = scheduled && !ended;

    final Widget inner;
    if (busy) {
      inner = const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(strokeWidth: 2.4),
          ),
        ),
      );
    } else if (canComplete) {
      inner = SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: onComplete,
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          icon: const Icon(Icons.check, size: 18),
          label: const Text('Završi termin'),
        ),
      );
    } else if (canCancel) {
      inner = SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onCancel,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            foregroundColor: AppColors.danger,
            side: BorderSide(color: AppColors.danger.withValues(alpha: 0.5)),
          ),
          icon: const Icon(Icons.close, size: 18),
          label: const Text('Otkaži termin'),
        ),
      );
    } else {
      inner = _TermStatusNote(status: status);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: inner,
    );
  }
}

class _TermStatusNote extends StatelessWidget {
  const _TermStatusNote({required this.status});

  final TrainingTermStatus status;

  @override
  Widget build(BuildContext context) {
    final (icon, background, foreground, text) = switch (status) {
      TrainingTermStatus.completed => (
        Icons.task_alt,
        AppColors.neutralSoft,
        AppColors.onNeutralSoft,
        'Ovaj termin je označen kao završen.',
      ),
      TrainingTermStatus.cancelled => (
        Icons.event_busy_outlined,
        AppColors.dangerSoft,
        AppColors.onDangerSoft,
        'Ovaj termin je otkazan.',
      ),
      TrainingTermStatus.scheduled => (
        Icons.info_outline,
        AppColors.neutralSoft,
        AppColors.onNeutralSoft,
        'Termin je zakazan.',
      ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: foreground),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReservationActionTile extends StatelessWidget {
  const _ReservationActionTile({
    required this.reservation,
    required this.userName,
    required this.busy,
    this.onConfirm,
    this.onComplete,
    this.onCancel,
  });

  final ReservationResponse reservation;
  final String userName;
  final bool busy;
  final VoidCallback? onConfirm;
  final VoidCallback? onComplete;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final (statusLabel, statusTone) = reservationStatusDisplay(reservation.status);
    final actions = <Widget>[
      if (onConfirm != null)
        Expanded(child: _FillButton(label: 'Potvrdi', onPressed: onConfirm!)),
      if (onComplete != null)
        Expanded(child: _FillButton(label: 'Završi', onPressed: onComplete!)),
      if (onCancel != null)
        Expanded(child: _DangerButton(label: 'Otkaži', onPressed: onCancel!)),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _UserAvatar(
                imageUrl: AppConfig.absoluteFileUrl(reservation.userProfileImageUrl),
                name: userName,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Rezervisano ${formatRelativeTime(reservation.reservedAtUtc)}',
                      style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              StatusChip(label: statusLabel, tone: statusTone),
            ],
          ),
          if (busy) ...[
            const SizedBox(height: 14),
            const Center(
              child: SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(strokeWidth: 2.4),
              ),
            ),
          ] else if (actions.isNotEmpty) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                for (var i = 0; i < actions.length; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  actions[i],
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.imageUrl, required this.name});

  final String? imageUrl;
  final String name;

  static const double _size = 42;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    if (url != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          url,
          width: _size,
          height: _size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _fallback(),
        ),
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    final initials = _initials(name);
    return Container(
      width: _size,
      height: _size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: initials.isEmpty
          ? const Icon(Icons.person_outline, size: 22, color: AppColors.onPrimarySoft)
          : Text(
              initials,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.onPrimarySoft,
              ),
            ),
    );
  }

  String _initials(String value) {
    final parts = value.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}

class _FillButton extends StatelessWidget {
  const _FillButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(44),
        padding: EdgeInsets.zero,
      ),
      child: Text(label),
    );
  }
}

class _DangerButton extends StatelessWidget {
  const _DangerButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(44),
        padding: EdgeInsets.zero,
        foregroundColor: AppColors.danger,
        side: BorderSide(color: AppColors.danger.withValues(alpha: 0.5)),
      ),
      child: Text(label),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
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

class _EmptyReservations extends StatelessWidget {
  const _EmptyReservations();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        children: [
          Icon(Icons.event_available_outlined, size: 40, color: AppColors.textSecondary),
          SizedBox(height: 12),
          Text(
            'Nema rezervacija za ovaj termin.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.5, height: 1.4, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ReasonDialog extends StatefulWidget {
  const _ReasonDialog({
    this.title = 'Otkazivanje rezervacije',
    this.message = 'Unesite razlog otkazivanja rezervacije:',
    this.confirmLabel = 'Otkaži rezervaciju',
  });

  final String title;
  final String message;
  final String confirmLabel;

  @override
  State<_ReasonDialog> createState() => _ReasonDialogState();
}

class _ReasonDialogState extends State<_ReasonDialog> {
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
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.message),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            maxLines: 3,
            maxLength: 500,
            inputFormatters: [LengthLimitingTextInputFormatter(500)],
            decoration: InputDecoration(hintText: 'Razlog...', errorText: _error),
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
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 52, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, height: 1.4, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Pokušaj ponovo'),
            ),
          ],
        ),
      ),
    );
  }
}
