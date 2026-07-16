import 'package:json_annotation/json_annotation.dart';

import '../common/api_request_body.dart';

part 'training_term_insert_request.g.dart';

/// Mirrors `FitBook.Model.Requests.TrainingTermInsertRequest`.
@JsonSerializable()
class TrainingTermInsertRequest implements ApiRequestBody {
  TrainingTermInsertRequest({
    required this.startTimeUtc,
    required this.endTimeUtc,
    required this.maxParticipants,
    required this.isActive,
    required this.trainingId,
    required this.trainerId,
    required this.hallId,
  });

  final DateTime startTimeUtc;
  final DateTime endTimeUtc;
  final int maxParticipants;
  final bool isActive;
  final int trainingId;
  final int trainerId;
  final int hallId;

  factory TrainingTermInsertRequest.fromJson(Map<String, dynamic> json) =>
      _$TrainingTermInsertRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TrainingTermInsertRequestToJson(this);
}
