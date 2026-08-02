// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system_notification_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SystemNotificationResponse _$SystemNotificationResponseFromJson(
  Map<String, dynamic> json,
) => SystemNotificationResponse(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  content: json['content'] as String,
  isRead: json['isRead'] as bool,
  readAtUtc: json['readAtUtc'] == null
      ? null
      : DateTime.parse(json['readAtUtc'] as String),
  notificationType: $enumDecode(
    _$NotificationTypeEnumMap,
    json['notificationType'],
  ),
  userAccountId: (json['userAccountId'] as num).toInt(),
  userFullName: json['userFullName'] as String,
  createdAtUtc: DateTime.parse(json['createdAtUtc'] as String),
  updatedAtUtc: json['updatedAtUtc'] == null
      ? null
      : DateTime.parse(json['updatedAtUtc'] as String),
);

Map<String, dynamic> _$SystemNotificationResponseToJson(
  SystemNotificationResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'content': instance.content,
  'isRead': instance.isRead,
  'readAtUtc': instance.readAtUtc?.toIso8601String(),
  'notificationType': _$NotificationTypeEnumMap[instance.notificationType]!,
  'userAccountId': instance.userAccountId,
  'userFullName': instance.userFullName,
  'createdAtUtc': instance.createdAtUtc.toIso8601String(),
  'updatedAtUtc': instance.updatedAtUtc?.toIso8601String(),
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
  NotificationType.membershipPaymentFailed: 11,
  NotificationType.reservationReminder: 12,
  NotificationType.trainerReservationCreated: 13,
  NotificationType.trainerReservationCancelled: 14,
  NotificationType.trainerTermReminder: 15,
};
