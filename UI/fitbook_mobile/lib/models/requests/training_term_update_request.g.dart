// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_term_update_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrainingTermUpdateRequest _$TrainingTermUpdateRequestFromJson(
  Map<String, dynamic> json,
) => TrainingTermUpdateRequest(
  startTimeUtc: DateTime.parse(json['startTimeUtc'] as String),
  endTimeUtc: DateTime.parse(json['endTimeUtc'] as String),
  maxParticipants: (json['maxParticipants'] as num).toInt(),
  isActive: json['isActive'] as bool,
  trainerId: (json['trainerId'] as num).toInt(),
  hallId: (json['hallId'] as num).toInt(),
);

Map<String, dynamic> _$TrainingTermUpdateRequestToJson(
  TrainingTermUpdateRequest instance,
) => <String, dynamic>{
  'startTimeUtc': instance.startTimeUtc.toIso8601String(),
  'endTimeUtc': instance.endTimeUtc.toIso8601String(),
  'maxParticipants': instance.maxParticipants,
  'isActive': instance.isActive,
  'trainerId': instance.trainerId,
  'hallId': instance.hallId,
};
