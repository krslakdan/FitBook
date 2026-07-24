import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../layouts/master_screen.dart';
import '../models/enums/notification_type.dart';
import '../models/enums/payment_status.dart';
import '../models/responses/dashboard_summary_response.dart';
import '../providers/dashboard_provider.dart';
import '../theme/app_theme.dart';
import '../utils/api_client_exception.dart';
import '../utils/app_config.dart';
import '../utils/formatters.dart';
import '../widgets/status_chip.dart';
import 'reservations_screen.dart';
import 'system_notifications_screen.dart';
import 'trainings_screen.dart';
import 'user_memberships_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const _dayOptions = [7, 14, 30];

  int _reservationsDays = 7;

  DashboardSummaryResponse? _summary;
  bool _loading = false;
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
    });

    try {
      final summary = await context
          .read<DashboardProvider>()
          .getSummary(reservationsDays: _reservationsDays);

      if (!mounted) return;
      setState(() => _summary = summary);
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

  String _money(double amount, String currency) =>
      '${amount.toStringAsFixed(2)} ${currency.toUpperCase()}';

  String _time(DateTime utc) {
    final local = utc.toLocal();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(local.hour)}:${two(local.minute)}';
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
    if (_loading && _summary == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _summary == null) {
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

    final summary = _summary!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildKpiRow(summary),
          const SizedBox(height: 16),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 5, child: _buildReservationsChartCard(summary)),
                const SizedBox(width: 16),
                Expanded(flex: 3, child: _buildTopTrainingsCard(summary)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _buildRecentReservationsCard(summary)),
                const SizedBox(width: 16),
                Expanded(child: _buildRecentPaymentsCard(summary)),
                const SizedBox(width: 16),
                Expanded(child: _buildActivitiesCard(summary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiRow(DashboardSummaryResponse summary) {
    return Row(
      children: [
        Expanded(
          child: _KpiTile(
            icon: Icons.groups_outlined,
            iconBackground: AppColors.primarySoft,
            iconColor: AppColors.onPrimarySoft,
            label: 'UKUPNO KORISNIKA',
            value: '${summary.totalUsers}',
            changePercent: summary.totalUsersChangePercent,
            changeCaption: 'u odnosu na prošli mjesec',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _KpiTile(
            icon: Icons.loyalty_outlined,
            iconBackground: AppColors.infoSoft,
            iconColor: AppColors.onInfoSoft,
            label: 'AKTIVNE ČLANARINE',
            value: '${summary.activeMemberships}',
            changePercent: summary.activeMembershipsChangePercent,
            changeCaption: 'u odnosu na prije 30 dana',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _KpiTile(
            icon: Icons.event_available_outlined,
            iconBackground: AppColors.purpleSoft,
            iconColor: AppColors.onPurpleSoft,
            label: 'DANAŠNJE REZERVACIJE',
            value: '${summary.todayReservations}',
            changePercent: summary.todayReservationsChangePercent,
            changeCaption: 'u odnosu na jučer',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _KpiTile(
            icon: Icons.payments_outlined,
            iconBackground: AppColors.warningSoft,
            iconColor: AppColors.onWarningSoft,
            label: 'PRIHOD (OVAJ MJESEC)',
            value: summary.revenueCurrency.isEmpty
                ? summary.monthRevenue.toStringAsFixed(2)
                : _money(summary.monthRevenue, summary.revenueCurrency),
            changePercent: summary.monthRevenueChangePercent,
            changeCaption: 'u odnosu na prošli mjesec',
          ),
        ),
      ],
    );
  }

  Widget _buildReservationsChartCard(DashboardSummaryResponse summary) {
    return _DashboardCard(
      title: 'Rezervacije po danima',
      trailing: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _reservationsDays,
          borderRadius: BorderRadius.circular(10),
          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
          items: [
            for (final days in _dayOptions)
              DropdownMenuItem(value: days, child: Text('Posljednjih $days dana')),
          ],
          onChanged: _loading
              ? null
              : (value) {
                  if (value == null || value == _reservationsDays) return;
                  setState(() => _reservationsDays = value);
                  _load();
                },
        ),
      ),
      child: SizedBox(
        height: 260,
        child: summary.reservationsPerDay.isEmpty
            ? const Center(
                child: Text(
                  'Nema podataka o rezervacijama.',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              )
            : _ReservationsChart(points: summary.reservationsPerDay),
      ),
    );
  }

  Widget _buildTopTrainingsCard(DashboardSummaryResponse summary) {
    return _DashboardCard(
      title: 'Najpopularniji treninzi',
      trailing: _SeeAllButton(onPressed: () => _navigateTo(const TrainingsScreen())),
      child: summary.topTrainings.isEmpty
          ? const _EmptyCardMessage('Još nema rezervisanih treninga.')
          : Column(
              children: [
                for (var i = 0; i < summary.topTrainings.length; i++) ...[
                  if (i > 0) const SizedBox(height: 14),
                  _TopTrainingRow(rank: i + 1, training: summary.topTrainings[i]),
                ],
              ],
            ),
    );
  }

  Widget _buildRecentReservationsCard(DashboardSummaryResponse summary) {
    return _DashboardCard(
      title: 'Nedavne rezervacije',
      trailing: _SeeAllButton(onPressed: () => _navigateTo(const ReservationsScreen())),
      child: summary.recentReservations.isEmpty
          ? const _EmptyCardMessage('Još nema rezervacija.')
          : Column(
              children: [
                for (var i = 0; i < summary.recentReservations.length; i++) ...[
                  if (i > 0) const SizedBox(height: 12),
                  _RecentReservationRow(
                    reservation: summary.recentReservations[i],
                    time: _time,
                  ),
                ],
              ],
            ),
    );
  }

  Widget _buildRecentPaymentsCard(DashboardSummaryResponse summary) {
    return _DashboardCard(
      title: 'Posljednja plaćanja',
      trailing: _SeeAllButton(onPressed: () => _navigateTo(const UserMembershipsScreen())),
      child: summary.recentPayments.isEmpty
          ? const _EmptyCardMessage('Još nema evidentiranih plaćanja.')
          : Column(
              children: [
                for (var i = 0; i < summary.recentPayments.length; i++) ...[
                  if (i > 0) const SizedBox(height: 12),
                  _RecentPaymentRow(
                    payment: summary.recentPayments[i],
                    money: _money,
                  ),
                ],
              ],
            ),
    );
  }

  Widget _buildActivitiesCard(DashboardSummaryResponse summary) {
    return _DashboardCard(
      title: 'Historija obavijesti',
      trailing: _SeeAllButton(
        onPressed: () => _navigateTo(const SystemNotificationsScreen()),
      ),
      child: summary.recentActivities.isEmpty
          ? const _EmptyCardMessage('Još nema aktivnosti u sistemu.')
          : Column(
              children: [
                for (var i = 0; i < summary.recentActivities.length; i++) ...[
                  if (i > 0) const SizedBox(height: 12),
                  _ActivityRow(activity: summary.recentActivities[i]),
                ],
              ],
            ),
    );
  }
}

class _KpiTile extends StatelessWidget {
  const _KpiTile({
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.changePercent,
    required this.changeCaption,
  });

  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String label;
  final String value;
  final double? changePercent;
  final String changeCaption;

  @override
  Widget build(BuildContext context) {
    final change = changePercent;
    final positive = (change ?? 0) >= 0;
    final changeColor = positive ? AppColors.primaryDark : AppColors.danger;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 22, color: iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (change != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  positive ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 14,
                  color: changeColor,
                ),
                const SizedBox(width: 4),
                Text(
                  '${change.abs().toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: changeColor,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    changeCaption,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({required this.title, required this.child, this.trailing});

  final String title;
  final Widget? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _SeeAllButton extends StatelessWidget {
  const _SeeAllButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: Size.zero,
        textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
      ),
      child: const Text('Vidi sve'),
    );
  }
}

class _EmptyCardMessage extends StatelessWidget {
  const _EmptyCardMessage(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

class _ReservationsChart extends StatelessWidget {
  const _ReservationsChart({required this.points});

  final List<DashboardDailyCount> points;

  static const _weekdayLabels = ['Pon', 'Uto', 'Sri', 'Čet', 'Pet', 'Sub', 'Ned'];

  String _bottomLabel(DateTime dateUtc) {
    if (points.length <= 7) return _weekdayLabels[dateUtc.weekday - 1];
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(dateUtc.day)}.${two(dateUtc.month)}.';
  }

  @override
  Widget build(BuildContext context) {
    final maxCount = points.fold<int>(0, (max, p) => p.count > max ? p.count : max);
    final maxY = maxCount == 0 ? 5.0 : (maxCount * 1.25).ceilToDouble();
    final labelStep = (points.length / 7).ceil();

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY,
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) =>
              const FlLine(color: AppColors.border, strokeWidth: 1, dashArray: [4, 4]),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 34,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= points.length) return const SizedBox.shrink();
                if (index % labelStep != 0) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _bottomLabel(points[index].dateUtc),
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.textPrimary,
            getTooltipItems: (spots) => [
              for (final spot in spots)
                LineTooltipItem(
                  '${formatDate(points[spot.x.toInt()].dateUtc)}\n${spot.y.toInt()} rezervacija',
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < points.length; i++)
                FlSpot(i.toDouble(), points[i].count.toDouble()),
            ],
            isCurved: true,
            curveSmoothness: 0.3,
            preventCurveOverShooting: true,
            color: AppColors.primary,
            barWidth: 2.5,
            dotData: FlDotData(
              show: points.length <= 14,
              getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                radius: 3.5,
                color: AppColors.primary,
                strokeWidth: 2,
                strokeColor: Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withValues(alpha: 0.25),
                  AppColors.primary.withValues(alpha: 0.02),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopTrainingRow extends StatelessWidget {
  const _TopTrainingRow({required this.rank, required this.training});

  final int rank;
  final DashboardTopTraining training;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.neutralSoft,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$rank',
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.onNeutralSoft,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      training.trainingName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${training.sharePercent.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '${training.reservationCount} rezervacija · ${training.categoryName}',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (training.sharePercent / 100).clamp(0.0, 1.0),
                  minHeight: 5,
                  backgroundColor: AppColors.neutralSoft,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RecentReservationRow extends StatelessWidget {
  const _RecentReservationRow({required this.reservation, required this.time});

  final DashboardRecentReservation reservation;
  final String Function(DateTime) time;

  @override
  Widget build(BuildContext context) {
    final initials = reservation.userFullName
        .split(' ')
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();
    final imageUrl = AppConfig.absoluteFileUrl(reservation.userImageUrl);

    return Row(
      children: [
        CircleAvatar(
          radius: 17,
          backgroundColor: AppColors.primarySoft,
          foregroundImage: imageUrl == null ? null : NetworkImage(imageUrl),
          child: Text(
            initials,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.onPrimarySoft,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reservation.userFullName,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              Text(
                reservation.trainingName,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formatDate(reservation.termStartUtc.toLocal()),
              style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
            ),
            Text(
              '${time(reservation.termStartUtc)} - ${time(reservation.termEndUtc)}',
              style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(width: 10),
        StatusChip(
          label: reservationStatusLabel(reservation.status),
          tone: reservationStatusTone(reservation.status),
        ),
      ],
    );
  }
}

class _RecentPaymentRow extends StatelessWidget {
  const _RecentPaymentRow({required this.payment, required this.money});

  final DashboardRecentPayment payment;
  final String Function(double, String) money;

  @override
  Widget build(BuildContext context) {
    final refunded = payment.status == PaymentStatus.refunded;

    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.neutralSoft,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.receipt_long_outlined, size: 18, color: AppColors.onNeutralSoft),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                payment.userFullName,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              Text(
                payment.packageName,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              money(payment.amount, payment.currency),
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
            ),
            Text(
              formatDate((payment.paidAtUtc ?? payment.createdAtUtc).toLocal()),
              style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(width: 10),
        StatusChip(
          label: refunded ? 'Refundirano' : 'Plaćeno',
          tone: refunded ? ChipTone.info : ChipTone.success,
        ),
      ],
    );
  }
}

class _ActivityStyle {
  const _ActivityStyle(this.title, this.description, this.icon, this.background, this.foreground);

  final String title;
  final String description;
  final IconData icon;
  final Color background;
  final Color foreground;
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.activity});

  final DashboardActivity activity;

  _ActivityStyle _style() {
    final user = activity.userFullName;
    return switch (activity.type) {
      NotificationType.reservationCreated => _ActivityStyle(
        'Nova rezervacija',
        '$user — kreirana je rezervacija',
        Icons.check_circle_outline,
        AppColors.primarySoft,
        AppColors.onPrimarySoft,
      ),
      NotificationType.reservationConfirmed => _ActivityStyle(
        'Potvrđena rezervacija',
        '$user — rezervacija je potvrđena',
        Icons.event_available_outlined,
        AppColors.primarySoft,
        AppColors.onPrimarySoft,
      ),
      NotificationType.reservationCancelled => _ActivityStyle(
        'Otkazana rezervacija',
        '$user — rezervacija je otkazana',
        Icons.warning_amber_outlined,
        AppColors.warningSoft,
        AppColors.onWarningSoft,
      ),
      NotificationType.reservationCompleted => _ActivityStyle(
        'Završena rezervacija',
        '$user — rezervacija je završena',
        Icons.task_alt_outlined,
        AppColors.infoSoft,
        AppColors.onInfoSoft,
      ),
      NotificationType.membershipPaid => _ActivityStyle(
        'Uspješno plaćanje',
        '$user — uplata članarine je izvršena',
        Icons.info_outline,
        AppColors.infoSoft,
        AppColors.onInfoSoft,
      ),
      NotificationType.membershipExpiringSoon => _ActivityStyle(
        'Članarina uskoro ističe',
        '$user — članarina uskoro ističe',
        Icons.hourglass_bottom_outlined,
        AppColors.warningSoft,
        AppColors.onWarningSoft,
      ),
      NotificationType.membershipCancelled => _ActivityStyle(
        'Otkazana članarina',
        '$user — članarina je otkazana',
        Icons.cancel_outlined,
        AppColors.dangerSoft,
        AppColors.onDangerSoft,
      ),
      NotificationType.membershipExpired => _ActivityStyle(
        'Istekla članarina',
        '$user — članarina je istekla',
        Icons.event_busy_outlined,
        AppColors.neutralSoft,
        AppColors.onNeutralSoft,
      ),
      NotificationType.membershipPaymentFailed => _ActivityStyle(
        'Neuspjelo plaćanje',
        '$user — uplata članarine nije uspjela',
        Icons.error_outline,
        AppColors.dangerSoft,
        AppColors.onDangerSoft,
      ),
      NotificationType.newsPublished => _ActivityStyle(
        'Nova novost',
        '$user — objavljena je novost',
        Icons.campaign_outlined,
        AppColors.infoSoft,
        AppColors.onInfoSoft,
      ),
      NotificationType.reservationReminder => _ActivityStyle(
        'Podsjetnik',
        '$user — poslan je podsjetnik za termin',
        Icons.notifications_outlined,
        AppColors.infoSoft,
        AppColors.onInfoSoft,
      ),
      NotificationType.trainerReservationCreated => _ActivityStyle(
        'Nova rezervacija (trener)',
        '$user — nova rezervacija na terminu',
        Icons.event_available_outlined,
        AppColors.infoSoft,
        AppColors.onInfoSoft,
      ),
      NotificationType.trainerReservationCancelled => _ActivityStyle(
        'Otkazana rezervacija (trener)',
        '$user — rezervacija na terminu je otkazana',
        Icons.event_busy_outlined,
        AppColors.warningSoft,
        AppColors.onWarningSoft,
      ),
      NotificationType.trainerTermReminder => _ActivityStyle(
        'Podsjetnik za termin (trener)',
        '$user — termin uskoro počinje',
        Icons.notifications_outlined,
        AppColors.infoSoft,
        AppColors.onInfoSoft,
      ),
    };
  }

  String _relativeTime() {
    final difference = DateTime.now().toUtc().difference(activity.createdAtUtc);
    if (difference.inMinutes < 1) return 'upravo sada';
    if (difference.inMinutes < 60) return 'prije ${difference.inMinutes} min';
    if (difference.inHours < 24) return 'prije ${difference.inHours} h';
    if (difference.inDays < 7) return 'prije ${difference.inDays} d';
    return formatDate(activity.createdAtUtc.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final style = _style();

    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: style.background,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(style.icon, size: 18, color: style.foreground),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                style.title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              Text(
                style.description,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          _relativeTime(),
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
