import 'package:json_annotation/json_annotation.dart';

import '../enums/training_term_status.dart';

part 'training_term_response.g.dart';

/// Mirrors `FitBook.Model.Responses.TrainingTermResponse`.
@JsonSerializable()
class TrainingTermResponse {
  TrainingTermResponse({
    required this.id,
    required this.startTimeUtc,
    required this.endTimeUtc,
    required this.maxParticipants,
    required this.status,
    required this.isActive,
    required this.trainingId,
    required this.trainingName,
    required this.trainerId,
    required this.trainerFirstName,
    required this.trainerLastName,
    required this.hallId,
    required this.hallName,
    required this.createdAtUtc,
    this.updatedAtUtc,
  });

  final int id;
  final DateTime startTimeUtc;
  final DateTime endTimeUtc;
  final int maxParticipants;
  final TrainingTermStatus status;
  final bool isActive;
  final int trainingId;
  final String trainingName;
  final int trainerId;
  final String trainerFirstName;
  final String trainerLastName;
  final int hallId;
  final String hallName;
  final DateTime createdAtUtc;
  final DateTime? updatedAtUtc;

  factory TrainingTermResponse.fromJson(Map<String, dynamic> json) =>
      _$TrainingTermResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TrainingTermResponseToJson(this);
}
