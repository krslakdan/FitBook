import 'package:json_annotation/json_annotation.dart';

import '../enums/payment_status.dart';
import '../enums/reservation_status.dart';

part 'dashboard_summary_response.g.dart';

@JsonSerializable()
class DashboardSummaryResponse {
  DashboardSummaryResponse({
    required this.totalUsers,
    this.totalUsersChangePercent,
    required this.activeMemberships,
    this.activeMembershipsChangePercent,
    required this.todayReservations,
    this.todayReservationsChangePercent,
    required this.monthRevenue,
    required this.revenueCurrency,
    this.monthRevenueChangePercent,
    required this.reservationsPerDay,
    required this.topTrainings,
    required this.recentReservations,
    required this.recentPayments,
  });

  final int totalUsers;
  final double? totalUsersChangePercent;
  final int activeMemberships;
  final double? activeMembershipsChangePercent;
  final int todayReservations;
  final double? todayReservationsChangePercent;
  final double monthRevenue;
  final String revenueCurrency;
  final double? monthRevenueChangePercent;
  final List<DashboardDailyCount> reservationsPerDay;
  final List<DashboardTopTraining> topTrainings;
  final List<DashboardRecentReservation> recentReservations;
  final List<DashboardRecentPayment> recentPayments;

  factory DashboardSummaryResponse.fromJson(Map<String, dynamic> json) =>
      _$DashboardSummaryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardSummaryResponseToJson(this);
}

@JsonSerializable()
class DashboardDailyCount {
  DashboardDailyCount({required this.dateUtc, required this.count});

  final DateTime dateUtc;
  final int count;

  factory DashboardDailyCount.fromJson(Map<String, dynamic> json) =>
      _$DashboardDailyCountFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardDailyCountToJson(this);
}

@JsonSerializable()
class DashboardTopTraining {
  DashboardTopTraining({
    required this.trainingName,
    required this.categoryName,
    required this.reservationCount,
    required this.sharePercent,
  });

  final String trainingName;
  final String categoryName;
  final int reservationCount;
  final double sharePercent;

  factory DashboardTopTraining.fromJson(Map<String, dynamic> json) =>
      _$DashboardTopTrainingFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardTopTrainingToJson(this);
}

@JsonSerializable()
class DashboardRecentReservation {
  DashboardRecentReservation({
    required this.userFullName,
    required this.trainingName,
    required this.termStartUtc,
    required this.termEndUtc,
    required this.status,
    required this.reservedAtUtc,
  });

  final String userFullName;
  final String trainingName;
  final DateTime termStartUtc;
  final DateTime termEndUtc;
  final ReservationStatus status;
  final DateTime reservedAtUtc;

  factory DashboardRecentReservation.fromJson(Map<String, dynamic> json) =>
      _$DashboardRecentReservationFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardRecentReservationToJson(this);
}

@JsonSerializable()
class DashboardRecentPayment {
  DashboardRecentPayment({
    required this.userFullName,
    required this.packageName,
    required this.amount,
    required this.currency,
    required this.status,
    this.paidAtUtc,
    required this.createdAtUtc,
  });

  final String userFullName;
  final String packageName;
  final double amount;
  final String currency;
  final PaymentStatus status;
  final DateTime? paidAtUtc;
  final DateTime createdAtUtc;

  factory DashboardRecentPayment.fromJson(Map<String, dynamic> json) =>
      _$DashboardRecentPaymentFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardRecentPaymentToJson(this);
}
