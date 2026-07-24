import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../layouts/master_screen.dart';
import '../models/enums/training_term_status.dart';
import '../models/responses/training_term_response.dart';
import '../models/search_objects/trainer_search_object.dart';
import '../models/search_objects/training_term_search_object.dart';
import '../providers/auth_provider.dart';
import '../providers/trainer_provider.dart';
import '../providers/training_term_provider.dart';
import '../theme/app_theme.dart';
import '../utils/api_client_exception.dart';
import '../utils/formatters.dart';
import '../widgets/status_chip.dart';
import 'trainer_term_detail_screen.dart';

class TrainerTermsScreen extends StatefulWidget {
  const TrainerTermsScreen({super.key});

  @override
  State<TrainerTermsScreen> createState() => _TrainerTermsScreenState();
}

class _TrainerTermsScreenState extends State<TrainerTermsScreen> {
  final List<TrainingTermResponse> _terms = [];
  int? _trainerId;
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

      final result = await termProvider.get(
        filter: TrainingTermSearchObject(
          trainerId: trainerId,
          pageSize: 100,
          includeTotalCount: true,
        ),
      );
      if (!mounted) return;
      setState(() {
        _terms
          ..clear()
          ..addAll(_sortTerms(result.items));
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

  List<TrainingTermResponse> _sortTerms(List<TrainingTermResponse> items) {
    final now = DateTime.now().toUtc();
    final upcoming = items.where((t) => t.startTimeUtc.isAfter(now)).toList()
      ..sort((a, b) => a.startTimeUtc.compareTo(b.startTimeUtc));
    final past = items.where((t) => !t.startTimeUtc.isAfter(now)).toList()
      ..sort((a, b) => b.startTimeUtc.compareTo(a.startTimeUtc));
    return [...upcoming, ...past];
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
    return MasterScreen(
      title: 'Moji termini',
      subtitle: 'Termini koje vodite',
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

    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.primary,
      child: _terms.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 100),
                _MessageView(
                  icon: Icons.event_busy_outlined,
                  title: 'Nema termina',
                  message: 'Trenutno vam nije dodijeljen nijedan termin.',
                ),
              ],
            )
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
              itemCount: _terms.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final term = _terms[index];
                return _TermCard(term: term, onTap: () => _openTerm(term));
              },
            ),
    );
  }
}

class _TermCard extends StatelessWidget {
  const _TermCard({required this.term, required this.onTap});

  final TrainingTermResponse term;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final start = term.startTimeUtc.toLocal();
    final (statusLabel, statusTone) = _termStatusDisplay(term.status);
    final (tileBackground, tileForeground) = _termStatusColors(term.status);

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: tileBackground,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${start.day}',
                      style: TextStyle(
                        fontSize: 20,
                        height: 1,
                        fontWeight: FontWeight.w800,
                        color: tileForeground,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      monthShort(start).toUpperCase(),
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: tileForeground,
                      ),
                    ),
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
                    const SizedBox(height: 8),
                    _MetaRow(
                      icon: Icons.schedule_outlined,
                      text: formatTimeRange(term.startTimeUtc, term.endTimeUtc),
                    ),
                    const SizedBox(height: 4),
                    _MetaRow(icon: Icons.place_outlined, text: term.hallName),
                    const SizedBox(height: 8),
                    _CapacityPill(reserved: term.reservedCount, max: term.maxParticipants),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 6, top: 2),
                child: Icon(Icons.chevron_right, size: 20, color: AppColors.textSecondary),
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

(Color, Color) _termStatusColors(TrainingTermStatus status) => switch (status) {
  TrainingTermStatus.scheduled => (AppColors.primarySoft, AppColors.onPrimarySoft),
  TrainingTermStatus.cancelled => (AppColors.dangerSoft, AppColors.onDangerSoft),
  TrainingTermStatus.completed => (AppColors.neutralSoft, AppColors.onNeutralSoft),
};

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _CapacityPill extends StatelessWidget {
  const _CapacityPill({required this.reserved, required this.max});

  final int reserved;
  final int max;

  @override
  Widget build(BuildContext context) {
    final free = (max - reserved).clamp(0, max);
    final isFull = reserved >= max;
    final (background, foreground) = isFull
        ? (AppColors.dangerSoft, AppColors.onDangerSoft)
        : (AppColors.primarySoft, AppColors.onPrimarySoft);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isFull ? Icons.block : Icons.people_alt_outlined, size: 13, color: foreground),
          const SizedBox(width: 5),
          Text(
            isFull ? 'Popunjeno · $reserved/$max' : '$free slobodnih · $reserved/$max',
            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: foreground),
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
