import 'package:json_annotation/json_annotation.dart';

enum TrainingTermStatus {
  @JsonValue(1)
  scheduled,
  @JsonValue(2)
  cancelled,
  @JsonValue(3)
  completed;

  int get value => switch (this) {
    TrainingTermStatus.scheduled => 1,
    TrainingTermStatus.cancelled => 2,
    TrainingTermStatus.completed => 3,
  };
}
