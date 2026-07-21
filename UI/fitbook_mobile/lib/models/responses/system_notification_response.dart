import 'package:json_annotation/json_annotation.dart';

import '../enums/notification_type.dart';

part 'system_notification_response.g.dart';

@JsonSerializable()
class SystemNotificationResponse {
  SystemNotificationResponse({
    required this.id,
    required this.title,
    required this.content,
    required this.isRead,
    this.readAtUtc,
    required this.notificationType,
    required this.userAccountId,
    required this.userFullName,
    required this.createdAtUtc,
    this.updatedAtUtc,
  });

  final int id;
  final String title;
  final String content;
  final bool isRead;
  final DateTime? readAtUtc;
  final NotificationType notificationType;
  final int userAccountId;
  final String userFullName;
  final DateTime createdAtUtc;
  final DateTime? updatedAtUtc;

  factory SystemNotificationResponse.fromJson(Map<String, dynamic> json) =>
      _$SystemNotificationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SystemNotificationResponseToJson(this);

  SystemNotificationResponse copyWith({bool? isRead, DateTime? readAtUtc}) {
    return SystemNotificationResponse(
      id: id,
      title: title,
      content: content,
      isRead: isRead ?? this.isRead,
      readAtUtc: readAtUtc ?? this.readAtUtc,
      notificationType: notificationType,
      userAccountId: userAccountId,
      userFullName: userFullName,
      createdAtUtc: createdAtUtc,
      updatedAtUtc: updatedAtUtc,
    );
  }
}
