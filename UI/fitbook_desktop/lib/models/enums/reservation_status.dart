import 'package:json_annotation/json_annotation.dart';

enum ReservationStatus {
  @JsonValue(1)
  pending,
  @JsonValue(2)
  confirmed,
  @JsonValue(3)
  cancelled,
  @JsonValue(4)
  completed;

  int get value => switch (this) {
    ReservationStatus.pending => 1,
    ReservationStatus.confirmed => 2,
    ReservationStatus.cancelled => 3,
    ReservationStatus.completed => 4,
  };
}
