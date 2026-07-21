import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../layouts/master_screen.dart';
import '../models/enums/training_term_status.dart';
import '../models/responses/training_equipment_response.dart';
import '../models/responses/training_response.dart';
import '../models/responses/training_term_response.dart';
import '../models/search_objects/training_equipment_search_object.dart';
import '../models/search_objects/training_term_search_object.dart';
import '../providers/training_equipment_provider.dart';
import '../providers/training_term_provider.dart';
import '../theme/app_theme.dart';
import '../utils/api_client_exception.dart';
import '../utils/formatters.dart';
import '../widgets/status_chip.dart';

class TrainingDetailsScreen extends StatefulWidget {
  const TrainingDetailsScreen({super.key, required this.training});

  final TrainingResponse training;

  @override
  State<TrainingDetailsScreen> createState() => _TrainingDetailsScreenState();
}

class _TrainingDetailsScreenState extends State<TrainingDetailsScreen> {
  List<TrainingTermResponse> _terms = const [];
  bool _loading = true;
  String? _error;

  List<TrainingEquipmentResponse> _equipment = const [];
  bool _equipmentLoading = true;
  String? _equipmentError;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    await Future.wait([_loadTerms(), _loadEquipment()]);
  }

  Future<void> _loadEquipment() async {
    setState(() {
      _equipmentLoading = true;
      _equipmentError = null;
    });

    try {
      final result = await context.read<TrainingEquipmentProvider>().get(
        filter: TrainingEquipmentSearchObject(
          trainingId: widget.training.id,
          pageSize: 100,
          includeTotalCount: true,
        ),
      );
      if (!mounted) return;
      setState(() {
        _equipment = result.items;
        _equipmentLoading = false;
      });
    } on ApiClientException catch (e) {
      if (!mounted) return;
      setState(() {
        _equipmentError = e.message;
        _equipmentLoading = false;
      });
    }
  }

  Future<void> _loadTerms() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await context.read<TrainingTermProvider>().get(
        filter: TrainingTermSearchObject(
          trainingId: widget.training.id,
          startFromUtc: DateTime.now().toUtc(),
          status: TrainingTermStatus.scheduled,
          isActive: true,
          pageSize: 50,
          includeTotalCount: true,
        ),
      );
      if (!mounted) return;
      final terms = [...result.items]
        ..sort((a, b) => a.startTimeUtc.compareTo(b.startTimeUtc));
      setState(() {
        _terms = terms;
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

  @override
  Widget build(BuildContext context) {
    final training = widget.training;

    return MasterScreen(
      title: training.name,
      subtitle: training.trainingCategoryName,
      showBackButton: true,
      child: RefreshIndicator(
        onRefresh: _loadAll,
        color: AppColors.primary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            _InfoCard(training: training),
            const SizedBox(height: 24),
            const Text(
              'Oprema',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ..._buildEquipment(),
            const SizedBox(height: 24),
            const Text(
              'Nadolazeći termini',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ..._buildTerms(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTerms() {
    if (_loading) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }

    if (_error != null) {
      return [
        _MessageBox(
          icon: Icons.cloud_off_outlined,
          message: _error!,
          action: OutlinedButton.icon(
            onPressed: _loadTerms,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Pokušaj ponovo'),
          ),
        ),
      ];
    }

    if (_terms.isEmpty) {
      return const [
        _MessageBox(
          icon: Icons.event_busy_outlined,
          message: 'Trenutno nema zakazanih termina za ovaj trening.',
        ),
      ];
    }

    return [
      for (final term in _terms) ...[
        _TermCard(term: term),
        const SizedBox(height: 10),
      ],
    ];
  }

  List<Widget> _buildEquipment() {
    if (_equipmentLoading) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }

    if (_equipmentError != null) {
      return [
        _MessageBox(
          icon: Icons.cloud_off_outlined,
          message: _equipmentError!,
          action: OutlinedButton.icon(
            onPressed: _loadEquipment,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Pokušaj ponovo'),
          ),
        ),
      ];
    }

    if (_equipment.isEmpty) {
      return const [
        _MessageBox(
          icon: Icons.inventory_2_outlined,
          message: 'Za ovaj trening nije navedena posebna oprema.',
        ),
      ];
    }

    return [
      for (final item in _equipment) ...[
        _EquipmentRow(item: item),
        const SizedBox(height: 10),
      ],
    ];
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.training});

  final TrainingResponse training;

  @override
  Widget build(BuildContext context) {
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
          StatusChip(label: training.difficultyLevelName, tone: ChipTone.info),
          const SizedBox(height: 8),
          StatusChip(label: training.trainingCategoryName, tone: ChipTone.neutral),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _Stat(
                  icon: Icons.timer_outlined,
                  label: 'Trajanje',
                  value: '${training.durationMinutes} min',
                ),
              ),
              Expanded(
                child: _Stat(
                  icon: Icons.people_outline,
                  label: 'Max učesnika',
                  value: '${training.maxParticipants}',
                ),
              ),
            ],
          ),
          if (training.description.trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 16),
            const Text(
              'Opis',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              training.description,
              style: const TextStyle(fontSize: 13.5, height: 1.5, color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
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
        const SizedBox(width: 10),
        Column(
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
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TermCard extends StatelessWidget {
  const _TermCard({required this.term});

  final TrainingTermResponse term;

  String get _timeRange {
    final start = term.startTimeUtc.toLocal();
    final end = term.endTimeUtc.toLocal();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(start.hour)}:${two(start.minute)} - ${two(end.hour)}:${two(end.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final trainer = '${term.trainerFirstName} ${term.trainerLastName}'.trim();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.infoSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.event_outlined, size: 22, color: AppColors.onInfoSoft),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatDateWithWeekday(term.startTimeUtc.toLocal()),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _timeRange,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                _Line(icon: Icons.person_outline, text: trainer.isEmpty ? 'Trener' : trainer),
                const SizedBox(height: 4),
                _Line(icon: Icons.place_outlined, text: term.hallName),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.icon, required this.text});

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
            style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _EquipmentRow extends StatelessWidget {
  const _EquipmentRow({required this.item});

  final TrainingEquipmentResponse item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.neutralSoft,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(Icons.sports_gymnastics, size: 21, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.equipmentName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusChip(
                      label: item.isRequired ? 'Obavezno' : 'Opcionalno',
                      tone: item.isRequired ? ChipTone.info : ChipTone.neutral,
                    ),
                  ],
                ),
                if (item.note != null && item.note!.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.note!,
                    style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBox extends StatelessWidget {
  const _MessageBox({required this.icon, required this.message, this.action});

  final IconData icon;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13.5, height: 1.4, color: AppColors.textSecondary),
          ),
          if (action != null) ...[
            const SizedBox(height: 16),
            action!,
          ],
        ],
      ),
    );
  }
}
