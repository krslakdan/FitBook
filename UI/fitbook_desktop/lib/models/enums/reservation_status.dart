import 'package:json_annotation/json_annotation.dart';

/// Mirrors `FitBook.Model.Enums.ReservationStatus`.
enum ReservationStatus {
  @JsonValue(1)
  pending,
  @JsonValue(2)
  confirmed,
  @JsonValue(3)
  cancelled,
  @JsonValue(4)
  completed;

  /// The backend's underlying int value — kept explicit (not `index + 1`)
  /// so it can't silently drift from the `@JsonValue` above.
  int get value => switch (this) {
    ReservationStatus.pending => 1,
    ReservationStatus.confirmed => 2,
    ReservationStatus.cancelled => 3,
    ReservationStatus.completed => 4,
  };
}
