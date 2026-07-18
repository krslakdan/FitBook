import 'package:json_annotation/json_annotation.dart';

enum MembershipStatus {
  @JsonValue(1)
  pending,
  @JsonValue(2)
  active,
  @JsonValue(3)
  expired,
  @JsonValue(4)
  cancelled;

  int get value => switch (this) {
    MembershipStatus.pending => 1,
    MembershipStatus.active => 2,
    MembershipStatus.expired => 3,
    MembershipStatus.cancelled => 4,
  };
}
