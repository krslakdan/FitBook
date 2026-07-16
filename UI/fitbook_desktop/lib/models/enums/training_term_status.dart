import 'package:json_annotation/json_annotation.dart';

/// Mirrors `FitBook.Model.Enums.TrainingTermStatus`.
enum TrainingTermStatus {
  @JsonValue(1)
  scheduled,
  @JsonValue(2)
  cancelled,
  @JsonValue(3)
  completed;

  /// The backend's underlying int value — kept explicit (not `index + 1`)
  /// so it can't silently drift from the `@JsonValue` above.
  int get value => switch (this) {
    TrainingTermStatus.scheduled => 1,
    TrainingTermStatus.cancelled => 2,
    TrainingTermStatus.completed => 3,
  };
}
