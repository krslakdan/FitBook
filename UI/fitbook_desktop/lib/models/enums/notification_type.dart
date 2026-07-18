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
  reservationReminder,
}
