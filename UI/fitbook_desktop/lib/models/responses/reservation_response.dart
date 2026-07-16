import 'package:json_annotation/json_annotation.dart';

import '../enums/reservation_status.dart';

part 'reservation_response.g.dart';

/// Mirrors `FitBook.Model.Responses.ReservationResponse`.
@JsonSerializable()
class ReservationResponse {
  ReservationResponse({
    required this.id,
    required this.status,
    required this.reservedAtUtc,
    this.confirmedAtUtc,
    this.cancelledAtUtc,
    this.completedAtUtc,
    this.cancellationReason,
    required this.userAccountId,
    required this.userFirstName,
    required this.userLastName,
    required this.userEmail,
    required this.trainingTermId,
    required this.trainingName,
    required this.trainingTermStartTimeUtc,
    required this.trainingTermEndTimeUtc,
    this.lastStatusChangedByUserAccountId,
    required this.createdAtUtc,
    this.updatedAtUtc,
  });

  final int id;
  final ReservationStatus status;
  final DateTime reservedAtUtc;
  final DateTime? confirmedAtUtc;
  final DateTime? cancelledAtUtc;
  final DateTime? completedAtUtc;
  final String? cancellationReason;
  final int userAccountId;
  final String userFirstName;
  final String userLastName;
  final String userEmail;
  final int trainingTermId;
  final String trainingName;
  final DateTime trainingTermStartTimeUtc;
  final DateTime trainingTermEndTimeUtc;
  final int? lastStatusChangedByUserAccountId;
  final DateTime createdAtUtc;
  final DateTime? updatedAtUtc;

  factory ReservationResponse.fromJson(Map<String, dynamic> json) =>
      _$ReservationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ReservationResponseToJson(this);
}
