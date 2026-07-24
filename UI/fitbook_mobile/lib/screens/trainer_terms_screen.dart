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

class _TrainerTermsScreenState extends State<TrainerTermsScreen>
    with SingleTickerProviderStateMixin {
  final List<TrainingTermResponse> _terms = [];
  int? _trainerId;
  bool _loading = true;
  bool _noProfile = false;
  String? _error;

  late final TabController _tabController;
  int _tabIndex = 0;
  _TermFilters _filters = const _TermFilters();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted && _tabController.index != _tabIndex) {
        setState(() => _tabIndex = _tabController.index);
      }
    });
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          ..addAll(result.items);
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

  bool _matchesFilters(TrainingTermResponse term) {
    if (_filters.trainingId != null && term.trainingId != _filters.trainingId) {
      return false;
    }
    if (_filters.hallId != null && term.hallId != _filters.hallId) {
      return false;
    }
    if (_filters.day != null) {
      final start = term.startTimeUtc.toLocal();
      final day = _filters.day!;
      if (start.year != day.year || start.month != day.month || start.day != day.day) {
        return false;
      }
    }
    return true;
  }

  List<TrainingTermResponse> get _activeTerms {
    final now = DateTime.now().toUtc();
    return _terms
        .where((t) =>
            _matchesFilters(t) &&
            t.status == TrainingTermStatus.scheduled &&
            t.endTimeUtc.isAfter(now))
        .toList()
      ..sort((a, b) => a.startTimeUtc.compareTo(b.startTimeUtc));
  }

  List<TrainingTermResponse> get _pastTerms {
    final now = DateTime.now().toUtc();
    return _terms
        .where((t) =>
            _matchesFilters(t) &&
            !(t.status == TrainingTermStatus.scheduled && t.endTimeUtc.isAfter(now)))
        .toList()
      ..sort((a, b) => b.startTimeUtc.compareTo(a.startTimeUtc));
  }

  List<({int id, String name})> get _trainingOptions {
    final map = <int, String>{};
    for (final t in _terms) {
      map[t.trainingId] = t.trainingName;
    }
    final list = map.entries.map((e) => (id: e.key, name: e.value)).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list;
  }

  List<({int id, String name})> get _hallOptions {
    final map = <int, String>{};
    for (final t in _terms) {
      map[t.hallId] = t.hallName;
    }
    final list = map.entries.map((e) => (id: e.key, name: e.value)).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list;
  }

  String? _trainingName(int id) {
    for (final t in _terms) {
      if (t.trainingId == id) return t.trainingName;
    }
    return null;
  }

  String? _hallName(int id) {
    for (final t in _terms) {
      if (t.hallId == id) return t.hallName;
    }
    return null;
  }

  Future<void> _openFilterSheet() async {
    final result = await showModalBottomSheet<_TermFilters>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => _TermFilterSheet(
        current: _filters,
        trainings: _trainingOptions,
        halls: _hallOptions,
      ),
    );
    if (result == null || !mounted) return;
    setState(() => _filters = result);
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
    final hasData = _terms.isNotEmpty;
    return MasterScreen(
      title: 'Moji termini',
      subtitle: 'Termini koje vodite',
      child: Column(
        children: [
          _TermsTabBar(
            controller: _tabController,
            currentIndex: _tabIndex,
            activeCount: hasData ? _activeTerms.length : null,
            pastCount: hasData ? _pastTerms.length : null,
          ),
          if (hasData) _buildFilterBar(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    final chips = <Widget>[];
    if (_filters.trainingId != null) {
      chips.add(_FilterChip(
        label: _trainingName(_filters.trainingId!) ?? 'Trening',
        icon: Icons.fitness_center,
        onRemove: () => setState(() => _filters = _filters.copyWith(clearTraining: true)),
      ));
    }
    if (_filters.hallId != null) {
      chips.add(_FilterChip(
        label: _hallName(_filters.hallId!) ?? 'Sala',
        icon: Icons.place_outlined,
        onRemove: () => setState(() => _filters = _filters.copyWith(clearHall: true)),
      ));
    }
    if (_filters.day != null) {
      chips.add(_FilterChip(
        label: formatDate(_filters.day),
        icon: Icons.event_outlined,
        onRemove: () => setState(() => _filters = _filters.copyWith(clearDay: true)),
      ));
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
      child: Row(
        children: [
          Expanded(
            child: chips.isEmpty
                ? const Text(
                    'Svi termini',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (var i = 0; i < chips.length; i++) ...[
                          if (i > 0) const SizedBox(width: 8),
                          chips[i],
                        ],
                      ],
                    ),
                  ),
          ),
          const SizedBox(width: 10),
          _FilterButton(count: _filters.count, onTap: _openFilterSheet),
        ],
      ),
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

    return TabBarView(
      controller: _tabController,
      children: [
        _buildList(
          items: _activeTerms,
          emptyIcon: Icons.event_available_outlined,
          emptyTitle: 'Nema aktivnih termina',
          emptyMessage: 'Ovdje se prikazuju zakazani termini koji još nisu prošli.',
        ),
        _buildList(
          items: _pastTerms,
          emptyIcon: Icons.history,
          emptyTitle: 'Nema prošlih termina',
          emptyMessage: 'Ovdje se prikazuju završeni, otkazani i istekli termini.',
        ),
      ],
    );
  }

  Widget _buildList({
    required List<TrainingTermResponse> items,
    required IconData emptyIcon,
    required String emptyTitle,
    required String emptyMessage,
  }) {
    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.primary,
      child: items.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 90),
                _MessageView(icon: emptyIcon, title: emptyTitle, message: emptyMessage),
              ],
            )
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final term = items[index];
                return _TermCard(term: term, onTap: () => _openTerm(term));
              },
            ),
    );
  }
}

