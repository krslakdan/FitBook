import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../layouts/master_screen.dart';
import '../models/responses/training_category_response.dart';
import '../models/responses/training_response.dart';
import '../models/search_objects/training_category_search_object.dart';
import '../models/search_objects/training_search_object.dart';
import '../providers/training_category_provider.dart';
import '../providers/training_provider.dart';
import '../theme/app_theme.dart';
import '../utils/api_client_exception.dart';
import '../widgets/status_chip.dart';
import 'training_details_screen.dart';

class TrainingsScreen extends StatefulWidget {
  const TrainingsScreen({super.key});

  @override
  State<TrainingsScreen> createState() => _TrainingsScreenState();
}

class _TrainingsScreenState extends State<TrainingsScreen> {
  static const int _pageSize = 20;

  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _searchDebounce;

  final List<TrainingResponse> _items = [];
  List<TrainingCategoryResponse> _categories = const [];
  int? _categoryId;

  int _page = 1;
  bool _hasMore = true;
  bool _loading = false;
  bool _loadingMore = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadCategories();
    _load(reset: true);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      _loadMore();
    }
  }

  Future<void> _loadCategories() async {
    try {
      final result = await context.read<TrainingCategoryProvider>().get(
        filter: const TrainingCategorySearchObject(pageSize: 100, isActive: true),
      );
      if (!mounted) return;
      setState(() => _categories = result.items);
    } on ApiClientException {
      return;
    }
  }

  TrainingSearchObject _filter(int page) => TrainingSearchObject(
    page: page,
    pageSize: _pageSize,
    search: _searchController.text.trim(),
    trainingCategoryId: _categoryId,
    isActive: true,
    includeTotalCount: true,
  );

  Future<void> _load({required bool reset}) async {
    if (reset) {
      setState(() {
        _loading = true;
        _error = null;
        _page = 1;
        _hasMore = true;
      });
    }

    try {
      final result = await context.read<TrainingProvider>().get(filter: _filter(1));
      if (!mounted) return;
      setState(() {
        _items
          ..clear()
          ..addAll(result.items);
        final total = result.totalCount ?? _items.length;
        _hasMore = _items.length < total && result.items.isNotEmpty;
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

  Future<void> _loadMore() async {
    if (_loadingMore || _loading || !_hasMore) return;
    setState(() => _loadingMore = true);
    final nextPage = _page + 1;

    try {
      final result = await context.read<TrainingProvider>().get(filter: _filter(nextPage));
      if (!mounted) return;
      setState(() {
        _page = nextPage;
        _items.addAll(result.items);
        final total = result.totalCount ?? _items.length;
        _hasMore = _items.length < total && result.items.isNotEmpty;
        _loadingMore = false;
      });
    } on ApiClientException {
      if (!mounted) return;
      setState(() => _loadingMore = false);
    }
  }

  void _onSearchChanged(String _) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: 450),
      () => _load(reset: true),
    );
  }

  void _selectCategory(int? id) {
    if (_categoryId == id) return;
    setState(() => _categoryId = id);
    _load(reset: true);
  }

  Future<void> _openDetails(TrainingResponse training) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TrainingDetailsScreen(training: training)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Treninzi',
      subtitle: 'Pregled dostupnih treninga',
      child: Column(
        children: [
          _SearchBar(controller: _searchController, onChanged: _onSearchChanged),
          if (_categories.isNotEmpty)
            _CategoryFilter(
              categories: _categories,
              selectedId: _categoryId,
              onSelected: _selectCategory,
            ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading && _items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _items.isEmpty) {
      return _ErrorView(message: _error!, onRetry: () => _load(reset: true));
    }

    return RefreshIndicator(
      onRefresh: () => _load(reset: true),
      color: AppColors.primary,
      child: _items.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [SizedBox(height: 120), _EmptyView()],
            )
          : ListView.separated(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              itemCount: _items.length + (_hasMore ? 1 : 0),
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index >= _items.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2.4),
                      ),
                    ),
                  );
                }
                final training = _items[index];
                return _TrainingCard(
                  training: training,
                  onTap: () => _openDetails(training),
                );
              },
            ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: const InputDecoration(
          hintText: 'Pretraži treninge...',
          prefixIcon: Icon(Icons.search, size: 20),
        ),
      ),
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  const _CategoryFilter({
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  });

  final List<TrainingCategoryResponse> categories;
  final int? selectedId;
  final ValueChanged<int?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        children: [
          _chip(label: 'Sve', selected: selectedId == null, onTap: () => onSelected(null)),
          for (final category in categories)
            _chip(
              label: category.name,
              selected: selectedId == category.id,
              onTap: () => onSelected(category.id),
            ),
        ],
      ),
    );
  }

  Widget _chip({required String label, required bool selected, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        showCheckmark: false,
        labelStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: selected ? Colors.white : AppColors.textSecondary,
        ),
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.surface,
        side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
      ),
    );
  }
}

class _TrainingCard extends StatelessWidget {
  const _TrainingCard({required this.training, required this.onTap});

  final TrainingResponse training;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (accentBackground, accentForeground) =
        _categoryAccent(training.trainingCategoryId);
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
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accentBackground,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _categoryIcon(training.trainingCategoryName),
                  size: 24,
                  color: accentForeground,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      training.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      training.trainingCategoryName,
                      style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        StatusChip(label: training.difficultyLevelName, tone: ChipTone.info),
                        _MetaText(icon: Icons.timer_outlined, label: '${training.durationMinutes} min'),
                        _MetaText(icon: Icons.people_outline, label: '${training.maxParticipants}'),
                      ],
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 6, top: 2),
                child: Icon(Icons.chevron_right, size: 22, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaText extends StatelessWidget {
  const _MetaText({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

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
              child: const Icon(
                Icons.fitness_center,
                size: 44,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Nema treninga',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Nema treninga za zadate kriterije pretrage.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, height: 1.4, color: AppColors.textSecondary),
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

const List<(Color, Color)> _categoryAccents = [
  (AppColors.primarySoft, AppColors.onPrimarySoft),
  (AppColors.infoSoft, AppColors.onInfoSoft),
  (AppColors.purpleSoft, AppColors.onPurpleSoft),
  (AppColors.warningSoft, AppColors.onWarningSoft),
];

(Color, Color) _categoryAccent(int categoryId) =>
    _categoryAccents[categoryId.abs() % _categoryAccents.length];

IconData _categoryIcon(String categoryName) {
  final name = categoryName.toLowerCase();
  if (name.contains('joga') ||
      name.contains('yoga') ||
      name.contains('pilates') ||
      name.contains('mobil') ||
      name.contains('istez') ||
      name.contains('stretch')) {
    return Icons.self_improvement;
  }
  if (name.contains('kardio') ||
      name.contains('cardio') ||
      name.contains('trč') ||
      name.contains('run') ||
      name.contains('spin')) {
    return Icons.directions_run;
  }
  if (name.contains('hiit') ||
      name.contains('intenz') ||
      name.contains('cross') ||
      name.contains('funkcion')) {
    return Icons.bolt;
  }
  if (name.contains('ples') || name.contains('dance') || name.contains('zumba')) {
    return Icons.music_note;
  }
  if (name.contains('boks') ||
      name.contains('box') ||
      name.contains('borila') ||
      name.contains('martial')) {
    return Icons.sports_mma;
  }
  if (name.contains('pliv') || name.contains('swim') || name.contains('bazen')) {
    return Icons.pool;
  }
  if (name.contains('grup')) {
    return Icons.groups;
  }
  return Icons.fitness_center;
}
