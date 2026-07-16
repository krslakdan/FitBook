import 'package:json_annotation/json_annotation.dart';

import '../common/api_request_body.dart';

part 'training_term_update_request.g.dart';

/// Mirrors `FitBook.Model.Requests.TrainingTermUpdateRequest`.
/// Note: unlike insert, the training cannot be changed on update.
@JsonSerializable()
class TrainingTermUpdateRequest implements ApiRequestBody {
  TrainingTermUpdateRequest({
    required this.startTimeUtc,
    required this.endTimeUtc,
    required this.maxParticipants,
    required this.isActive,
    required this.trainerId,
    required this.hallId,
  });

  final DateTime startTimeUtc;
  final DateTime endTimeUtc;
  final int maxParticipants;
  final bool isActive;
  final int trainerId;
  final int hallId;

  factory TrainingTermUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$TrainingTermUpdateRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TrainingTermUpdateRequestToJson(this);
}