class _TermFilters {
  const _TermFilters({this.trainingId, this.hallId, this.day});

  final int? trainingId;
  final int? hallId;
  final DateTime? day;

  bool get isEmpty => trainingId == null && hallId == null && day == null;

  int get count =>
      (trainingId != null ? 1 : 0) + (hallId != null ? 1 : 0) + (day != null ? 1 : 0);

  _TermFilters copyWith({
    int? trainingId,
    int? hallId,
    DateTime? day,
    bool clearTraining = false,
    bool clearHall = false,
    bool clearDay = false,
  }) {
    return _TermFilters(
      trainingId: clearTraining ? null : (trainingId ?? this.trainingId),
      hallId: clearHall ? null : (hallId ?? this.hallId),
      day: clearDay ? null : (day ?? this.day),
    );
  }
}

class _TermsTabBar extends StatelessWidget {
  const _TermsTabBar({
    required this.controller,
    required this.currentIndex,
    required this.activeCount,
    required this.pastCount,
  });

  final TabController controller;
  final int currentIndex;
  final int? activeCount;
  final int? pastCount;

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      indicator: const UnderlineTabIndicator(
        borderSide: BorderSide(color: AppColors.primary, width: 2.5),
        insets: EdgeInsets.symmetric(horizontal: 44),
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      labelColor: AppColors.primaryDark,
      unselectedLabelColor: AppColors.textSecondary,
      dividerColor: AppColors.border,
      labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      splashBorderRadius: BorderRadius.circular(12),
      tabs: [
        _buildTab('Aktivni', activeCount, currentIndex == 0),
        _buildTab('Prošli', pastCount, currentIndex == 1),
      ],
    );
  }

  Widget _buildTab(String label, int? count, bool selected) {
    return Tab(
      height: 48,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (count != null) ...[
            const SizedBox(width: 7),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: selected ? AppColors.primarySoft : AppColors.neutralSoft,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: selected ? AppColors.onPrimarySoft : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final active = count > 0;
    return Material(
      color: active ? AppColors.primarySoft : AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: active ? Colors.transparent : AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.tune,
                size: 18,
                color: active ? AppColors.onPrimarySoft : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                active ? 'Filter ($count)' : 'Filter',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: active ? AppColors.onPrimarySoft : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.icon, required this.onRemove});

  final String label;
  final IconData icon;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 6, 6, 6),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.onPrimarySoft),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.onPrimarySoft,
            ),
          ),
          const SizedBox(width: 2),
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(999),
            child: const Padding(
              padding: EdgeInsets.all(2),
              child: Icon(Icons.close, size: 15, color: AppColors.onPrimarySoft),
            ),
          ),
        ],
      ),
    );
  }
}

class _TermFilterSheet extends StatefulWidget {
  const _TermFilterSheet({
    required this.current,
    required this.trainings,
    required this.halls,
  });

  final _TermFilters current;
  final List<({int id, String name})> trainings;
  final List<({int id, String name})> halls;

  @override
  State<_TermFilterSheet> createState() => _TermFilterSheetState();
}

class _TermFilterSheetState extends State<_TermFilterSheet> {
  late int? _trainingId = widget.current.trainingId;
  late int? _hallId = widget.current.hallId;
  late DateTime? _day = widget.current.day;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _day ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) setState(() => _day = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 18,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Filtriraj termine',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 18),
          const _FieldLabel('Trening'),
          const SizedBox(height: 6),
          _Dropdown(
            value: _trainingId,
            hint: 'Svi treninzi',
            items: widget.trainings,
            onChanged: (v) => setState(() => _trainingId = v),
          ),
          const SizedBox(height: 14),
          const _FieldLabel('Sala'),
          const SizedBox(height: 6),
          _Dropdown(
            value: _hallId,
            hint: 'Sve sale',
            items: widget.halls,
            onChanged: (v) => setState(() => _hallId = v),
          ),
          const SizedBox(height: 14),
          const _FieldLabel('Datum'),
          const SizedBox(height: 6),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.event_outlined, size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _day == null ? 'Bilo koji datum' : formatDate(_day),
                      style: TextStyle(
                        fontSize: 14,
                        color: _day == null ? AppColors.textSecondary : AppColors.textPrimary,
                        fontWeight: _day == null ? FontWeight.w500 : FontWeight.w600,
                      ),
                    ),
                  ),
                  if (_day != null)
                    InkWell(
                      onTap: () => setState(() => _day = null),
                      borderRadius: BorderRadius.circular(999),
                      child: const Padding(
                        padding: EdgeInsets.all(2),
                        child: Icon(Icons.close, size: 18, color: AppColors.textSecondary),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(const _TermFilters()),
                  style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  child: const Text('Očisti'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(
                    _TermFilters(trainingId: _trainingId, hallId: _hallId, day: _day),
                  ),
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  child: const Text('Primijeni'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _Dropdown extends StatelessWidget {
  const _Dropdown({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  final int? value;
  final String hint;
  final List<({int id, String name})> items;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int?>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
      hint: Text(hint),
      items: [
        DropdownMenuItem<int?>(value: null, child: Text(hint)),
        for (final item in items)
          DropdownMenuItem<int?>(value: item.id, child: Text(item.name)),
      ],
      onChanged: onChanged,
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
