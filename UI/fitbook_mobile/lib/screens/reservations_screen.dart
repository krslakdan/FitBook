import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../layouts/master_screen.dart';
import '../models/responses/reservation_response.dart';
import '../models/search_objects/reservation_search_object.dart';
import '../providers/reservation_provider.dart';
import '../theme/app_theme.dart';
import '../utils/api_client_exception.dart';
import '../utils/formatters.dart';
import '../utils/reservation_display.dart';
import '../widgets/status_chip.dart';
import 'reservation_details_screen.dart';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key});

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen>
    with SingleTickerProviderStateMixin {
  static const int _pageSize = 50;

  late final TabController _tabController;
  final List<ReservationResponse> _all = [];

  int _tabIndex = 0;
  bool _loading = false;
  String? _error;

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

  List<ReservationResponse> get _activeItems {
    final items = _all.where(isActiveReservation).toList()
      ..sort((a, b) => a.trainingTermStartTimeUtc.compareTo(b.trainingTermStartTimeUtc));
    return items;
  }

  List<ReservationResponse> get _pastItems {
    final items = _all.where((r) => !isActiveReservation(r)).toList()
      ..sort((a, b) => b.trainingTermStartTimeUtc.compareTo(a.trainingTermStartTimeUtc));
    return items;
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final collected = <ReservationResponse>[];
      var page = 1;
      while (true) {
        final result = await context.read<ReservationProvider>().get(
          filter: ReservationSearchObject(
            page: page,
            pageSize: _pageSize,
            includeTotalCount: true,
          ),
        );
        collected.addAll(result.items);
        final total = result.totalCount ?? collected.length;
        if (result.items.isEmpty || collected.length >= total) break;
        page++;
      }
      if (!mounted) return;
      setState(() {
        _all
          ..clear()
          ..addAll(collected);
        _loading = false;
      });
    } on ApiClientException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
      if (_all.isNotEmpty) _showMessage(e.message);
    }
  }

  void _selectTab(int index) {
    if (index == _tabIndex) return;
    setState(() => _tabIndex = index);
    _tabController.animateTo(index);
  }

  Future<void> _openDetails(ReservationResponse reservation) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ReservationDetailsScreen(reservation: reservation)),
    );
    if (!mounted) return;
    _load();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final hasData = _all.isNotEmpty;
    return MasterScreen(
      title: 'Rezervacije',
      subtitle: 'Vaše rezervacije treninga',
      child: Column(
        children: [
          _SegmentedTabs(
            currentIndex: _tabIndex,
            activeCount: hasData ? _activeItems.length : null,
            pastCount: hasData ? _pastItems.length : null,
            onChanged: _selectTab,
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading && _all.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _all.isEmpty) {
      return _ErrorView(message: _error!, onRetry: _load);
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildList(
          items: _activeItems,
          emptyIcon: Icons.event_available_outlined,
          emptyTitle: 'Nema aktivnih rezervacija',
          emptyMessage: 'Rezervišite termin treninga i pratite ga ovdje.',
        ),
        _buildList(
          items: _pastItems,
          emptyIcon: Icons.history,
          emptyTitle: 'Nema prošlih rezervacija',
          emptyMessage: 'Ovdje se prikazuju vaše završene i otkazane rezervacije.',
        ),
      ],
    );
  }

  Widget _buildList({
    required List<ReservationResponse> items,
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
                const SizedBox(height: 100),
                _EmptyView(icon: emptyIcon, title: emptyTitle, message: emptyMessage),
              ],
            )
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final reservation = items[index];
                return _ReservationCard(
                  reservation: reservation,
                  onTap: () => _openDetails(reservation),
                );
              },
            ),
    );
  }
}

class _SegmentedTabs extends StatelessWidget {
  const _SegmentedTabs({
    required this.currentIndex,
    required this.activeCount,
    required this.pastCount,
    required this.onChanged,
  });

  final int currentIndex;
  final int? activeCount;
  final int? pastCount;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.neutralSoft,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(child: _segment(0, 'Aktivne', activeCount)),
            Expanded(child: _segment(1, 'Prošle', pastCount)),
          ],
        ),
      ),
    );
  }

  Widget _segment(int index, String label, int? count) {
    final selected = index == currentIndex;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                color: selected ? AppColors.primaryDark : AppColors.textSecondary,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 6),
              _CountBadge(count: count, selected: selected),
            ],
          ],
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count, required this.selected});

  final int count;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1.5),
      decoration: BoxDecoration(
        color: selected ? AppColors.primarySoft : AppColors.surface,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: selected ? AppColors.onPrimarySoft : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  const _ReservationCard({required this.reservation, required this.onTap});

  final ReservationResponse reservation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final start = reservation.trainingTermStartTimeUtc.toLocal();
    final (statusLabel, statusTone) = reservationStatusDisplay(reservation.status);
    final (tileBackground, tileForeground) = reservationStatusColors(reservation.status);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                _DateTile(date: start, background: tileBackground, foreground: tileForeground),
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
                              reservation.trainingName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15.5,
                                height: 1.25,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          StatusChip(label: statusLabel, tone: statusTone),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _MetaLine(
                        icon: Icons.schedule_outlined,
                        text: formatTimeRange(
                          reservation.trainingTermStartTimeUtc,
                          reservation.trainingTermEndTimeUtc,
                        ),
                        strong: true,
                      ),
                      const SizedBox(height: 6),
                      _MetaLine(
                        icon: reservationStatusIcon(reservation.status),
                        text: reservationSecondaryText(reservation),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, size: 20, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  const _DateTile({required this.date, required this.background, required this.foreground});

  final DateTime date;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            weekdayShort(date).toUpperCase(),
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: foreground,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${date.day}',
            style: TextStyle(
              fontSize: 22,
              height: 1,
              fontWeight: FontWeight.w800,
              color: foreground,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            monthShort(date).toUpperCase(),
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.icon, required this.text, this.strong = false});

  final IconData icon;
  final String text;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: strong
                ? const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  )
                : const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.icon, required this.title, required this.message});

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
