import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../layouts/master_screen.dart';
import '../models/enums/reservation_status.dart';
import '../models/enums/training_term_status.dart';
import '../models/responses/training_term_response.dart';
import '../models/search_objects/reservation_search_object.dart';
import '../models/search_objects/trainer_search_object.dart';
import '../models/search_objects/training_term_search_object.dart';
import '../providers/auth_provider.dart';
import '../providers/reservation_provider.dart';
import '../providers/trainer_provider.dart';
import '../providers/training_term_provider.dart';
import '../theme/app_theme.dart';
import '../utils/api_client_exception.dart';
import '../utils/formatters.dart';
import '../widgets/status_chip.dart';
import 'trainer_term_detail_screen.dart';

class TrainerDashboardScreen extends StatefulWidget {
  const TrainerDashboardScreen({super.key, this.onGoToTerms});

  final VoidCallback? onGoToTerms;

  @override
  State<TrainerDashboardScreen> createState() => _TrainerDashboardScreenState();
}

class _TrainerDashboardScreenState extends State<TrainerDashboardScreen> {
  final List<TrainingTermResponse> _terms = [];
  int? _trainerId;
  int _pendingCount = 0;
  bool _loading = true;
  bool _noProfile = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _noProfile = false;
    });

    final userId = context.read<AuthProvider>().currentUserId;
    final trainerProvider = context.read<TrainerProvider>();
    final termProvider = context.read<TrainingTermProvider>();
    final reservationProvider = context.read<ReservationProvider>();

    try {
      final trainerId = _trainerId ?? await _resolveTrainerId(trainerProvider, userId);
      if (trainerId == null) {
        if (!mounted) return;
        setState(() {
          _loading = false;
          _noProfile = true;
        });
        return;
      }
      _trainerId = trainerId;

      final termsResult = await termProvider.get(
        filter: TrainingTermSearchObject(
          trainerId: trainerId,
          pageSize: 100,
          includeTotalCount: true,
        ),
      );
      final pendingResult = await reservationProvider.get(
        filter: ReservationSearchObject(
          trainerId: trainerId,
          status: ReservationStatus.pending,
          pageSize: 1,
          includeTotalCount: true,
        ),
      );
      if (!mounted) return;
      setState(() {
        _terms
          ..clear()
          ..addAll(termsResult.items);
        _pendingCount = pendingResult.totalCount ?? 0;
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

  Future<int?> _resolveTrainerId(TrainerProvider provider, int? userId) async {
    if (userId == null) return null;
    final result = await provider.get(filter: const TrainerSearchObject(pageSize: 100));
    for (final trainer in result.items) {
      if (trainer.userAccountId == userId) return trainer.id;
    }
    return null;
  }

  List<TrainingTermResponse> get _upcomingScheduled {
    final now = DateTime.now().toUtc();
    return _terms
        .where((t) => t.status == TrainingTermStatus.scheduled && t.startTimeUtc.isAfter(now))
        .toList()
      ..sort((a, b) => a.startTimeUtc.compareTo(b.startTimeUtc));
  }

  List<TrainingTermResponse> get _todayTerms {
    final now = DateTime.now();
    return _terms.where((t) {
      final start = t.startTimeUtc.toLocal();
      return start.year == now.year &&
          start.month == now.month &&
          start.day == now.day &&
          t.status != TrainingTermStatus.cancelled;
    }).toList()
      ..sort((a, b) => a.startTimeUtc.compareTo(b.startTimeUtc));
  }

  Future<void> _openTerm(TrainingTermResponse term) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TrainerTermDetailScreen(term: term)),
    );
    if (!mounted) return;
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return MasterScreen(
      title: 'Danas',
      subtitle: formatDateWithWeekday(now),
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading && _terms.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_noProfile) {
      return const _MessageView(
        icon: Icons.badge_outlined,
        title: 'Trenerski profil nije pronađen',
        message: 'Vaš nalog nije povezan sa trenerskim profilom. Obratite se administratoru.',
      );
    }

    if (_error != null && _terms.isEmpty) {
      return _ErrorView(message: _error!, onRetry: _load);
    }

    final nextTerm = _upcomingScheduled.isEmpty ? null : _upcomingScheduled.first;
    final todayTerms = _todayTerms;

    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.primary,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: [
          _NextTermCard(term: nextTerm, onTap: nextTerm == null ? null : () => _openTerm(nextTerm)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  icon: Icons.event_note_outlined,
                  value: '${todayTerms.length}',
                  label: 'Termina danas',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatTile(
                  icon: Icons.pending_actions_outlined,
                  value: '$_pendingCount',
                  label: 'Čeka potvrdu',
                  highlight: _pendingCount > 0,
                  onTap: widget.onGoToTerms,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            'Današnji termini',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          if (todayTerms.isEmpty)
            const _EmptyToday()
          else
            for (final term in todayTerms) ...[
              _TodayTermCard(term: term, onTap: () => _openTerm(term)),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }
}

class _NextTermCard extends StatelessWidget {
  const _NextTermCard({required this.term, required this.onTap});

  final TrainingTermResponse? term;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final term = this.term;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.28),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: term == null
                ? const _NextTermEmpty()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.upcoming_outlined, size: 18, color: Colors.white70),
                          const SizedBox(width: 6),
                          Text(
                            'Sljedeći termin',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        term.trainingName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20,
                          height: 1.2,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _HeroLine(
                        icon: Icons.event_outlined,
                        text: formatDateWithWeekday(term.startTimeUtc.toLocal()),
                      ),
                      const SizedBox(height: 6),
                      _HeroLine(
                        icon: Icons.schedule_outlined,
                        text: formatTimeRange(term.startTimeUtc, term.endTimeUtc),
                      ),
                      const SizedBox(height: 6),
                      _HeroLine(icon: Icons.place_outlined, text: term.hallName),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.people_alt_outlined, size: 15, color: Colors.white),
                            const SizedBox(width: 6),
                            Text(
                              'Prijavljeni: ${term.reservedCount}/${term.maxParticipants}',
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _NextTermEmpty extends StatelessWidget {
  const _NextTermEmpty();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.check_circle_outline, size: 18, color: Colors.white70),
            const SizedBox(width: 6),
            Text(
              'Sljedeći termin',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Nema zakazanih termina',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Trenutno nemate nijedan nadolazeći termin.',
          style: TextStyle(
            fontSize: 13,
            height: 1.35,
            color: Colors.white.withValues(alpha: 0.85),
          ),
        ),
      ],
    );
  }
}

