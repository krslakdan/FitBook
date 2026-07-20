// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_summary_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardSummaryResponse _$DashboardSummaryResponseFromJson(
  Map<String, dynamic> json,
) => DashboardSummaryResponse(
  totalUsers: (json['totalUsers'] as num).toInt(),
  totalUsersChangePercent: (json['totalUsersChangePercent'] as num?)
      ?.toDouble(),
  activeMemberships: (json['activeMemberships'] as num).toInt(),
  activeMembershipsChangePercent:
      (json['activeMembershipsChangePercent'] as num?)?.toDouble(),
  todayReservations: (json['todayReservations'] as num).toInt(),
  todayReservationsChangePercent:
      (json['todayReservationsChangePercent'] as num?)?.toDouble(),
  monthRevenue: (json['monthRevenue'] as num).toDouble(),
  revenueCurrency: json['revenueCurrency'] as String,
  monthRevenueChangePercent: (json['monthRevenueChangePercent'] as num?)
      ?.toDouble(),
  reservationsPerDay: (json['reservationsPerDay'] as List<dynamic>)
      .map((e) => DashboardDailyCount.fromJson(e as Map<String, dynamic>))
      .toList(),
  topTrainings: (json['topTrainings'] as List<dynamic>)
      .map((e) => DashboardTopTraining.fromJson(e as Map<String, dynamic>))
      .toList(),
  recentReservations: (json['recentReservations'] as List<dynamic>)
      .map(
        (e) => DashboardRecentReservation.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
  recentPayments: (json['recentPayments'] as List<dynamic>)
      .map((e) => DashboardRecentPayment.fromJson(e as Map<String, dynamic>))
      .toList(),
  recentActivities: (json['recentActivities'] as List<dynamic>)
      .map((e) => DashboardActivity.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$DashboardSummaryResponseToJson(
  DashboardSummaryResponse instance,
) => <String, dynamic>{
  'totalUsers': instance.totalUsers,
  'totalUsersChangePercent': instance.totalUsersChangePercent,
  'activeMemberships': instance.activeMemberships,
  'activeMembershipsChangePercent': instance.activeMembershipsChangePercent,
  'todayReservations': instance.todayReservations,
  'todayReservationsChangePercent': instance.todayReservationsChangePercent,
  'monthRevenue': instance.monthRevenue,
  'revenueCurrency': instance.revenueCurrency,
  'monthRevenueChangePercent': instance.monthRevenueChangePercent,
  'reservationsPerDay': instance.reservationsPerDay,
  'topTrainings': instance.topTrainings,
  'recentReservations': instance.recentReservations,
  'recentPayments': instance.recentPayments,
  'recentActivities': instance.recentActivities,
};

DashboardDailyCount _$DashboardDailyCountFromJson(Map<String, dynamic> json) =>
    DashboardDailyCount(
      dateUtc: DateTime.parse(json['dateUtc'] as String),
      count: (json['count'] as num).toInt(),
    );

Map<String, dynamic> _$DashboardDailyCountToJson(
  DashboardDailyCount instance,
) => <String, dynamic>{
  'dateUtc': instance.dateUtc.toIso8601String(),
  'count': instance.count,
};

DashboardTopTraining _$DashboardTopTrainingFromJson(
  Map<String, dynamic> json,
) => DashboardTopTraining(
  trainingName: json['trainingName'] as String,
  categoryName: json['categoryName'] as String,
  reservationCount: (json['reservationCount'] as num).toInt(),
  sharePercent: (json['sharePercent'] as num).toDouble(),
);

Map<String, dynamic> _$DashboardTopTrainingToJson(
  DashboardTopTraining instance,
) => <String, dynamic>{
  'trainingName': instance.trainingName,
  'categoryName': instance.categoryName,
  'reservationCount': instance.reservationCount,
  'sharePercent': instance.sharePercent,
};

DashboardRecentReservation _$DashboardRecentReservationFromJson(
  Map<String, dynamic> json,
) => DashboardRecentReservation(
  userFullName: json['userFullName'] as String,
  userImageUrl: json['userImageUrl'] as String?,
  trainingName: json['trainingName'] as String,
  termStartUtc: DateTime.parse(json['termStartUtc'] as String),
  termEndUtc: DateTime.parse(json['termEndUtc'] as String),
  status: $enumDecode(_$ReservationStatusEnumMap, json['status']),
  reservedAtUtc: DateTime.parse(json['reservedAtUtc'] as String),
);

Map<String, dynamic> _$DashboardRecentReservationToJson(
  DashboardRecentReservation instance,
) => <String, dynamic>{
  'userFullName': instance.userFullName,
  'userImageUrl': instance.userImageUrl,
  'trainingName': instance.trainingName,
  'termStartUtc': instance.termStartUtc.toIso8601String(),
  'termEndUtc': instance.termEndUtc.toIso8601String(),
  'status': _$ReservationStatusEnumMap[instance.status]!,
  'reservedAtUtc': instance.reservedAtUtc.toIso8601String(),
};

const _$ReservationStatusEnumMap = {
  ReservationStatus.pending: 1,
  ReservationStatus.confirmed: 2,
  ReservationStatus.cancelled: 3,
  ReservationStatus.completed: 4,
};

DashboardActivity _$DashboardActivityFromJson(Map<String, dynamic> json) =>
    DashboardActivity(
      type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
      userFullName: json['userFullName'] as String,
      createdAtUtc: DateTime.parse(json['createdAtUtc'] as String),
    );

Map<String, dynamic> _$DashboardActivityToJson(DashboardActivity instance) =>
    <String, dynamic>{
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'userFullName': instance.userFullName,
      'createdAtUtc': instance.createdAtUtc.toIso8601String(),
    };

const _$NotificationTypeEnumMap = {
  NotificationType.reservationCreated: 1,
  NotificationType.reservationConfirmed: 2,
  NotificationType.reservationCancelled: 3,
  NotificationType.reservationCompleted: 4,
  NotificationType.membershipPaid: 5,
  NotificationType.membershipExpiringSoon: 6,
  NotificationType.newsPublished: 7,
  NotificationType.membershipCancelled: 8,
  NotificationType.membershipExpired: 9,
  NotificationType.trainingTermCancelled: 10,
  NotificationType.membershipPaymentFailed: 11,
  NotificationType.reservationReminder: 12,
};

DashboardRecentPayment _$DashboardRecentPaymentFromJson(
  Map<String, dynamic> json,
) => DashboardRecentPayment(
  userFullName: json['userFullName'] as String,
  packageName: json['packageName'] as String,
  amount: (json['amount'] as num).toDouble(),
  currency: json['currency'] as String,
  status: $enumDecode(_$PaymentStatusEnumMap, json['status']),
  paidAtUtc: json['paidAtUtc'] == null
      ? null
      : DateTime.parse(json['paidAtUtc'] as String),
  createdAtUtc: DateTime.parse(json['createdAtUtc'] as String),
);

Map<String, dynamic> _$DashboardRecentPaymentToJson(
  DashboardRecentPayment instance,
) => <String, dynamic>{
  'userFullName': instance.userFullName,
  'packageName': instance.packageName,
  'amount': instance.amount,
  'currency': instance.currency,
  'status': _$PaymentStatusEnumMap[instance.status]!,
  'paidAtUtc': instance.paidAtUtc?.toIso8601String(),
  'createdAtUtc': instance.createdAtUtc.toIso8601String(),
};

const _$PaymentStatusEnumMap = {
  PaymentStatus.pending: 1,
  PaymentStatus.completed: 2,
  PaymentStatus.failed: 3,
  PaymentStatus.refunded: 4,
};
