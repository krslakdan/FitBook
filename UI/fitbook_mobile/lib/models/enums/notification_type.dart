import 'package:json_annotation/json_annotation.dart';

enum NotificationType {
  @JsonValue(1)
  reservationCreated,
  @JsonValue(2)
  reservationConfirmed,
  @JsonValue(3)
  reservationCancelled,
  @JsonValue(4)
  reservationCompleted,
  @JsonValue(5)
  membershipPaid,
  @JsonValue(6)
  membershipExpiringSoon,
  @JsonValue(7)
  newsPublished,
  @JsonValue(8)
  membershipCancelled,
  @JsonValue(9)
  membershipExpired,
  @JsonValue(10)
  trainingTermCancelled,
  @JsonValue(11)
  membershipPaymentFailed,
  @JsonValue(12)
  reservationReminder;

  int get value => switch (this) {
    NotificationType.reservationCreated => 1,
    NotificationType.reservationConfirmed => 2,
    NotificationType.reservationCancelled => 3,
    NotificationType.reservationCompleted => 4,
    NotificationType.membershipPaid => 5,
    NotificationType.membershipExpiringSoon => 6,
    NotificationType.newsPublished => 7,
    NotificationType.membershipCancelled => 8,
    NotificationType.membershipExpired => 9,
    NotificationType.trainingTermCancelled => 10,
    NotificationType.membershipPaymentFailed => 11,
    NotificationType.reservationReminder => 12,
  };
}