class _HeroLine extends StatelessWidget {
  const _HeroLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: Colors.white.withValues(alpha: 0.85)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.95),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    this.highlight = false,
    this.onTap,
  });

  final IconData icon;
  final String value;
  final String label;
  final bool highlight;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final background = highlight ? AppColors.warningSoft : AppColors.surface;
    final accent = highlight ? AppColors.onWarningSoft : AppColors.primary;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: highlight ? Colors.transparent : AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 20, color: accent),
                  const Spacer(),
                  if (onTap != null)
                    Icon(Icons.chevron_right, size: 18, color: accent.withValues(alpha: 0.7)),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: highlight ? AppColors.onWarningSoft : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TodayTermCard extends StatelessWidget {
  const _TodayTermCard({required this.term, required this.onTap});

  final TrainingTermResponse term;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (statusLabel, statusTone) = _termStatusDisplay(term.status);
    final isFull = term.reservedCount >= term.maxParticipants;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      formatTimeRange(term.startTimeUtc, term.endTimeUtc).split(' - ').first,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onPrimarySoft,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Icon(Icons.schedule, size: 13, color: AppColors.onPrimarySoft),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            term.trainingName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusChip(label: statusLabel, tone: statusTone),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.place_outlined, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            term.hallName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.people_alt_outlined,
                          size: 14,
                          color: isFull ? AppColors.danger : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${term.reservedCount}/${term.maxParticipants}',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: isFull ? AppColors.danger : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

(String, ChipTone) _termStatusDisplay(TrainingTermStatus status) => switch (status) {
  TrainingTermStatus.scheduled => ('Zakazan', ChipTone.info),
  TrainingTermStatus.cancelled => ('Otkazan', ChipTone.danger),
  TrainingTermStatus.completed => ('Završen', ChipTone.neutral),
};

class _EmptyToday extends StatelessWidget {
  const _EmptyToday();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        children: [
          Icon(Icons.free_breakfast_outlined, size: 38, color: AppColors.textSecondary),
          SizedBox(height: 12),
          Text(
            'Nemate termina danas.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.5, height: 1.4, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _MessageView extends StatelessWidget {
  const _MessageView({required this.icon, required this.title, required this.message});

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 92,
              height: 92,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.neutralSoft,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(icon, size: 44, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, height: 1.4, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
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
