import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../layouts/master_screen.dart';
import '../models/enums/reservation_status.dart';
import '../models/requests/reservation_insert_request.dart';
import '../models/responses/training_term_response.dart';
import '../models/search_objects/reservation_search_object.dart';
import '../providers/reservation_provider.dart';
import '../theme/app_theme.dart';
import '../utils/api_client_exception.dart';
import '../utils/formatters.dart';

class TermDetailsScreen extends StatefulWidget {
  const TermDetailsScreen({super.key, required this.term});

  final TrainingTermResponse term;

  @override
  State<TermDetailsScreen> createState() => _TermDetailsScreenState();
}

class _TermDetailsScreenState extends State<TermDetailsScreen> {
  bool _checking = true;
  bool _alreadyReserved = false;
  bool _reserving = false;

  @override
  void initState() {
    super.initState();
    _checkExisting();
  }

  bool get _isPast => !widget.term.startTimeUtc.isAfter(DateTime.now().toUtc());

  Future<void> _checkExisting() async {
    setState(() => _checking = true);
    try {
      final result = await context.read<ReservationProvider>().get(
        filter: ReservationSearchObject(
          trainingTermId: widget.term.id,
          pageSize: 100,
          includeTotalCount: true,
        ),
      );
      if (!mounted) return;
      final active = result.items.any((r) =>
          r.status == ReservationStatus.pending ||
          r.status == ReservationStatus.confirmed);
      setState(() {
        _alreadyReserved = active;
        _checking = false;
      });
    } on ApiClientException {
      if (!mounted) return;
      setState(() => _checking = false);
    }
  }

  Future<void> _reserve() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Potvrda rezervacije'),
        content: Text(
          'Rezervisati termin "${widget.term.trainingName}" '
          '(${formatDateWithWeekday(widget.term.startTimeUtc.toLocal())} ${formatTimeRange(widget.term.startTimeUtc, widget.term.endTimeUtc)})?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Odustani'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Rezerviši'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _reserving = true);
    try {
      await context.read<ReservationProvider>().create(
        ReservationInsertRequest(trainingTermId: widget.term.id),
      );
      if (!mounted) return;
      setState(() {
        _alreadyReserved = true;
        _reserving = false;
      });
      _showMessage('Rezervacija je kreirana i čeka potvrdu.');
    } on ApiClientException catch (e) {
      if (!mounted) return;
      setState(() => _reserving = false);
      _showMessage(e.message);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final term = widget.term;
    final trainer = '${term.trainerFirstName} ${term.trainerLastName}'.trim();

    return MasterScreen(
      title: term.trainingName,
      subtitle: 'Detalji termina',
      showBackButton: true,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
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
                _Line(
                  icon: Icons.event_outlined,
                  label: 'Datum',
                  value: formatDateWithWeekday(term.startTimeUtc.toLocal()),
                ),
                _Line(
                  icon: Icons.schedule_outlined,
                  label: 'Vrijeme',
                  value: formatTimeRange(term.startTimeUtc, term.endTimeUtc),
                ),
                _Line(
                  icon: Icons.person_outline,
                  label: 'Trener',
                  value: trainer.isEmpty ? '—' : trainer,
                ),
                _Line(
                  icon: Icons.place_outlined,
                  label: 'Sala',
                  value: term.hallName,
                ),
                _Line(
                  icon: Icons.people_outline,
                  label: 'Max učesnika',
                  value: '${term.maxParticipants}',
                  last: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildReserveSection(),
        ],
      ),
    );
  }

  Widget _buildReserveSection() {
    if (_checking) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(strokeWidth: 2.4),
          ),
        ),
      );
    }

    if (_alreadyReserved) {
      return const _InfoBanner(
        icon: Icons.check_circle_outline,
        message: 'Već imate aktivnu rezervaciju za ovaj termin.',
        tone: _BannerTone.success,
      );
    }

    if (_isPast) {
      return const _InfoBanner(
        icon: Icons.info_outline,
        message: 'Termin je već počeo i ne može se rezervisati.',
        tone: _BannerTone.muted,
      );
    }

    return FilledButton.icon(
      onPressed: _reserving ? null : _reserve,
      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
      icon: _reserving
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
            )
          : const Icon(Icons.event_available_outlined, size: 20),
      label: Text(_reserving ? 'Rezervišem...' : 'Rezerviši termin'),
    );
  }
}

enum _BannerTone { success, muted }

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.icon, required this.message, required this.tone});

  final IconData icon;
  final String message;
  final _BannerTone tone;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (tone) {
      _BannerTone.success => (AppColors.primarySoft, AppColors.onPrimarySoft),
      _BannerTone.muted => (AppColors.neutralSoft, AppColors.textSecondary),
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: foreground),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: foreground),
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
