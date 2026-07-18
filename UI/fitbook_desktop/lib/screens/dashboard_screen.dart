import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../layouts/master_screen.dart';
import '../models/enums/reservation_status.dart';
import '../models/enums/training_term_status.dart';
import '../models/search_objects/membership_package_search_object.dart';
import '../models/search_objects/reservation_search_object.dart';
import '../models/search_objects/trainer_search_object.dart';
import '../models/search_objects/training_search_object.dart';
import '../models/search_objects/training_term_search_object.dart';
import '../models/search_objects/user_search_object.dart';
import '../providers/membership_package_provider.dart';
import '../providers/reservation_provider.dart';
import '../providers/trainer_provider.dart';
import '../providers/training_provider.dart';
import '../providers/training_term_provider.dart';
import '../providers/user_account_provider.dart';
import '../theme/app_theme.dart';
import '../utils/api_client_exception.dart';
import 'membership_packages_screen.dart';
import 'reservations_screen.dart';
import 'trainers_screen.dart';
import 'training_terms_screen.dart';
import 'trainings_screen.dart';
import 'user_accounts_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _loading = false;
  String? _error;

  int? _activeUsers;
  int? _activeTrainers;
  int? _activeTrainings;
  int? _scheduledTerms;
  int? _pendingReservations;
  int? _activePackages;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        context.read<UserAccountProvider>().get(
          filter: const UserSearchObject(
            pageSize: 1,
            isActive: true,
            includeTotalCount: true,
          ),
        ),
        context.read<TrainerProvider>().get(
          filter: const TrainerSearchObject(
            pageSize: 1,
            isActive: true,
            includeTotalCount: true,
          ),
        ),
        context.read<TrainingProvider>().get(
          filter: const TrainingSearchObject(
            pageSize: 1,
            isActive: true,
            includeTotalCount: true,
          ),
        ),
        context.read<TrainingTermProvider>().get(
          filter: TrainingTermSearchObject(
            pageSize: 1,
            status: TrainingTermStatus.scheduled,
            startFromUtc: DateTime.now().toUtc(),
            includeTotalCount: true,
          ),
        ),
        context.read<ReservationProvider>().get(
          filter: const ReservationSearchObject(
            pageSize: 1,
            status: ReservationStatus.pending,
            includeTotalCount: true,
          ),
        ),
        context.read<MembershipPackageProvider>().get(
          filter: const MembershipPackageSearchObject(
            pageSize: 1,
            isActive: true,
            includeTotalCount: true,
          ),
        ),
      ]);

      if (!mounted) return;
      setState(() {
        _activeUsers = results[0].totalCount;
        _activeTrainers = results[1].totalCount;
        _activeTrainings = results[2].totalCount;
        _scheduledTerms = results[3].totalCount;
        _pendingReservations = results[4].totalCount;
        _activePackages = results[5].totalCount;
      });
    } on ApiClientException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _navigateTo(Widget screen) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Dashboard',
      subtitle: 'Pregled ključnih informacija o sistemu',
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13.5, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Pokušaj ponovo'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Statistika sistema',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Osvježi'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _StatTile(
                icon: Icons.group_outlined,
                label: 'Aktivni korisnici',
                value: _activeUsers,
                onTap: () => _navigateTo(const UserAccountsScreen()),
              ),
              _StatTile(
                icon: Icons.badge_outlined,
                label: 'Aktivni treneri',
                value: _activeTrainers,
                onTap: () => _navigateTo(const TrainersScreen()),
              ),
              _StatTile(
                icon: Icons.fitness_center,
                label: 'Aktivni treninzi',
                value: _activeTrainings,
                onTap: () => _navigateTo(const TrainingsScreen()),
              ),
              _StatTile(
                icon: Icons.calendar_month_outlined,
                label: 'Predstojeći termini',
                value: _scheduledTerms,
                onTap: () => _navigateTo(const TrainingTermsScreen()),
              ),
              _StatTile(
                icon: Icons.event_available_outlined,
                label: 'Rezervacije na čekanju',
                value: _pendingReservations,
                onTap: () => _navigateTo(const ReservationsScreen()),
              ),
              _StatTile(
                icon: Icons.card_membership_outlined,
                label: 'Aktivni paketi članarina',
                value: _activePackages,
                onTap: () => _navigateTo(const MembershipPackagesScreen()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final int? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 22, color: AppColors.onPrimarySoft),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${value ?? '—'}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        label,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
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
