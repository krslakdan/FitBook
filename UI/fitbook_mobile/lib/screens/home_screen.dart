import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../layouts/master_screen.dart';
import '../models/enums/membership_status.dart';
import '../models/responses/reservation_response.dart';
import '../models/responses/training_recommendation_response.dart';
import '../models/responses/user_membership_response.dart';
import '../models/search_objects/membership_search_object.dart';
import '../models/search_objects/reservation_search_object.dart';
import '../providers/auth_provider.dart';
import '../providers/main_navigation_controller.dart';
import '../providers/recommendation_provider.dart';
import '../providers/reservation_provider.dart';
import '../providers/system_notification_provider.dart';
import '../providers/training_provider.dart';
import '../providers/user_membership_provider.dart';
import '../theme/app_theme.dart';
import '../utils/api_client_exception.dart';
import '../utils/formatters.dart';
import '../utils/membership_display.dart';
import '../utils/reservation_display.dart';
import '../widgets/notification_bell.dart';
import '../widgets/status_chip.dart';
import 'notifications_screen.dart';
import 'reservation_details_screen.dart';
import 'training_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const int _navTabIndex = 0;
  static const int _trainingsTab = 1;
  static const int _membershipTab = 3;

  late final SystemNotificationProvider _notifications;
  MainNavigationController? _navigation;

  UserMembershipResponse? _membership;
  ReservationResponse? _nextReservation;
  List<TrainingRecommendationResponse> _recommendations = const [];

  bool _loading = true;
  bool _opening = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _notifications = context.read<SystemNotificationProvider>();
    _notifications.refreshUnreadCount();
    _notifications.startPolling();
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final navigation = context.read<MainNavigationController>();
    if (!identical(navigation, _navigation)) {
      _navigation?.removeListener(_onNavigationChanged);
      _navigation = navigation;
      _navigation!.addListener(_onNavigationChanged);
    }
  }

  void _onNavigationChanged() {
    if (mounted && !_loading && _navigation?.selectedIndex == _navTabIndex) {
      _load();
    }
  }

  @override
  void dispose() {
    _navigation?.removeListener(_onNavigationChanged);
    _notifications.stopPolling();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final userId = context.read<AuthProvider>().currentUserId;

    try {
      final results = await Future.wait<Object?>([
        _fetchMembership(userId),
        _fetchNextReservation(userId),
        _fetchRecommendations(),
      ]);
      if (!mounted) return;
      setState(() {
        _membership = results[0] as UserMembershipResponse?;
        _nextReservation = results[1] as ReservationResponse?;
        _recommendations = results[2] as List<TrainingRecommendationResponse>;
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

  Future<UserMembershipResponse?> _fetchMembership(int? userId) async {
    final result = await context.read<UserMembershipProvider>().get(
      filter: MembershipSearchObject(page: 1, pageSize: 50, userAccountId: userId),
    );
    final current = result.items.where(isCurrentMembership).toList()
      ..sort((a, b) {
        if (a.status != b.status) {
          return a.status == MembershipStatus.active ? -1 : 1;
        }
        return b.createdAtUtc.compareTo(a.createdAtUtc);
      });
    return current.isEmpty ? null : current.first;
  }

  Future<ReservationResponse?> _fetchNextReservation(int? userId) async {
    final result = await context.read<ReservationProvider>().get(
      filter: ReservationSearchObject(page: 1, pageSize: 50, userAccountId: userId),
    );
    final upcoming = result.items.where(isActiveReservation).toList()
      ..sort((a, b) => a.trainingTermStartTimeUtc.compareTo(b.trainingTermStartTimeUtc));
    return upcoming.isEmpty ? null : upcoming.first;
  }

  Future<List<TrainingRecommendationResponse>> _fetchRecommendations() {
    return context.read<RecommendationProvider>().getRecommendations(maxResults: 5);
  }

  void _openNotifications() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
  }

  void _selectTab(int index) => context.read<MainNavigationController>().select(index);

  void _openReservation(ReservationResponse reservation) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => ReservationDetailsScreen(reservation: reservation)))
        .then((_) {
      if (mounted) _load();
    });
  }

  Future<void> _openRecommendation(TrainingRecommendationResponse recommendation) async {
    if (_opening) return;
    setState(() => _opening = true);
    try {
      final training = await context.read<TrainingProvider>().getById(recommendation.trainingId);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => TrainingDetailsScreen(training: training)),
      );
    } on ApiClientException catch (e) {
      if (mounted) _showMessage(e.message);
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final firstName = context.read<AuthProvider>().currentFirstName;

    return MasterScreen(
      title: 'FitBook',
      subtitle: firstName == null ? 'Vaš pregled aktivnosti' : 'Zdravo, $firstName',
      actions: [NotificationBell(onTap: _openNotifications)],
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    final isEmpty =
        _membership == null && _nextReservation == null && _recommendations.isEmpty;

    if (_loading && isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && isEmpty) {
      return _ErrorView(message: _error!, onRetry: _load);
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.primary,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          _MembershipSummaryCard(
            membership: _membership,
            onTap: () => _selectTab(_membershipTab),
          ),
          const SizedBox(height: 24),
          const _SectionTitle('Sljedeći trening'),
          const SizedBox(height: 12),
          if (_nextReservation != null)
            _NextTrainingCard(
              reservation: _nextReservation!,
              onTap: () => _openReservation(_nextReservation!),
            )
          else
            _EmptyHint(
              icon: Icons.event_available_outlined,
              message: 'Nemate nadolazećih rezervacija.',
              actionLabel: 'Pregledaj treninge',
              onAction: () => _selectTab(_trainingsTab),
            ),
          const SizedBox(height: 24),
          const _SectionTitle('Preporučeno za vas'),
          const SizedBox(height: 12),
          if (_recommendations.isEmpty)
            const _EmptyHint(
              icon: Icons.auto_awesome_outlined,
              message:
                  'Rezervišite treninge da biste dobili personalizovane preporuke.',
            )
          else
            for (final recommendation in _recommendations) ...[
              _RecommendationCard(
                recommendation: recommendation,
                onTap: () => _openRecommendation(recommendation),
              ),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }
}

class _MembershipSummaryCard extends StatelessWidget {
  const _MembershipSummaryCard({required this.membership, required this.onTap});

  final UserMembershipResponse? membership;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final data = membership;
    final IconData icon;
    final String label;
    final String title;
    final String subtitle;
    final Color background;
    final Color foreground;

    if (data == null) {
      icon = Icons.workspace_premium_outlined;
      label = 'Članarina';
      title = 'Nemate aktivnu članarinu';
      subtitle = 'Aktivirajte članarinu za rezervacije treninga.';
      background = AppColors.neutralSoft;
      foreground = AppColors.onNeutralSoft;
    } else if (data.status == MembershipStatus.active) {
      icon = Icons.workspace_premium;
      label = 'Aktivna članarina';
      title = data.packageName;
      subtitle =
          'Vrijedi do ${formatDate(data.endDateUtc.toLocal())} · ${formatDaysRemaining(membershipDaysRemaining(data))}';
      background = AppColors.primarySoft;
      foreground = AppColors.onPrimarySoft;
    } else {
      icon = Icons.hourglass_top;
      label = 'Članarina na čekanju';
      title = data.packageName;
      subtitle = 'Dovršite plaćanje da aktivirate članarinu.';
      background = AppColors.warningSoft;
      foreground = AppColors.onWarningSoft;
    }

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 24, color: foreground),
              ),
              const SizedBox(width: 14),
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
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12.5, height: 1.3, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right, size: 22, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _NextTrainingCard extends StatelessWidget {
  const _NextTrainingCard({required this.reservation, required this.onTap});

  final ReservationResponse reservation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final start = reservation.trainingTermStartTimeUtc.toLocal();
    final (statusLabel, statusTone) = reservationStatusDisplay(reservation.status);
    final (background, foreground) = reservationStatusColors(reservation.status);
    final trainer = '${reservation.trainerFirstName} ${reservation.trainerLastName}'.trim();

    return Material(
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
              Container(
                width: 54,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: background,
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
                        color: foreground,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      monthShort(start).toUpperCase(),
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: foreground,
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
                            reservation.trainingName,
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
                      text: formatTimeRange(
                        reservation.trainingTermStartTimeUtc,
                        reservation.trainingTermEndTimeUtc,
                      ),
                    ),
                    if (trainer.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      _MetaRow(icon: Icons.person_outline, text: trainer),
                    ],
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

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.recommendation, required this.onTap});

  final TrainingRecommendationResponse recommendation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(Icons.auto_awesome, size: 22, color: AppColors.onPrimarySoft),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recommendation.trainingName,
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
                          '${recommendation.trainingCategoryName} · ${recommendation.durationMinutes} min',
                          style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 20, color: AppColors.textSecondary),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_outline, size: 15, color: AppColors.onPrimarySoft),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        recommendation.explanation,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                          color: AppColors.onPrimarySoft,
                        ),
                      ),
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 34, color: AppColors.textSecondary),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13.5, height: 1.4, color: AppColors.textSecondary),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 14),
            OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
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
