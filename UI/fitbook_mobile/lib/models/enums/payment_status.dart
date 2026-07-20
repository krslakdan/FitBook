import 'package:json_annotation/json_annotation.dart';

enum PaymentStatus {
  @JsonValue(1)
  pending,
  @JsonValue(2)
  completed,
  @JsonValue(3)
  failed,
  @JsonValue(4)
  refunded;

  int get value => switch (this) {
    PaymentStatus.pending => 1,
    PaymentStatus.completed => 2,
    PaymentStatus.failed => 3,
    PaymentStatus.refunded => 4,
  };
}
